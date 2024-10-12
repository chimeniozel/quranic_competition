import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/result_model.dart';
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

  static Future<List<ResultModel>> getResults(
      String competitionPhase, String competitionVersion, String query) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection("results")
              .doc(competitionVersion)
              .collection(competitionPhase)
              .orderBy("المعدل العالم", descending: true)
              .get();

      List<ResultModel> results = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> resultData = doc.data();
        ResultModel result = ResultModel.fromMap(resultData);

        if (query != "") {
          if (result.idUser == query) {
            results.add(result);
          }
        } else {
          results.add(result);
        }
      }

      return results;
    } on FirebaseException catch (e) {
      print("Error fetching results: $e");
      return [];
    }
  }
}
