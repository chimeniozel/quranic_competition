import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';

class InscriptionService {


 static Future<bool> sendToFirebase(
      Inscription inscription, BuildContext context, String version) async {
    CollectionReference inscriptions =
        FirebaseFirestore.instance.collection('inscriptions');
    String competitionType;
    bool result = false;

    try {
      var year = DateTime.now().year - inscription.birthDate!.year;
      if (year < 18) {
        competitionType = "child_inscription";
      } else {
        competitionType = "adult_inscription";
      }
      int newId = await Inscription.getNextId();
      inscription.idInscription = newId; // Update the ID with the new value

      var data = await inscriptions
          .doc(version)
          .collection(competitionType)
          .doc(inscription.phoneNumber)
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
            .doc(inscription.phoneNumber)
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