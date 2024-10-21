import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/providers/auth_provider.dart';

class InscriptionService {
// Get the next ID, unique per version and competition type
  static Future<int> getNextId(String version, String competitionType) async {
    final counterDoc = FirebaseFirestore.instance
        .collection('counters')
        .doc('$version-$competitionType'); // Unique per version and type

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

  // Send inscription to Firebase with limits and version-index logic
  static Future<bool> sendToFirebase(
    Inscription inscription,
    BuildContext context,
    String version,
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
      int currentCount = await getCurrentCount(version, competitionType);

      // Check limits (children: 50, adults: 100)
      if ((competitionType == "child_inscription" && currentCount >= 50) ||
          (competitionType == "adult_inscription" && currentCount >= 100)) {
        const limitSnackBar = SnackBar(
          content:
              Text('عذراً، تم الوصول إلى الحد الأقصى للتسجيل في هذا النوع.'),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(limitSnackBar);
        return false;
      }

      // Get a unique ID for the new inscription
      int newId = await getNextId(version, competitionType);
      inscription.idInscription = newId;

      // Check if the inscription already exists (by phone number)
      var data = await inscriptions
          .doc(version)
          .collection(competitionType)
          .doc(inscription.phoneNumber)
          .get();

      if (data.exists) {
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
            .doc(version)
            .collection(competitionType)
            .doc(inscription.phoneNumber)
            .set(inscription.toMap())
            .whenComplete(() {
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

  // Fetch all contestants from firestore db
  static Stream<List<Inscription>> streamContestants(
    String version,
    String cometionType,
    String comprtitionRound,
  ) {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(cometionType);

    if (comprtitionRound == "التصفيات الأولى") {
      return inscriptionCollection
          .orderBy("رقم التسجيل", descending: false)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        List<Inscription> inscriptions = [];
        for (var doc in querySnapshot.docs) {
          // Inscription ins = Inscription.fromDocumentSnapshot(doc);
          print("================================\n ${doc.get("رقم الهاتف")}");
          inscriptions.add(Inscription.fromDocumentSnapshot(doc));
        }
        return inscriptions;
      });
    } else {
      return inscriptionCollection
          .where("نتائج التصفيات الأولى", isGreaterThanOrEqualTo: 14)
          .orderBy("رقم التسجيل", descending: false)
          .snapshots()
          .map((QuerySnapshot querySnapshot) {
        List<Inscription> inscriptions = [];
        for (var doc in querySnapshot.docs) {
          // Inscription ins = Inscription.fromDocumentSnapshot(doc);
          print("================================\n ${doc.get("رقم الهاتف")}");
          inscriptions.add(Inscription.fromDocumentSnapshot(doc));
        }
        return inscriptions;
      });
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

  // Function to fetch constraints by jury
  static Future<List<Inscription>> fetchContestantsByJury(
    Competition competition,
    String competitionType,
    String juryName,
    String competitionRound,
    BuildContext context,
  ) async {
    Users currentUser =
        Provider.of<AuthProvider>(context, listen: false).currentUser!;
    var inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc("النسخة الرابعة")
        .collection("adult_inscription")
        .where("اسم الشيخ", arrayContainsAny: ["شمني"]);
    QuerySnapshot querySnapshot = await inscriptionCollection
        // .orderBy("رقم التسجيل", descending: false)
        .get();

    print("==================================== ${querySnapshot.docs.length}");

    List<Inscription> inscriptions = [];

    for (var doc in querySnapshot.docs) {
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
    NoteResult? noteResult;
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
            noteResult = NoteResult.fromMapChild(data);
          } else {
            noteResult = NoteResult.fromMapAdult(data);
          }
          List<CellValue> cells = [];

          // Add number of subscribers
          cells.add(TextCellValue(inscription.idInscription!.toString()));
          // Add Note Tajwid
          cells.add(TextCellValue(noteResult.notes!.noteTajwid!.toString()));
          // Add Housn al Sawtt
          cells
              .add(TextCellValue(noteResult.notes!.noteHousnSawtt!.toString()));
          if (competionType == "child_inscription") {
            // Add Ou4oubet al Sawtt
            cells.add(
                TextCellValue(noteResult.notes!.noteOu4oubetSawtt!.toString()));
            // Add Waqf And al Ibtidaa
            cells.add(TextCellValue(
                noteResult.notes!.noteWaqfAndIbtidaa!.toString()));
            // Add Total
            double total = noteResult.notes!.noteTajwid! +
                noteResult.notes!.noteHousnSawtt! +
                noteResult.notes!.noteOu4oubetSawtt! +
                noteResult.notes!.noteWaqfAndIbtidaa!;
            cells.add(TextCellValue(total.toString()));
          } else {
            // Add Iltizam bi Riwaya
            cells.add(
                TextCellValue(noteResult.notes!.noteIltizamRiwaya!.toString()));
            // Add Total
            double total = noteResult.notes!.noteTajwid! +
                noteResult.notes!.noteHousnSawtt! +
                noteResult.notes!.noteIltizamRiwaya!;
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
}
