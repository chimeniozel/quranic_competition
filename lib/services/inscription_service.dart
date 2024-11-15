import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/jury.dart';
import 'package:quranic_competition/models/jurys_inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/models/result_model.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class InscriptionService {
// Get the next ID, unique per version and competition type
  static Future<int> getNextId(
      Competition competition, String competitionType) async {
    final counterDoc = FirebaseFirestore.instance.collection('counters').doc(
        '${competition.competitionVirsion}-$competitionType'); // Unique per version and type

    final snapshot = await counterDoc.get();

    int currentId = 0;
    if (snapshot.exists) {
      currentId = snapshot.data()!['currentId'] as int;
    }

    int newId = currentId + 1;
    await counterDoc.set({'currentId': newId});

    return newId;
  }

  // Get the current number of inscriptions for the given type and version
  static Future<int> getCurrentCount(
      String version, String competitionType) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(competitionType)
        .get();

    return querySnapshot.docs.length;
  }

  static Future<void> updateNumberConstraints(
      {required String competitionType,
      required Competition competition,
      required int index}) async {
    if (competitionType == "adult_inscription") {
      await FirebaseFirestore.instance
          .collection("competitions")
          .doc(competition.competitionId)
          .update({
        "adultNumber": index,
      });
    } else {
      await FirebaseFirestore.instance
          .collection("competitions")
          .doc(competition.competitionId)
          .update({
        "childNumber": index,
      });
    }
  }

  // Send inscription to Firebase with limits and version-index logic
  static Future<bool> sendToFirebase(
    Inscription inscription,
    BuildContext context,
    Competition competition,
  ) async {
    CollectionReference inscriptions =
        FirebaseFirestore.instance.collection('inscriptions');
    String competitionType;
    bool result = false;

    try {
      var year = DateTime.now().year - inscription.birthDate!.year;

      // Determine the competition type (adult/child)
      if (year < 12) {
        competitionType = "child_inscription";
      } else {
        competitionType = "adult_inscription";
      }

      // Get the current count for the type/version
      int currentCount = await getCurrentCount(
          competition.competitionVirsion!, competitionType);

      // Check limits (children: 50, adults: 100)
      if ((competitionType == "child_inscription" && currentCount >= 50) ||
          (competitionType == "adult_inscription" && currentCount >= 200)) {
        const limitSnackBar = SnackBar(
          content:
              Text('عذراً، تم الوصول إلى الحد الأقصى للتسجيل في هذا النوع.'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(limitSnackBar);
        return false;
      }

      // Get a unique ID for the new inscription
      int newId = await getNextId(competition, competitionType);
      inscription.idInscription = newId;

      // Check if the inscription already exists (by phone number)
      var data = await inscriptions
          .doc(competition.competitionVirsion)
          .collection(competitionType)
          .where("رقم الهاتف", isEqualTo: inscription.phoneNumber)
          .get();

      if (data.docs.isNotEmpty) {
        // Snackbar for duplicate registration
        final duplicateSnackBar = SnackBar(
          content: const Text('هذا المتسابق موجود سابقاً!'),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () {},
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(duplicateSnackBar);
      } else {
        // Add the new inscription to Firestore
        await inscriptions
            .doc(competition.competitionVirsion)
            .collection(competitionType)
            .doc(inscription.idInscription.toString())
            .set(inscription.toMap())
            .whenComplete(() async {
          updateNumberConstraints(
              competition: competition,
              competitionType: competitionType,
              index: newId);
          // Success snackbar
          final successSnackBar = SnackBar(
            content: const Text('تم التسجيل بنجاح!'),
            action: SnackBarAction(
              label: 'تراجع',
              onPressed: () {},
            ),
            backgroundColor: AppColors.greenColor,
          );
          ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
        });
        result = true;
      }
    } catch (e) {
      // Snackbar for errors
      final errorSnackBar = SnackBar(
        content: Text('حدث خطأ أثناء التسجيل: $e'),
        action: SnackBarAction(
          label: 'حاول مرة أخرى',
          onPressed: () {},
        ),
        backgroundColor: Colors.red,
      );
      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }
    return result;
  }

/*

// Stream to fetch all contestants from Firestore DB
  static Stream<List<Map<String, dynamic>>> streamContestants(
    String version,
    String competitionType,
    String competitionRound,
    Jury jury,
  ) {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(competitionType);

    if (competitionRound == "التصفيات الأولى") {
      return inscriptionCollection
          .orderBy("رقم التسجيل", descending: false)
          .snapshots()
          .asyncMap((QuerySnapshot querySnapshot) async {
        List<Map<String, dynamic>> inscriptions = [];
        print(
            "================================== querySnapshot : ${querySnapshot.docs.length}");
        for (var doc in querySnapshot.docs) {
          // Convert document snapshot to Inscription
          Inscription inscription = Inscription.fromDocumentSnapshot(doc);

          // Add initial entry for the inscription with a null firstNotes
          inscriptions.add({
            "inscription": inscription,
            "firstNotes": null, // Initialize as null
          });

          // Fetch corresponding jurys_inscriptions entries
          List<NoteModel> juryEntries = await fetchJuryEntries(
            version,
            inscription.idInscription!,
            competitionType,
            jury.userID!,
          );

          // Update the 'firstNotes' with the first entry in juryEntries, if it exists
          inscriptions.last["firstNotes"] =
              juryEntries.isNotEmpty ? juryEntries.first : null;
        }

        return inscriptions;
      });
    } else {
      return inscriptionCollection
          .where("نتائج التصفيات الأولى", isGreaterThanOrEqualTo: 14)
          .orderBy("رقم التسجيل", descending: false)
          .snapshots()
          .asyncMap((QuerySnapshot querySnapshot) async {
        List<Map<String, dynamic>> inscriptions = [];

        for (var doc in querySnapshot.docs) {
          Inscription inscription = Inscription.fromDocumentSnapshot(doc);

          // Fetch corresponding jurys_inscriptions
          List<NoteModel> juryEntries = await fetchJuryEntries(
            version,
            inscription.idInscription!,
            competitionType,
            jury.userID!,
          );

          NoteModel note = juryEntries.first;
          inscriptions.add({
            "inscription": inscription,
            "firstNotes": juryEntries.isNotEmpty ? note : null,
          });
        }

        return inscriptions;
      });
    }
  }

// Helper function to fetch jurys_inscriptions data for an inscription
  static Future<List<NoteModel>> fetchJuryEntries(
    String version,
    int idInscription,
    String competitionType,
    String juryID,
  ) async {
    QuerySnapshot<Map<String, dynamic>> docSnapshot = await FirebaseFirestore
        .instance
        .collection('inscriptions')
        .doc(version)
        .collection("jurysInscriptions")
        .where("idInscription", isEqualTo: idInscription)
        .where("idJury", isEqualTo: juryID)
        .get();

    print("====================== JurySnapshot : ${docSnapshot.docs.length}");

    List<NoteModel> juryEntries = [];
    for (var doc in docSnapshot.docs) {
      if (competitionType == "adult_inscription") {
        JuryInscription adultJuryInscription =
            JuryInscription.fromMapAdult(doc.data());
        juryEntries.add(adultJuryInscription.firstNotes!);
        print(
            "====================== adult_inscription : ${adultJuryInscription.idInscription}");
      } else {
        JuryInscription childJuryInscription =
            JuryInscription.fromMapChild(doc.data());
        juryEntries.add(childJuryInscription.firstNotes!);
        print(
            "====================== child_inscription : ${childJuryInscription.firstNotes?.toMapAdult()}");
      }
    }

    return juryEntries;
  }

*/

  static Stream<List<Map<String, dynamic>>> streamContestants(
      {required String version,
      required String competitionType,
      required String competitionRound,
      required double successMoyenne,
      required Jury jury}) async* {
    try {
      // Reference to the inscriptions collection
      CollectionReference inscriptionCollection = FirebaseFirestore.instance
          .collection('inscriptions')
          .doc(version)
          .collection(competitionType);

      // Fetch query snapshots based on competition round
      QuerySnapshot querySnapshot;
      if (competitionRound == "التصفيات الأولى") {
        querySnapshot = await inscriptionCollection
            .orderBy("رقم التسجيل", descending: false)
            .get();
      } else {
        querySnapshot = await inscriptionCollection
            .where("نتائج التصفيات الأولى",
                isGreaterThanOrEqualTo: successMoyenne)
            .orderBy("رقم التسجيل", descending: false)
            .get();
      }

      // Process inscriptions and fetch jury entries
      List<Map<String, dynamic>> inscriptions = [];
      for (var doc in querySnapshot.docs) {
        try {
          // Parse inscription
          Inscription inscription = Inscription.fromDocumentSnapshot(doc);

          // Fetch jury entries for the current inscription
          QuerySnapshot<Map<String, dynamic>> docSnapshot =
              await FirebaseFirestore.instance
                  .collection('inscriptions')
                  .doc(version)
                  .collection("jurysInscriptions")
                  .where("idInscription", isEqualTo: inscription.idInscription)
                  .where("idJury", isEqualTo: jury.userID!)
                  .get();

          // Process jury entries
          List<JuryInscription> juryEntries = [];
          for (var juryDoc in docSnapshot.docs) {
            Map<String, dynamic> data = juryDoc.data();
            JuryInscription? juryInscription;

            if (competitionType == "adult_inscription") {
              if (juryDoc.get("isAdult")) {
                JuryInscription adultJuryInscription =
                    JuryInscription.fromMapAdult(data);
                if (competitionRound == "التصفيات الأولى") {
                  if (adultJuryInscription.isFirstCorrected != null) {
                    juryInscription = adultJuryInscription;
                    juryEntries.add(juryInscription);
                    print(
                        "====================== FirstNotes: ${juryInscription.firstNotes?.toMapAdult()}, LastNotes: ${juryInscription.lastNotes?.toMapAdult()}");
                  } else {
                    print(
                        "Warning: Score is null for adult inscription ID: ${inscription.idInscription}");
                  }
                } else {
                  if (adultJuryInscription.isLastCorrected != null) {
                    juryInscription = adultJuryInscription;
                    juryEntries.add(juryInscription);
                    print(
                        "====================== FirstNotes: ${juryInscription.firstNotes?.toMapAdult()}, LastNotes: ${juryInscription.lastNotes?.toMapAdult()}");
                  } else {
                    print(
                        "Warning: Score is null for adult inscription ID: ${inscription.idInscription}");
                  }
                }
              }
            } else {
              if (!juryDoc.get("isAdult")) {
                JuryInscription childJuryInscription =
                    JuryInscription.fromMapChild(data);

                if (competitionRound == "التصفيات الأولى") {
                  if (childJuryInscription.isFirstCorrected != null) {
                    juryInscription = childJuryInscription;
                    juryEntries.add(juryInscription);
                    print(
                        "====================== FirstNotes: ${juryInscription.firstNotes?.toMapChild()}, LastNotes: ${juryInscription.lastNotes?.toMapChild()}");
                  } else {
                    print(
                        "Warning: Score is null for adult inscription ID: ${inscription.idInscription}");
                  }
                } else {
                  if (childJuryInscription.isLastCorrected != null) {
                    juryInscription = childJuryInscription;
                    juryEntries.add(juryInscription);
                    print(
                        "====================== FirstNotes: ${juryInscription.firstNotes?.toMapChild()}, LastNotes: ${juryInscription.lastNotes?.toMapChild()}");
                  } else {
                    print(
                        "Warning: Score is null for adult inscription ID: ${inscription.idInscription}");
                  }
                }
              }
            }
          }

          // Add processed data to the result list
          inscriptions.add({
            "inscription": inscription,
            "juryInscription":
                juryEntries.isNotEmpty ? juryEntries.first : null,
          });
        } catch (e) {
          print("Error processing inscription ${doc.id}: $e");
        }
      }

      // Yield the final result as a stream
      yield inscriptions;
    } catch (e) {
      print("Error fetching contestants: $e");
      yield [];
    }
  }

  // Function to fetch constraints
  static Future<List<Inscription>> fetchContestants(
    Competition competition,
    String competitionType,
  ) async {
    QuerySnapshot childSnapshot = await FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(competition.competitionVirsion)
        .collection(competitionType)
        .orderBy("رقم التسجيل", descending: false)
        .get();

    List<Inscription> inscriptions = [];

    for (var doc in childSnapshot.docs) {
      inscriptions.add(Inscription.fromDocumentSnapshot(doc));
    }
    return inscriptions;
  }

  static Future<void> exportDataAsXlsx(
      List<Inscription> notedInscriptions,
      List<Map<String, dynamic>> dataList,
      String fullName,
      Competition competition,
      String competionType,
      BuildContext context,
      String copmetitionRound) async {
    var excel = Excel.createExcel();
    NoteModel? noteModel;
    Sheet sheetObject = excel['Sheet1'];

    // Create header row
    if (dataList.isNotEmpty) {
      List<String> headers = [];
      if (competionType == "child_inscription") {
        headers = [
          "رقم المتسابق",
          "التجويد",
          "حسن الصوت",
          "عذوبة الصوت",
          "الوقف والإبتداء",
          "المجموع",
        ];
      } else {
        headers = [
          "رقم المتسابق",
          "التجويد",
          "حسن الصوت",
          "الإلتزام بالرواية",
          "المجموع",
        ];
      }
      List<CellValue?> cellHeaders = [];
      for (var header in headers) {
        cellHeaders.add(TextCellValue(header));
      }
      sheetObject.appendRow(cellHeaders);

      // Add data rows
      for (Inscription inscription in notedInscriptions) {
        for (var data in dataList) {
          if (DateTime.now().year - inscription.birthDate!.year < 13) {
            noteModel = NoteModel.fromMapChild(data);
          } else {
            noteModel = NoteModel.fromMapAdult(data);
          }
          List<CellValue> cells = [];

          // Add number of subscribers
          cells.add(TextCellValue(inscription.idInscription!.toString()));
          // Add Note Tajwid
          cells.add(TextCellValue(noteModel.noteTajwid!.toString()));
          // Add Housn al Sawtt
          cells.add(TextCellValue(noteModel.noteHousnSawtt!.toString()));
          if (competionType == "child_inscription") {
            // Add Ou4oubet al Sawtt
            cells.add(TextCellValue(noteModel.noteOu4oubetSawtt!.toString()));
            // Add Waqf And al Ibtidaa
            cells.add(TextCellValue(noteModel.noteWaqfAndIbtidaa!.toString()));
            // Add Total
            double total = noteModel.noteTajwid! +
                noteModel.noteHousnSawtt! +
                noteModel.noteOu4oubetSawtt! +
                noteModel.noteWaqfAndIbtidaa!;
            cells.add(TextCellValue(total.toString()));
          } else {
            // Add Iltizam bi Riwaya
            cells.add(TextCellValue(noteModel.noteIltizamRiwaya!.toString()));
            // Add Total
            double total = noteModel.noteTajwid! +
                noteModel.noteHousnSawtt! +
                noteModel.noteIltizamRiwaya!;
            cells.add(TextCellValue(total.toString()));
          }

          sheetObject.appendRow(cells);
        }
      }
    }

    // Convert the Excel file to bytes
    List<int>? fileBytes = excel.encode();

    // Upload the file to Firebase Storage
    if (fileBytes != null) {
      try {
        String fileName;
        if (competionType == "child_inscription") {
          fileName = "الشيخ $fullName - $copmetitionRound فئة الصغار.xlsx";
        } else {
          fileName = "الشيخ $fullName - $copmetitionRound فئة الكبار.xlsx";
        }

        // Reference to Firebase Storage
        Reference storageRef = FirebaseStorage.instance.ref().child(
            "${competition.competitionVirsion}/تصحيح لجنة التحكيم/$copmetitionRound/الشيخ $fullName/$fileName");

        // Upload the file (this will automatically replace the old file if it exists)
        UploadTask uploadTask =
            storageRef.putData(Uint8List.fromList(fileBytes));

        // Optionally, show a progress indicator
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          double progress = snapshot.bytesTransferred / snapshot.totalBytes;
          int percentage = (progress * 100).round();

          // Show a SnackBar with the upload progress
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Upload is $percentage% complete."),
              backgroundColor: AppColors.yellowColor,
              duration: const Duration(
                milliseconds: 500,
              ), // Short duration to update frequently
            ),
          );
        });

        // Wait for the upload to complete
        await uploadTask;

        // Get the download URL
        String downloadURL = await storageRef.getDownloadURL();

        // Show success SnackBar
        final successSnackBar = SnackBar(
          content: const Text('تم الإرسال بنجاح'),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () {
              // Perform some action
            },
          ),
          backgroundColor: AppColors.greenColor,
        );
        ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
      } catch (e) {
        // Show error SnackBar
        final successSnackBar = SnackBar(
          content: const Text('فشل تحميل الملف'),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () {
              // Perform some action
            },
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
      }
    } else {
      // Show error SnackBar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("فشل في ترميز ملف Excel."),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  static Future<void> exportFinalResultAsXlsx(
    List<ResultModel> resultModels,
    Competition competition,
    String competitionType,
    BuildContext context,
    String competitionRound,
  ) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sheet1'];

    // Create header row
    List<String> headers = [
      "المعدل العام",
      "الإسم الكامل",
      "رقم التسجيل",
    ];
    List<CellValue?> cellHeaders =
        headers.map((header) => TextCellValue(header)).toList();
    sheetObject.appendRow(cellHeaders);

    // Add data rows
    for (ResultModel resultModel in resultModels) {
      List<CellValue> cells = [
        TextCellValue(resultModel.generalMoyenne!.toString()), // Moyenne
        TextCellValue(resultModel.fullName!), // Full name
        TextCellValue(resultModel.idUser!.toString()), // Registration number
      ];
      sheetObject.appendRow(cells);
    }

    // Convert the Excel file to bytes
    List<int>? fileBytes = excel.encode();
    if (fileBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("فشل في ترميز ملف Excel."),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      // Request storage permissions
      if (await Permission.manageExternalStorage.request().isGranted) {
        String fileName = (competitionType == "child_inscription")
            ? "$competitionRound فئة الصغار.xlsx"
            : "$competitionRound فئة الكبار.xlsx";

        // Determine directory based on platform
        Directory? downloadsDirectory;
        if (Platform.isAndroid) {
          downloadsDirectory = Directory('/storage/emulated/0/Download');
        } else if (Platform.isIOS) {
          downloadsDirectory = await getApplicationDocumentsDirectory();
        }

        // If directory does not exist, fallback to external storage
        if (downloadsDirectory == null || !downloadsDirectory.existsSync()) {
          downloadsDirectory = await getExternalStorageDirectory();
        }

        // Construct file path
        String filePath = "${downloadsDirectory!.path}/$fileName";
        File file = File(filePath);

        // Create the file if it does not exist, or replace it if it does
        await file.create(recursive: true);
        await file.writeAsBytes(fileBytes);

        // Show success message and open file
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حفظ الملف في التنزيلات'),
            action: SnackBarAction(
              label: 'فتح',
              onPressed: () async {
                await OpenFilex.open(file.path);
              },
            ),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("فشل في الحصول على إذن التخزين.")),
        );
      }
    } catch (e) {
      print("Error saving file: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حفظ الملف: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
