import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/about_us_model.dart';
import 'package:quranic_competition/models/admin.dart';
import 'package:quranic_competition/models/archive_entry.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/jury.dart';
import 'package:quranic_competition/models/note_model.dart';
import 'package:quranic_competition/models/result_model.dart';
import 'package:quranic_competition/models/tajweed_post_model.dart';

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

  static Future<double?> getCompetitionSuccessMoyenne(
      String competitionId) async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await competitionCollection.doc(competitionId).get();

      if (documentSnapshot.exists) {
        return documentSnapshot.get("field");
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

  static Future<void> updateVideosURL(BuildContext context,
      Competition competition, List<VideoEntry> videos) async {
    // Update the existing competition document in Firestore
    List<Map<String, dynamic>> videosUrl = [];
    for (var video in videos) {
      videosUrl.add({
        'title': video.title,
        'url': video.url,
      });
    }
    await FirebaseFirestore.instance
        .collection('competitions')
        .doc(competition
            .competitionId) // Reference to the specific competition document
        .update({
      'archiveEntry.videosURL': FieldValue.arrayUnion(videosUrl),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث المسابقة بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  static Future<void> updateVideoURL(BuildContext context,
      Competition competition, VideoEntry video, VideoEntry videoOld) async {
    await FirebaseFirestore.instance
        .collection('competitions')
        .doc(competition
            .competitionId) // Reference to the specific competition document
        .update({
      'archiveEntry.videosURL': FieldValue.arrayRemove([videoOld.toMap()]),
    }).whenComplete(() async {
      await FirebaseFirestore.instance
          .collection('competitions')
          .doc(competition
              .competitionId) // Reference to the specific competition document
          .update({
        'archiveEntry.videosURL': FieldValue.arrayUnion([video.toMap()]),
      });
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديث الفيديو بنجاح'),
        backgroundColor: Colors.green,
      ),
    );
  }

  static Future<AboutUsModel?> getAboutUs() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
          await FirebaseFirestore.instance
              .collection("about_us")
              .doc("k934z1vhO6LgWEFxex81")
              .get();

      if (documentSnapshot.exists) {
        Map<String, dynamic> aboutUsModel = documentSnapshot.data()!;
        return AboutUsModel.fromMap(aboutUsModel);
      } else {
        return null;
      }
    } on FirebaseException catch (e) {
      print("Error fetching about us: $e");
      return null;
    }
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

  static Future<bool> hasActiveCompetition({String? competitionId}) async {
    if (competitionId == null) {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('competitions')
          .where('isActive', isEqualTo: true)
          .get();

      return snapshot.docs.isNotEmpty;
    } else {
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
  }

  static Stream<List<Jury>> getAllJurysStream() {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .where('role', isEqualTo: "عضو لجنة التحكيم")
          .orderBy("isVerified")
          .snapshots()
          .map((querySnapshot) {
        // Transform the query snapshot into a list of Jury objects
        return querySnapshot.docs.map((doc) {
          Map<String, dynamic> userData = doc.data();
          return Jury.fromMap(userData);
        }).toList();
      });
    } catch (e) {
      print("Error fetching jury users stream: $e");
      return const Stream.empty();
    }
  }

  static Stream<List<Admin>> getAllAdminsStream(String currentUserID) {
    try {
      return FirebaseFirestore.instance
          .collection("users")
          .where('role', isEqualTo: "إداري")
          .orderBy("isVerified")
          .where("userID", isNotEqualTo: currentUserID)
          .snapshots()
          .map((querySnapshot) {
        // Transform the query snapshot into a list of Jury objects
        return querySnapshot.docs.map((doc) {
          Map<String, dynamic> userData = doc.data();
          return Admin.fromMap(userData);
        }).toList();
      });
    } catch (e) {
      print("Error fetching admin users stream: $e");
      return const Stream.empty();
    }
  }

  static Future<List<Jury>> getAllJurys() async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .where('role', isEqualTo: "عضو لجنة التحكيم")
              .orderBy("isVerified")
              .get();

      List<Jury> juryUsers = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> userData = doc.data();
        Jury user = Jury.fromMap(userData);
        juryUsers.add(user);
      }

      return juryUsers;
    } on FirebaseException catch (e) {
      print("Error fetching jury users: $e");
      return [];
    }
  }

  static Future<List<Jury>> getCompetitionJurys(
      String competitionVersion) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection("users")
              .where('competitions', arrayContains: competitionVersion)
              .get();

      List<Jury> juryUsers = [];
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> userData = doc.data();
        Jury user = Jury.fromMap(userData);
        juryUsers.add(user);
      }

      return juryUsers;
    } on FirebaseException catch (e) {
      print("Error fetching jury users: $e");
      return [];
    }
  }

  static Future<void> deleteUser({required String userID}) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(userID).delete();
    } on FirebaseException catch (e) {
      print("Error deleting user: $e");
    }
  }

  static Future<void> deleteJuryFromCometition(
      {required String juryID, required String competitionVersion}) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(juryID).update({
        'competitions': FieldValue.arrayRemove([competitionVersion]),
      });
    } on FirebaseException catch (e) {
      print("Error deleting jury from competition: $e");
    }
  }

  static Future<void> verifyUser({required String userID}) async {
    try {
      await FirebaseFirestore.instance.collection("users").doc(userID).update({
        'isVerified': true,
      });
    } on FirebaseException catch (e) {
      print("Error verifying user: $e");
    }
  }

  // get images archives as a stream
  static Future<List<String>> getImagesArchives(String competitionId) async {
    try {
      // Fetch the document once using 'get()' instead of 'snapshots()'
      DocumentSnapshot<Map<String, dynamic>> snapshot = await FirebaseFirestore
          .instance
          .collection("competitions")
          .doc(competitionId)
          .get();

      List<String> archives = [];
      if (snapshot.exists) {
        // Parse the competition data from the snapshot
        Competition competition = Competition.fromMap(snapshot.data()!);

        // Retrieve the images URL if available
        List<String>? imagesURL = competition.archiveEntry?.imagesURL;

        // Add the images URLs to the archives list
        if (imagesURL != null) {
          archives.addAll(imagesURL);
        }
      }
      return archives;
    } catch (error) {
      print("Error fetching archives: $error");
      return [];
    }
  }

  // get videos archives as a stream
  static Stream<List<VideoEntry>> getVideosArchivesStream(
      String competitionId) {
    return FirebaseFirestore.instance
        .collection("competitions")
        .doc(competitionId)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        try {
          // Parse the competition data from the snapshot
          Competition competition = Competition.fromMap(snapshot.data()!);

          // Retrieve the videos URL if available
          List<VideoEntry>? videosURL = competition.archiveEntry?.videosURL;

          // Return the list of video entries or an empty list
          return videosURL ?? <VideoEntry>[];
        } catch (error) {
          print("Error parsing competition data: $error");
          return <VideoEntry>[];
        }
      } else {
        return <VideoEntry>[];
      }
    }).handleError((error) {
      print("Error fetching archives stream: $error");
    });
  }

  static Future<List<Map<String, dynamic>>> getResults({
    required String version,
    required String competitionType,
    required String competitionRound,
    required bool isAdmin,
    required String query,
    required Competition competition,
  }) async {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(competitionType);
    var conpetitionDoc = await FirebaseFirestore.instance
        .collection("competitions")
        .doc(competition.competitionId)
        .get();
    QuerySnapshot<Map<String, dynamic>> juryCollection = await FirebaseFirestore
        .instance
        .collection('users')
        .where("competitions", arrayContains: version)
        .get();
    QuerySnapshot? querySnapshot;
    List<Map<String, dynamic>> inscriptions = [];

    if (competitionRound == "التصفيات الأولى") {
      if (query.isNotEmpty) {
        // البحث عن idUser باستخدام query
        querySnapshot = await inscriptionCollection
            .where("رقم التسجيل", isEqualTo: int.parse(query))
            .orderBy("رقم التسجيل", descending: false)
            .get();
      } else {
        // إذا لم يكن هناك قيمة للبحث، عرض جميع الوثائق
        querySnapshot = await inscriptionCollection
            .orderBy("رقم التسجيل", descending: false)
            .get();
      }

      for (var doc in querySnapshot.docs) {
        List<double> notes = [];
        Inscription inscription = Inscription.fromDocumentSnapshot(doc);
        var correctionSnapshot = await FirebaseFirestore.instance
            .collection('inscriptions')
            .doc(version)
            .collection("jurysInscriptions")
            .where("idInscription", isEqualTo: inscription.idInscription)
            .get();

        for (var correctionDoc in correctionSnapshot.docs) {
          if (competitionType == "adult_inscription") {
            if (correctionDoc["isAdult"]) {
              NoteModel model =
                  NoteModel.fromMapAdult(correctionDoc["firstResult"]);
              notes.add(model.result!);
            }
          } else {
            if (!correctionDoc["isAdult"]) {
              NoteModel model =
                  NoteModel.fromMapChild(correctionDoc["firstResult"]);
              notes.add(model.result!);
            }
          }
        }
        if (juryCollection.docs.length == notes.length) {
          double generalMoyenne = notes.reduce((double a, double b) => a + b) /
              juryCollection.docs.length;

          ResultModel resultModel = ResultModel(
              fullName: inscription.fullName,
              generalMoyenne: generalMoyenne,
              idUser: inscription.idInscription);

          if (isAdmin) {
            if (competitionType == "adult_inscription") {
              inscriptionCollection
                  .doc(inscription.idInscription.toString())
                  .update({
                "نتائج التصفيات الأولى": generalMoyenne,
                "isPassedFirstRound":
                    generalMoyenne >= competition.successMoyenneAdult!
                        ? true
                        : false,
              });
              inscription.resultFirstRound = generalMoyenne;
              inscription.isPassedFirstRound =
                  generalMoyenne >= competition.successMoyenneAdult!
                      ? true
                      : false;
            } else {
              inscriptionCollection
                  .doc(inscription.idInscription.toString())
                  .update({
                "نتائج التصفيات الأولى": generalMoyenne,
                "isPassedFirstRound":
                    generalMoyenne >= competition.successMoyenneChild!
                        ? true
                        : false,
              });
              inscription.resultFirstRound = generalMoyenne;
              inscription.isPassedFirstRound =
                  generalMoyenne >= competition.successMoyenneChild!
                      ? true
                      : false;
            }
            inscriptions.add({
              "inscription": inscription,
              "result": resultModel,
            });
          } else {
            if (conpetitionDoc.get("firstRoundIsPublished") == true) {
              inscriptions.add({
                "inscription": inscription,
                "result": resultModel,
              });
            }
          }
        }
      }
    } else {
      if (query.isNotEmpty) {
        // البحث عن idUser باستخدام query
        querySnapshot = await inscriptionCollection
            .where("isPassedFirstRound", isEqualTo: true)
            .where("رقم التسجيل", isEqualTo: int.parse(query))
            .orderBy("رقم التسجيل", descending: false)
            .get();
      } else {
        // إذا لم يكن هناك قيمة للبحث، عرض جميع الوثائق
        querySnapshot = await inscriptionCollection
            .where("isPassedFirstRound", isEqualTo: true)
            .orderBy("رقم التسجيل", descending: false)
            .get();
      }

      for (var doc in querySnapshot.docs) {
        List<double> notes = [];
        Inscription inscription = Inscription.fromDocumentSnapshot(doc);

        var correctionSnapshot = await FirebaseFirestore.instance
            .collection('inscriptions')
            .doc(version)
            .collection("jurysInscriptions")
            .where("idInscription", isEqualTo: inscription.idInscription)
            .get();

        for (var correctionDoc in correctionSnapshot.docs) {
          if (competitionType == "adult_inscription") {
            if (correctionDoc["isAdult"]) {
              NoteModel model =
                  NoteModel.fromMapAdult(correctionDoc["lastResult"]);
              notes.add(model.result!);
            }
          } else {
            if (!correctionDoc["isAdult"]) {
              NoteModel model =
                  NoteModel.fromMapChild(correctionDoc["lastResult"]);
              notes.add(model.result!);
            }
          }
        }

        if (juryCollection.docs.length == notes.length) {
          double generalMoyenne = notes.reduce((double a, double b) => a + b) /
              juryCollection.docs.length;

          ResultModel resultModel = ResultModel(
              fullName: inscription.fullName,
              generalMoyenne: generalMoyenne,
              idUser: inscription.idInscription);

          if (isAdmin) {
            inscriptionCollection
                .doc(inscription.idInscription.toString())
                .update({
              "نتائج التصفيات النهائية": generalMoyenne,
            });
            inscription.resultLastRound = generalMoyenne;

            inscriptions.add({
              "inscription": inscription,
              "result": resultModel,
            });
          } else {
            if (conpetitionDoc.get("lastRoundIsPublished") == true) {
              inscriptions.add({
                "inscription": inscription,
                "result": resultModel,
              });
            }
          }
        }
      }
    }

    if (inscriptions.length == querySnapshot.docs.length) {
      inscriptions.sort((a, b) {
        double moyenneA = (a['result'] as ResultModel).generalMoyenne!;
        double moyenneB = (b['result'] as ResultModel).generalMoyenne!;
        return moyenneB.compareTo(moyenneA); // Sorts in descending order
      });
      return inscriptions;
    }
    return [];
  }

  static void addJuryToCompetition(
      {required Jury jury,
      required String comptetitionVersion,
      required BuildContext context}) async {
    // Get the list of all users who have comped in the specified competition version

    var doc = await FirebaseFirestore.instance
        .collection("users")
        .doc(jury.userID)
        .get();
    // List list = doc.get("competitions") as List<dynamic>;
    if (doc.get("competitions").contains(comptetitionVersion)) {
      // User already comped in the specified competition version
      final failureSnackBar = SnackBar(
        content:
            Text("الشيخ ${jury.fullName} موجود مسبقا في لجنة هذه المسابقة !"),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {},
        ),
        backgroundColor: AppColors.yellowColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(failureSnackBar);
    } else {
      await FirebaseFirestore.instance
          .collection("users")
          .doc(jury.userID)
          .update({
        "competitions": FieldValue.arrayUnion([comptetitionVersion]),
      });
      final snackBar = SnackBar(
        content:
            Text("تمت إضافة الشيخ ${jury.fullName} إلى لجنة هذه المسابقة !"),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {},
        ),
        backgroundColor: AppColors.greenColor,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
    // Iterate through the users and add the jury to their inscriptions
  }

  // Publish results
  static Future publishResults({
    required Competition competition,
    required String competitionRound,
    required BuildContext context,
  }) async {
    QuerySnapshot<Map<String, dynamic>> juryInscriptionsFirst =
        await FirebaseFirestore.instance
            .collection("inscriptions")
            .doc(competition.competitionVirsion)
            .collection("jurysInscriptions")
            .where("isFirstCorrected", isEqualTo: true)
            .get();
    QuerySnapshot<Map<String, dynamic>> juryInscriptionsLast =
        await FirebaseFirestore.instance
            .collection("inscriptions")
            .doc(competition.competitionVirsion)
            .collection("jurysInscriptions")
            .where("isLastCorrected", isEqualTo: true)
            .get();
    QuerySnapshot<Map<String, dynamic>> inscriptionsAdultFirst =
        await FirebaseFirestore.instance
            .collection("inscriptions")
            .doc(competition.competitionVirsion)
            .collection("adult_inscription")
            .get();
    QuerySnapshot<Map<String, dynamic>> inscriptionsChildFirst =
        await FirebaseFirestore.instance
            .collection("inscriptions")
            .doc(competition.competitionVirsion)
            .collection("child_inscription")
            .get();
    QuerySnapshot<Map<String, dynamic>> inscriptionsAdultLast =
        await FirebaseFirestore.instance
            .collection("inscriptions")
            .doc(competition.competitionVirsion)
            .collection("adult_inscription")
            .where("isPassedFirstRound", isEqualTo: true)
            .get();
    QuerySnapshot<Map<String, dynamic>> inscriptionsChildLast =
        await FirebaseFirestore.instance
            .collection("inscriptions")
            .doc(competition.competitionVirsion)
            .collection("child_inscription")
            .where("isPassedFirstRound", isEqualTo: true)
            .get();
    QuerySnapshot<Map<String, dynamic>> usersQuery = await FirebaseFirestore
        .instance
        .collection("users")
        .where("role", isNotEqualTo: "إداري")
        .where("competitions", arrayContains: competition.competitionVirsion)
        .get();
    int nbInscriptionsFirst =
        inscriptionsAdultFirst.docs.length + inscriptionsChildFirst.docs.length;
    int nbInscriptionsLast =
        inscriptionsAdultLast.docs.length + inscriptionsChildLast.docs.length;
    int nbJurys = 0;

    if (competitionRound == "التصفيات الأولى") {
      nbJurys = juryInscriptionsFirst.docs.length ~/ nbInscriptionsFirst;
    } else {
      nbJurys = juryInscriptionsLast.docs.length ~/ nbInscriptionsLast;
    }

    if (nbJurys == usersQuery.docs.length) {
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

  static Stream<List<VideoEntry>> getTajweedVideoEntries() {
    return FirebaseFirestore.instance
        .collection("ahkam_tajweed_videos")
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => VideoEntry.fromMap(doc.data()))
              .toList(),
        );
  }

  static Stream<List<TajweedPostModel>> getTajweedPost() {
    return FirebaseFirestore.instance
        .collection("tajweed_post")
        .orderBy(
          "createdAt",
          descending: true,
        )
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => TajweedPostModel.fromMap(doc.data()))
              .toList(),
        );
  }

  static Future<void> addTajweedPost(
      TajweedPostModel model, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("tajweed_post")
        .add(model.toMap())
        .then(
      (DocumentReference docRef) async {
        await FirebaseFirestore.instance
            .collection("tajweed_post")
            .doc(docRef.id)
            .update({
          "id": docRef.id,
        }).whenComplete(
          () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'تمت إضافة المنشور بنجاح .',
                ),
                backgroundColor: AppColors.greenColor,
              ),
            );
          },
        );
      },
    );
  }

  static Future<void> updateTajweedPost(
      TajweedPostModel model, BuildContext context) async {
    await FirebaseFirestore.instance
        .collection("tajweed_post")
        .doc(model.id)
        .update(model.toMap())
        .whenComplete(
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تمت تعديل المنشور بنجاح .',
            ),
            backgroundColor: AppColors.greenColor,
          ),
        );
      },
    );
  }
}
