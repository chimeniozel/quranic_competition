import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/providers/competion_provider.dart';

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

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('تم تحديث المسابقة بنجاح'),
    //     backgroundColor: Colors.green,
    //   ),
    // );
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

    // ScaffoldMessenger.of(context).showSnackBar(
    //   const SnackBar(
    //     content: Text('تم تحديث المسابقة بنجاح'),
    //     backgroundColor: Colors.green,
    //   ),
    // );
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

  static Future<void> deleteUser(
      {required Users user, required BuildContext context}) async {
    try {
      Competition? competition =
          Provider.of<CompetitionProvider>(context, listen: false).competition;
      await FirebaseFirestore.instance
          .collection("users")
          .doc(user.phoneNumber)
          .delete()
          .whenComplete(() async {
        if (competition != null) {
          QuerySnapshot<Map<String, dynamic>> querySnapshotComp =
              await FirebaseFirestore.instance.collection("inscriptions").get();
          for (var queryComp in querySnapshotComp.docs) {
            if (queryComp.id == competition.competitionVirsion) {
              QuerySnapshot<Map<String, dynamic>> querySnapshotAdults =
                  await FirebaseFirestore.instance
                      .collection("inscriptions")
                      .doc(competition.competitionVirsion)
                      .collection("adult_inscription")
                      .get();
              for (var queryAdult in querySnapshotAdults.docs) {
                Inscription inscription =
                    Inscription.fromMap(queryAdult.data());
                List? firstRound = inscription.tashihMachaikhs!.firstRound;
                List? finalRound = inscription.tashihMachaikhs!.finalRound;
                NoteResult? firstRoundNote;
                NoteResult? finalRoundNote;
                for (var element in firstRound!) {
                  firstRoundNote = NoteResult.fromMapAdult(element);
                  if (firstRoundNote.cheikhName == user.fullName) {
                    firstRound.remove(element);
                  }
                }

                for (var element in finalRound!) {
                  finalRoundNote = NoteResult.fromMapAdult(element);
                  if (finalRoundNote.cheikhName == user.fullName) {
                    finalRound.remove(element);
                  }
                }
                await FirebaseFirestore.instance
                    .collection("inscriptions")
                    .doc(competition.competitionVirsion)
                    .collection("adult_inscription")
                    .doc(queryAdult.id)
                    .update({
                  "tashihMachaikhs.التصفيات_الأولى": firstRound,
                });
                await FirebaseFirestore.instance
                    .collection("inscriptions")
                    .doc(competition.competitionVirsion)
                    .collection("adult_inscription")
                    .doc(queryAdult.id)
                    .update({
                  "tashihMachaikhs.التصفيات_النهائية": finalRound,
                });
              }

              // QuerySnapshot<Map<String, dynamic>> querySnapshotChilds =
              //     await FirebaseFirestore.instance
              //         .collection("inscriptions")
              //         .doc(competition.competitionVirsion)
              //         .collection("child_inscription")
              //         .get();
            }
          }
        }
      });
    } on FirebaseException catch (e) {
      print("Error deleting user: $e");
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
  required Competition competition,
  required bool isAdmin,
  required String competitionRound,
  required bool isPassedFirstRound,
  required String competitionType,
  required String query,
}) async {
  try {
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    DocumentSnapshot<Map<String, dynamic>> competitionDoc = await FirebaseFirestore.instance
        .collection("competitions")
        .doc(competition.competitionId)
        .get();

    // Determine which round to fetch based on the first or last round
    String orderByField = isPassedFirstRound ? "نتائج التصفيات النهائية" : "نتائج التصفيات الأولى";
    bool isRoundPublished = isPassedFirstRound
        ? competitionDoc.get("lastRoundIsPublished") == true
        : competitionDoc.get("firstRoundIsPublished") == true;

    // Only proceed if the competition round is published or user is an admin
    if (isRoundPublished || isAdmin) {
      querySnapshot = await FirebaseFirestore.instance
          .collection("inscriptions")
          .doc(competition.competitionVirsion)
          .collection(competitionType)
          .where("isPassedFirstRound", isEqualTo: isPassedFirstRound)
          .orderBy(orderByField, descending: true)
          .get();
    } else {
      return [];
    }

    List<Inscription> inscriptions = [];
    for (var doc in querySnapshot.docs) {
      Map<String, dynamic> resultData = doc.data();
      Inscription result = Inscription.fromMap(resultData);

      // Select the appropriate round list
      List<dynamic>? roundList = isPassedFirstRound
          ? result.tashihMachaikhs?.finalRound
          : result.tashihMachaikhs?.firstRound;
      
      // Check if all results in the round list are corrected
      int correctedCount = 0;
      for (var element in (roundList ?? [])) {
        try {
          NoteResult noteResult = competitionType == "adult_inscription"
              ? NoteResult.fromMapAdult(element)
              : NoteResult.fromMapChild(element);

          if (noteResult.isCorrected == true) correctedCount++;
        } catch (e) {
          print("Error parsing NoteResult: $e");
        }
      }

      // Add to inscriptions if all items in the round list are corrected
      if (correctedCount == (roundList?.length ?? 0)) {
        if (query.isNotEmpty) {
          // Check if query matches the inscription ID
          if (double.tryParse(query) == result.idInscription) inscriptions.add(result);
        } else {
          inscriptions.add(result);
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

  static Future<bool> calculeResults(
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
              .update(
            {
              "نتائج التصفيات الأولى": roundMoyenne,
            },
          );
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

  // Publish results
  static Future publishResults(
      {required Competition competition,
      required String competitionRound,
      required BuildContext context}) async {
    bool isCalculated =
        await calculeResults(competition.competitionVirsion!, competitionRound);
    if (isCalculated) {
      DocumentReference<Map<String, dynamic>> querySnapshot = FirebaseFirestore
          .instance
          .collection("competitions")
          .doc(competition.competitionId);

      if (competitionRound == "التصفيات الأولى") {
        await querySnapshot.update({
          "firstRoundIsPublished": true,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم نشر النتائج التصفيات الأولية بنجاح.',
            ),
            backgroundColor: AppColors.greenColor,
          ),
        );
      } else {
        await querySnapshot.update({
          "lastRoundIsPublished": true,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم نشر النتائج التصفيات النهائية بنجاح.',
            ),
            backgroundColor: AppColors.greenColor,
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لم تنتهي لجنة التحكيم من التصحيح',
          ),
          backgroundColor: AppColors.yellowColor,
        ),
      );
    }
  }
}
// CollectionReference<Map<String, dynamic>> childQuerySnapshot =
      //     FirebaseFirestore.instance
      //         .collection("inscriptions")
      //         .doc(competitionVersion)
      //         .collection("child_inscription");
      // var adultQuery = await adultQuerySnapshot.get();
      // var childQuery = await childQuerySnapshot.get();
      // for (var doc in adultQuery.docs) {
      //   if (competitionRound == "التصفيات الأولى") {
      //     await adultQuerySnapshot.doc(doc.id).update({
      //       "firstRoundIsPublished": true,
      //     });
      //   }
      // if (competitionRound != "التصفيات الأولى" &&
      //     doc.get("isPassedFirstRound") == true) {
      //   await adultQuerySnapshot.doc(doc.id).update({
      //     "lastRoundIsPublished": true,
      //   });
      // }
      // }
      // for (var doc in childQuery.docs) {
      //   if (competitionRound == "التصفيات الأولى") {
      //     await childQuerySnapshot.doc(doc.id).update({
      //       "firstRoundIsPublished": true,
      //     });
      //   }
      //   if (competitionRound != "التصفيات الأولى" &&
      //       doc.get("isPassedFirstRound") == true) {
      //     await childQuerySnapshot.doc(doc.id).update({
      //       "lastRoundIsPublished": true,
      //     });
      //   }
      // }