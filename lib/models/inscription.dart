import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';

class Inscription {
  int? _idInscription;
  String? _fullName;
  String? _phoneNumber;
  DateTime? _birthDate;
  String? _residencePlace;
  String? _howMuchYouMemorize;
  String? _haveYouIhaza;
  String? _howMuchRiwayaYouHave;
  String? _haveYouParticipatedInACompetition;
  String? _haveYouEverWon1stTo2ndPlace;
  Map<String, dynamic>? _noteTajwid;
  Map<String, dynamic>? _noteHousnSawtt;
  Map<String, dynamic>? _noteOu4oubetSawtt;
  Map<String, dynamic>? _noteWaqfAndIbtidaa;
  Map<String, dynamic>? _noteIltizamRiwaya;
  Map<String, dynamic>? _result;

  Inscription({
    int? idInscription,
    String? fullName,
    String? phoneNumber,
    DateTime? birthDate,
    String? residencePlace,
    String? howMuchYouMemorize,
    String? haveYouIhaza,
    String? howMuchRiwayaYouHave,
    String? haveYouParticipatedInACompetition,
    String? haveYouEverWon1stTo2ndPlace,
    Map<String, dynamic>? noteTajwid,
    Map<String, dynamic>? noteHousnSawtt,
    Map<String, dynamic>? noteOu4oubetSawtt,
    Map<String, dynamic>? noteWaqfAndIbtidaa,
    Map<String, dynamic>? noteIltizamRiwaya,
    Map<String, dynamic>? result,
  })  : _idInscription = idInscription,
        _fullName = fullName,
        _phoneNumber = phoneNumber,
        _birthDate = birthDate,
        _residencePlace = residencePlace,
        _howMuchYouMemorize = howMuchYouMemorize,
        _haveYouIhaza = haveYouIhaza,
        _howMuchRiwayaYouHave = howMuchRiwayaYouHave,
        _haveYouParticipatedInACompetition = haveYouParticipatedInACompetition,
        _haveYouEverWon1stTo2ndPlace = haveYouEverWon1stTo2ndPlace,
        _noteTajwid = noteTajwid,
        _noteHousnSawtt = noteHousnSawtt,
        _noteOu4oubetSawtt = noteOu4oubetSawtt,
        _noteWaqfAndIbtidaa = noteWaqfAndIbtidaa,
        _noteIltizamRiwaya = noteIltizamRiwaya,
        _result = result;

  // Getters
  int? get idInscription => _idInscription;
  String? get fullName => _fullName;
  String? get phoneNumber => _phoneNumber;
  DateTime? get birthDate => _birthDate;
  String? get residencePlace => _residencePlace;
  String? get howMuchYouMemorize => _howMuchYouMemorize;
  String? get haveYouIhaza => _haveYouIhaza;
  String? get howMuchRiwayaYouHave => _howMuchRiwayaYouHave;
  String? get haveYouParticipatedInACompetition =>
      _haveYouParticipatedInACompetition;
  String? get haveYouEverWon1stTo2ndPlace => _haveYouEverWon1stTo2ndPlace;
  Map<String, dynamic>? get noteTajwid => _noteTajwid;
  Map<String, dynamic>? get noteHousnSawtt => _noteHousnSawtt;
  Map<String, dynamic>? get noteOu4oubetSawtt => _noteOu4oubetSawtt;
  Map<String, dynamic>? get noteWaqfAndIbtidaa => _noteWaqfAndIbtidaa;
  Map<String, dynamic>? get noteIltizamRiwaya => _noteIltizamRiwaya;
  Map<String, dynamic>? get result => _result;

  // Setters
  set idInscription(int? value) {
    _idInscription = value;
  }

  set fullName(String? value) {
    _fullName = value;
  }

  set phoneNumber(String? value) {
    _phoneNumber = value;
  }

  set birthDate(DateTime? value) {
    _birthDate = value;
  }

  set residencePlace(String? value) {
    _residencePlace = value;
  }

  set howMuchYouMemorize(String? value) {
    _howMuchYouMemorize = value;
  }

  set haveYouIhaza(String? value) {
    _haveYouIhaza = value;
  }

  set howMuchRiwayaYouHave(String? value) {
    _howMuchRiwayaYouHave = value;
  }

  set haveYouParticipatedInACompetition(String? value) {
    _haveYouParticipatedInACompetition = value;
  }

  set haveYouEverWon1stTo2ndPlace(String? value) {
    _haveYouEverWon1stTo2ndPlace = value;
  }

  set noteTajwid(Map<String, dynamic>? value) {
    _noteTajwid = value;
  }

  set noteHousnSawtt(Map<String, dynamic>? value) {
    _noteHousnSawtt = value;
  }

  set noteOu4oubetSawtt(Map<String, dynamic>? value) {
    _noteOu4oubetSawtt = value;
  }

  set noteWaqfAndIbtidaa(Map<String, dynamic>? value) {
    _noteWaqfAndIbtidaa = value;
  }

  set noteIltizamRiwaya(Map<String, dynamic>? value) {
    _noteIltizamRiwaya = value;
  }

  set result(Map<String, dynamic>? value) {
    _result = value;
  }

  Map<String, dynamic> toMap() {
    return {
      "رقم التسجيل": _idInscription,
      "الاسم الثلاثي": _fullName,
      "رقم الهاتف": _phoneNumber,
      "تاريخ الميلاد": _birthDate?.toIso8601String(),
      "مكان الإقامة الحالية": _residencePlace,
      "كم تحفظ من القرآن الكريم": _howMuchYouMemorize,
      "هل حصلت على إجازة": _haveYouIhaza,
      "كم رواية تقرأ بها": _howMuchRiwayaYouHave,
      "هل سبق وأن شاركت في نسخة ماضية من مسابقة أهل القرآن الوتسابية":
          _haveYouParticipatedInACompetition,
      "هل سبق وأن حصلت على المراتب 1 إلى 2  في مسابقة أهل القرآن الوتسابية أو أي مسابقة أخرى":
          _haveYouEverWon1stTo2ndPlace,
      "التجويد": _noteTajwid,
      "حسن الصوت": _noteHousnSawtt,
      "عذوبة الصوت": _noteOu4oubetSawtt,
      "الوقف والإبتداء": _noteWaqfAndIbtidaa,
      "الإلتزام بالرواية": _noteIltizamRiwaya,
      "المجموع": _result,
    };
  }

  factory Inscription.fromMap(Map<String, dynamic> map) {
    return Inscription(
      idInscription: map["رقم التسجيل"] as int?,
      fullName: map["الاسم الثلاثي"] as String?,
      phoneNumber: map["رقم الهاتف"] as String?,
      birthDate: DateTime.parse(map["تاريخ الميلاد"] as String),
      residencePlace: map["مكان الإقامة الحالية"] as String?,
      howMuchYouMemorize: map["كم تحفظ من القرآن الكريم"] as String?,
      haveYouIhaza: map["هل حصلت على إجازة"] as String?,
      howMuchRiwayaYouHave: map["كم رواية تقرأ بها"] as String?,
      haveYouParticipatedInACompetition:
          map["هل سبق وأن شاركت في نسخة ماضية من مسابقة أهل القرآن الوتسابية"]
              as String?,
      haveYouEverWon1stTo2ndPlace:
          map["هل سبق وأن حصلت على المراتب 1 إلى 2  في مسابقة أهل القرآن الوتسابية أو أي مسابقة أخرى"]
              as String?,
      noteTajwid: map["التجويد"] as Map<String, dynamic>?,
      noteHousnSawtt: map["حسن الصوت"] as Map<String, dynamic>?,
      noteOu4oubetSawtt: map["عذوبة الصوت"] as Map<String, dynamic>?,
      noteWaqfAndIbtidaa: map["الوقف والإبتداء"] as Map<String, dynamic>?,
      noteIltizamRiwaya: map["الإلتزام بالرواية"] as Map<String, dynamic>?,
      result: map["المجموع"] as Map<String, dynamic>?,
    );
  }

  factory Inscription.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Inscription.fromMap(data);
  }

  static Future<int> _getNextId() async {
    final counterDoc = FirebaseFirestore.instance
        .collection('counters')
        .doc('inscriptionIdCounter');
    final snapshot = await counterDoc.get();

    int currentId = 0;
    if (snapshot.exists) {
      currentId = snapshot.data()!['currentId'] as int;
    }

    int newId = currentId + 1;
    await counterDoc.set({'currentId': newId});

    return newId;
  }

  static Future<bool> sendToFirebase(
      Inscription inscription, BuildContext context, String version) async {
    CollectionReference inscriptions =
        FirebaseFirestore.instance.collection('inscriptions');
    String competitionType;
    bool result = false;

    try {
      var year = DateTime.now().year - inscription._birthDate!.year;
      if (year < 18) {
        competitionType = "child_inscription";
      } else {
        competitionType = "adult_inscription";
      }
      int newId = await _getNextId();
      inscription.idInscription = newId; // Update the ID with the new value

      var data = await inscriptions
          .doc(version)
          .collection(competitionType)
          .doc(inscription._phoneNumber)
          .get();
      if (data.exists) {
        // Snackbar for success
        final successSnackBar = SnackBar(
          content: const Text('هذا المتسابق موجود سابقا !'),
          action: SnackBarAction(
            label: 'تراجع',
            onPressed: () {
              // Perform some action
            },
          ),
          backgroundColor: Colors.red,
        );
        ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
      } else {
        await inscriptions
            .doc(version)
            .collection(competitionType)
            .doc(inscription._phoneNumber)
            .set(inscription.toMap())
            .whenComplete(
          () {
            // Snackbar for success
            final successSnackBar = SnackBar(
              content: const Text('تم التسجيل بنجاح'),
              action: SnackBarAction(
                label: 'تراجع',
                onPressed: () {
                  // Perform some action
                },
              ),
              backgroundColor: AppColors.greenColor,
            );
            ScaffoldMessenger.of(context).showSnackBar(successSnackBar);
          },
        );
      }
    } catch (e) {
      // Snackbar for exception
      final errorSnackBar = SnackBar(
        content: Text('حدث خطأ أثناء التسجيل: $e'),
        action: SnackBarAction(
          label: 'حاول مرة أخرى',
          onPressed: () {
            // Optional: Retry the operation or other actions
          },
        ),
        backgroundColor: Colors
            .red, // Optional: Change the background color to red to indicate an error
      );

      ScaffoldMessenger.of(context).showSnackBar(errorSnackBar);
    }
    return result;
  }

  // Fetch all contestants from firestore db
  static Stream<List<Inscription>> streamContestants(
      String version, String cometionType) {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(cometionType);

    return inscriptionCollection
        .orderBy("رقم التسجيل", descending: false)
        .snapshots()
        .map((QuerySnapshot querySnapshot) {
      List<Inscription> inscriptions = [];
      for (var doc in querySnapshot.docs) {
        inscriptions.add(Inscription.fromDocumentSnapshot(doc));
      }
      return inscriptions;
    });
  }

  // Function to fetch constraints
  static Future<List<Inscription>> fetchContestants(
      String version, String cometionType) async {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(cometionType);
    QuerySnapshot querySnapshot = await inscriptionCollection
        .orderBy("رقم التسجيل", descending: false)
        .get();

    List<Inscription> inscriptions = [];

    for (var doc in querySnapshot.docs) {
      inscriptions.add(Inscription.fromDocumentSnapshot(doc));
    }

    return inscriptions;
  }

  static Future<void> exportDataAsXlsx(
      List<Map<String, dynamic>> dataList,
      String fullName,
      String competionVersion,
      String competionType,
      BuildContext context) async {
    var excel = Excel.createExcel();

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
      for (var data in dataList) {
        Inscription inscription = Inscription.fromMap(data);
        List<CellValue> cells = [];

        // Add number of subscribers
        cells.add(TextCellValue(inscription.idInscription!.toString()));
        // Add Note Tajwid
        cells.add(TextCellValue(inscription.noteTajwid![fullName].toString()));
        // Add Housn al Sawtt
        cells.add(
            TextCellValue(inscription.noteHousnSawtt![fullName].toString()));
        if (competionType == "child_inscription") {
          // Add Ou4oubet al Sawtt
          cells.add(TextCellValue(
              inscription.noteOu4oubetSawtt![fullName].toString()));
          // Add Waqf And al Ibtidaa
          cells.add(TextCellValue(
              inscription.noteWaqfAndIbtidaa![fullName].toString()));
        } else {
          // Add Iltizam bi Riwaya
          cells.add(TextCellValue(
              inscription.noteIltizamRiwaya![fullName].toString()));
        }
        // Add Total
        cells.add(TextCellValue(inscription.result![fullName].toString()));

        sheetObject.appendRow(cells);
      }
    }

    // Convert the Excel file to bytes
    List<int>? fileBytes = excel.encode();

    // Upload the file to Firebase Storage
    if (fileBytes != null) {
      try {
        String fileName;
        if (competionType == "child_inscription") {
          fileName = "الشيخ $fullName - فئة الصغار.xlsx";
        } else {
          fileName = "الشيخ $fullName - فئة الكبار.xlsx";
        }

        // Reference to Firebase Storage
        Reference storageRef = FirebaseStorage.instance.ref().child(
            "تصحيح لجنة التحكيم/$competionVersion/الشيخ $fullName/$fileName");

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
