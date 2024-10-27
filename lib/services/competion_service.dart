import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/models/users.dart';

class CompetitionService {
  // Reference to the competitions collection in Firestore
  static CollectionReference<Map<String, dynamic>> competitionCollection =
      FirebaseFirestore.instance.collection("competitions");

  // Method to get current competition from Firebase
  static Future<Competition?> getCurrentCompetition() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await competitionCollection.where("isActive", isEqualTo: true).get();

      if (querySnapshot.docs.isNotEmpty) {
        Map<String, dynamic> competitionData = querySnapshot.docs[0].data();
        return Competition.fromMap(competitionData);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      print("Error fetching competition: $e");
      return null;
    }
  }

  static Future<void> updateImagesURL(
      BuildContext context, Competition competition) async {
    // Update the existing competition document in Firestore

    await FirebaseFirestore.instance
        .collection('competitions')
        .doc(competition
            .competitionId) // Reference to the specific competition document
        .update({
      'archiveEntry.imagesURL':
          FieldValue.arrayUnion(competition.archiveEntry!.imagesURL!),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث المسابقة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  static Future<void> updateVideosURL(
      BuildContext context, Competition competition) async {
    // Update the existing competition document in Firestore

    await FirebaseFirestore.instance
        .collection('competitions')
        .doc(competition
            .competitionId) // Reference to the specific competition document
        .update({
      'archiveEntry.videosURL':
          FieldValue.arrayUnion(competition.archiveEntry!.videosURL!),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث المسابقة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

// Method to get competition from Firebase
  static Future<Competition?> getCompetition(String competitionId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await competitionCollection.doc(competitionId).get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> competitionData = documentSnapshot.data()!;
        return Competition.fromMap(competitionData);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      print("Error fetching competition: $e");
      return null;
    }
  }

  static Future<bool> hasActiveCompetition() async {
    final QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('competitions')
        .where('isActive', isEqualTo: true)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  static Future<bool> checkIfCompetitionIsActive(String competitionId) async {
    try {
      DocumentSnapshot competitionSnapshot = await FirebaseFirestore.instance
          .collection('competitions')
          .doc(competitionId)
          .get();

      // Return the isActive state of the competition
      return competitionSnapshot['isActive'] ?? false;
    } catch (e) {
      print('Error fetching competition data: $e');
      return false;
    }
  }

  static Future<void> extendCompetition(
      BuildContext context, String competitionId, DateTime endDate) async {
    final TextEditingController daysController = TextEditingController();

    // Check the current state of the competition
    bool isActive = await checkIfCompetitionIsActive(competitionId);

    if (!isActive) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('لا يمكن تمديد نسخة غير نشطة'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // If the competition is active, show the extension dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('تمديد المدة'),
          content: TextField(
            controller: daysController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'عدد الأيام',
              hintText: 'أدخل عدد الأيام لتمديد المدة',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('إلغاء'),
            ),
            TextButton(
              onPressed: () {
                final int? extensionDays = int.tryParse(daysController.text);
                if (extensionDays != null && extensionDays > 0) {
                  DateTime newEndDate =
                      endDate.add(Duration(days: extensionDays));
                  FirebaseFirestore.instance
                      .collection('competitions')
                      .doc(competitionId)
                      .update({
                    'endDate': newEndDate,
                  }).then((_) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تم تمديد المدة بنجاح'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }).catchError((error) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('فشل التمديد: $error'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                }
              },
              child: const Text('تمديد'),
            ),
          ],
        );
      },
    );
  }

  static Future<List<Users>> getJuryUsers() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .where('role', isEqualTo: "عضو لجنة التحكيم")
              .get();

      List<Users> juryUsers = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> userData = doc.data();
        Users user = Users.fromMap(userData);
        juryUsers.add(user);
      }

      return juryUsers;
    } on FirebaseException catch (e) {
      print("Error fetching jury users: $e");
      return [];
    }
  }

  // get images archives as a stream
  static Stream<List<String>> getImagesArchives(String competitionId) {
    return FirebaseFirestore.instance
        .collection("competitions")
        .doc(competitionId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      List<String> archives = [];
      if (snapshot.exists) {
        Competition competition = Competition.fromMap(snapshot.data());
        List<String>? imagesURL = competition.archiveEntry?.imagesURL;

        if (imagesURL != null) {
          archives.addAll(imagesURL);
        }
      }
      return archives;
    }).handleError((error) {
      print("Error fetching archives: $error");
      return [];
    });
  }

  // get videos archives as a stream
  static Stream<List<String>> getVideosArchives(String competitionId) {
    return FirebaseFirestore.instance
        .collection("competitions")
        .doc(competitionId)
        .snapshots()
        .map((DocumentSnapshot<Map<String, dynamic>> snapshot) {
      List<String> archives = [];
      if (snapshot.exists) {
        Competition competition = Competition.fromMap(snapshot.data());
        List<String>? videosURL = competition.archiveEntry?.videosURL;

        if (videosURL != null) {
          archives.addAll(videosURL);
        }
      }
      return archives;
    }).handleError((error) {
      print("Error fetching archives: $error");
      return [];
    });
  }

  // read excel file
  void readExcelFile() async {
    // احصل على مسار الملف (يمكن أن يكون ملفًا محليًا أو من مجلد التنزيلات)
    Directory directory = await getApplicationDocumentsDirectory();
    String path =
        '${directory.path}/test.xlsx'; // قم بتغيير المسار بناءً على موقع ملفك

    // قراءة الملف
    var file = File(path);
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // طباعة البيانات
    for (var table in excel.tables.keys) {
      print('Sheet: $table');
      print('Max rows: ${excel.tables[table]!.maxRows}');
      print('Max cols: ${excel.tables[table]!.maxColumns}');

      for (var row in excel.tables[table]!.rows) {
        print('$row');
      }
    }
  }

  static Future<List<Inscription>> getResults({
    required String competitionVersion,
    required String competitionRound,
    required bool isPassedFirstRound,
    required String competitionType,
    required String query,
  }) async {
    try {
      // Query Firestore with the selected competition round.
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection("inscriptions")
              .doc(competitionVersion)
              .collection(competitionType)
              .where("isPassedFirstRound",
                  isEqualTo: isPassedFirstRound) // Add round filter
              .orderBy("نتائج التصفيات الأولى", descending: true)
              .get();

      List<Inscription> inscriptions = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> resultData = doc.data();
        Inscription result = Inscription.fromMap(resultData);

        if (!result.isPassedFirstRound!) {
          // Select the appropriate round list
          List<dynamic>? roundList = result.tashihMachaikhs?.firstRound;
          int correctedCount = 0;
          for (var element in (roundList ?? [])) {
            // Handle null roundList
            try {
              NoteResult noteResult;

              // Check if it's an adult or child inscription and parse accordingly
              if (competitionType == "adult_inscription") {
                noteResult = NoteResult.fromMapAdult(element);
              } else {
                noteResult = NoteResult.fromMapChild(element);
              }

              // Safely check if the result is corrected
              if (noteResult.isCorrected!) {
                correctedCount++;
              }
            } catch (e) {
              print("Error parsing NoteResult: $e");
            }
          }
          if (correctedCount == roundList!.length) {
            if (query.isNotEmpty) {
              // Handle numeric query conversion safely.
              if (double.tryParse(query) == result.idInscription) {
                inscriptions.add(result);
              }
            } else {
              inscriptions.add(result);
            }
          }
        } else {
          List<dynamic>? roundList = result.tashihMachaikhs?.finalRound;
          int correctedCount = 0;
          for (var element in (roundList ?? [])) {
            // Handle null roundList
            try {
              NoteResult noteResult;

              // Check if it's an adult or child inscription and parse accordingly
              if (competitionType == "adult_inscription") {
                noteResult = NoteResult.fromMapAdult(element);
              } else {
                noteResult = NoteResult.fromMapChild(element);
              }

              // Safely check if the result is corrected
              if (noteResult.isCorrected!) {
                correctedCount++;
              }
            } catch (e) {
              print("Error parsing NoteResult: $e");
            }
          }
          if (correctedCount == roundList!.length) {
            if (query.isNotEmpty) {
              // Handle numeric query conversion safely.
              if (double.tryParse(query) == result.idInscription) {
                inscriptions.add(result);
              }
            } else {
              inscriptions.add(result);
            }
          }
        }
      }

      return inscriptions;
    } on FirebaseException catch (e) {
      print("Error fetching results: $e");
      return [];
    }
  }

  static NoteResult getNoteResult(
      Map<String, dynamic> element, String competitionType) {
    if (competitionType == "adult_inscription") {
      return NoteResult.fromMapAdult(element);
    } else if (competitionType == "child_inscription") {
      return NoteResult.fromMapChild(element);
    } else {
      throw ArgumentError("Invalid competition type: $competitionType");
    }
  }

  static double getResult(List<dynamic> roundList, String competitionType) {
    // Ensure that notes and result are properly accessed and filtered
    var results = roundList
        .map((element) => getNoteResult(element, competitionType))
        .where(
            (noteResult) => noteResult.notes != null) // Filter out null notes
        .map((noteResult) => noteResult.notes!.result) // Extract the results
        .whereType<double>() // Ensure only valid doubles
        .toList();

    // Return the sum of all results or 0 if the list is empty
    return results.isNotEmpty ? results.reduce((a, b) => a + b) : 0.0;
  }

  static Future<bool> publishResults(
    String competitionVersion,
    String competitionRound,
  ) async {
    List<Inscription> inscriptions = [];
    try {
      CollectionReference<Map<String, dynamic>> adultQuerySnapshot =
          FirebaseFirestore.instance
              .collection("inscriptions")
              .doc(competitionVersion)
              .collection("adult_inscription");
      CollectionReference<Map<String, dynamic>> childQuerySnapshot =
          FirebaseFirestore.instance
              .collection("inscriptions")
              .doc(competitionVersion)
              .collection("child_inscription");
      var adultQuery = await adultQuerySnapshot.get();
      var childQuery = await childQuerySnapshot.get();
      int allDocs = adultQuery.docs.length + childQuery.docs.length;
      // Iterate through both adult and child competition types
      for (var competitionType in ["adult_inscription", "child_inscription"]) {
        // Fetch documents for the given competition version and type
        QuerySnapshot<Map<String, dynamic>> querySnapshot =
            await FirebaseFirestore.instance
                .collection("inscriptions")
                .doc(competitionVersion)
                .collection(competitionType)
                .get();

        for (var doc in querySnapshot.docs) {
          Inscription inscription = Inscription.fromMap(doc.data());

          // Select the appropriate round list
          List<dynamic>? roundList = competitionRound == "التصفيات الأولى"
              ? inscription.tashihMachaikhs?.firstRound
              : inscription.tashihMachaikhs?.finalRound;

          if (roundList != null) {
            // Count the number of corrected elements in the list
            int correctedCount = roundList
                .map((element) => getNoteResult(element, competitionType))
                .where((noteResult) => noteResult.isCorrected ?? false)
                .length;

            // Add to the inscriptions list if all elements are corrected
            if (correctedCount == roundList.length) {
              inscriptions.add(inscription);
            }
          }
        }
      }

      // Check if the number of processed inscriptions matches expectations
      print(
          "======================== \n $allDocs ================ ${inscriptions.length} inscriptions found.");

      if (allDocs == inscriptions.length) {
        for (var doc in adultQuery.docs) {
          Inscription inscr = Inscription.fromDocumentSnapshot(doc);
          // Select the appropriate round list
          List? roundList = competitionRound == "التصفيات الأولى"
              ? inscr.tashihMachaikhs?.firstRound
              : inscr.tashihMachaikhs?.finalRound;
          double roundNote = getResult(roundList!, "adult_inscription");
          double roundMoyenne = roundNote / roundList.length;
          FirebaseFirestore.instance
              .collection("inscriptions")
              .doc(competitionVersion)
              .collection("adult_inscription")
              .doc(doc.id)
              .update({
            "نتائج التصفيات الأولى": roundMoyenne,
          });
        }
        for (var doc in childQuery.docs) {
          Inscription inscr = Inscription.fromDocumentSnapshot(doc);
          // Select the appropriate round list
          List? roundList = competitionRound == "التصفيات الأولى"
              ? inscr.tashihMachaikhs?.firstRound
              : inscr.tashihMachaikhs?.finalRound;
          double roundNote = getResult(roundList!, "child_inscription");
          double roundMoyenne = roundNote / roundList.length;
          FirebaseFirestore.instance
              .collection("inscriptions")
              .doc(competitionVersion)
              .collection("child_inscription")
              .doc(doc.id)
              .update({
            "نتائج التصفيات الأولى": roundMoyenne,
          });
        }
      }

      // Return true if all inscriptions have been added successfully
      return allDocs == inscriptions.length;
    } on FirebaseException catch (e) {
      print("Error fetching inscriptions: ${e.message}");
      return false;
    } catch (e) {
      print("Unexpected error: $e");
      return false;
    }
  }
}
