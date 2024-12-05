import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/auth/login_screen.dart';
import 'package:quranic_competition/auth/register_screen.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/admin.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/jury.dart';
import 'package:quranic_competition/models/jurys_inscription.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/providers/auth_provider.dart';
import 'package:quranic_competition/screens/client/home_screen.dart';

class AuthService {
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static AuthProviders authProviders = AuthProviders();

  static Future<Map<String, dynamic>?> getCurrentUser(String userID) async {
    var usersRef = firebaseFirestore.collection("users");
    var users = await usersRef.doc(userID).get();

    // Check if the document exists
    if (!users.exists) {
      print("User document does not exist for userID: $userID");
      return null; // Return null or handle as appropriate for your app
    }

    // Safely access fields after confirming the document exists
    if (users.get("role") == "إداري") {
      return {
        "role": users.data()!["role"],
        "user": Admin.fromMap(users.data()!)
      };
    } else {
      return {
        "role": users.data()!["role"],
        "user": Jury.fromMap(users.data()!)
      };
    }
  }

  static Future<void> addJuryInscriptionNotes(
      {required String competitionId,
      required String competitionRound,
      required JuryInscription juryInscription,
      required bool isAdult,
      required BuildContext context}) async {
    // Reference to the collection where you want to store the JurysInscription
    CollectionReference jurysInscriptionCollection = FirebaseFirestore.instance
        .collection("inscriptions")
        .doc(competitionId)
        .collection('jurysInscriptions');
    try {
      // Generate a unique ID for the document
      juryInscription.idCollection =
          "${juryInscription.idJury}-${juryInscription.idInscription}";
      // Add a new document with data from jurysInscription.toMap()
      if (isAdult) {
        juryInscription.idCollection =
            "${juryInscription.idJury}-${juryInscription.idInscription}-adult";
        if (competitionRound == "التصفيات الأولى") {
          await jurysInscriptionCollection
              .doc(juryInscription.idCollection)
              .set(
                juryInscription.toMapAdult(),
              );
        } else {
          await jurysInscriptionCollection
              .doc(juryInscription.idCollection)
              .update({
            "lastResult": juryInscription.lastNotes!.toMapAdult(),
            "isLastCorrected": true,
          });
        }
      } else {
        juryInscription.idCollection =
            "${juryInscription.idJury}-${juryInscription.idInscription}-child";
        if (competitionRound == "التصفيات الأولى") {
          await jurysInscriptionCollection
              .doc(juryInscription.idCollection)
              .set(
                juryInscription.toMapChild(),
              );
        } else {
          await jurysInscriptionCollection
              .doc(juryInscription.idCollection)
              .update({
            "lastResult": juryInscription.lastNotes!.toMapChild(),
            "isLastCorrected": true,
          });
        }
      }
      // Snackbar for success
      final successSnackBar = SnackBar(
        content: const Text('تم حفظ العلامة بنجاح'),
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
      print("Failed to add JurysInscription: $e");
    }
  }

  // check if all constraints have notes and return result and list of constraints

  static Future<Map<String, dynamic>> checkAllNotes(
      {required String version,
      required String cometionType,
      required String userID,
      required String competitionRound}) async {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(cometionType);

    QuerySnapshot<Map<String, dynamic>> juryInscriptionAdult =
        await FirebaseFirestore.instance
            .collection('inscriptions')
            .doc(version)
            .collection("jurysInscriptions")
            .where("idJury", isEqualTo: userID)
            .where("isAdult", isEqualTo: true)
            .get();
    QuerySnapshot<Map<String, dynamic>> juryInscriptionChild =
        await FirebaseFirestore.instance
            .collection('inscriptions')
            .doc(version)
            .collection("jurysInscriptions")
            .where("idJury", isEqualTo: userID)
            .where("isAdult", isEqualTo: false)
            .get();

    QuerySnapshot querySnapshot;
    if (competitionRound == "التصفيات الأولى") {
      querySnapshot = await inscriptionCollection
          .orderBy("رقم التسجيل", descending: false)
          .get();
    } else {
      querySnapshot = await inscriptionCollection
          .where("isPassedFirstRound", isEqualTo: true)
          .orderBy("رقم التسجيل", descending: false)
          .get();
    }

    List<Inscription> inscriptions = [];
    List<Inscription> notedInscriptions = [];
    List<JuryInscription> dataList = [];

    // Parse each document into an Inscription object and a map
    for (var doc in querySnapshot.docs) {
      Inscription inscription = Inscription.fromDocumentSnapshot(doc);
      inscriptions.add(inscription);
      if (competitionRound == "التصفيات الأولى") {
        if (cometionType == "adult_inscription") {
          for (var juryDoc in juryInscriptionAdult.docs) {
            JuryInscription juryInscription =
                JuryInscription.fromMapAdult(juryDoc.data());

            if (juryInscription.idInscription == inscription.idInscription) {
              dataList.add(juryInscription);
              notedInscriptions.add(inscription);
            }
          }
        } else {
          for (var juryDoc in juryInscriptionChild.docs) {
            JuryInscription juryInscription =
                JuryInscription.fromMapChild(juryDoc.data());
            if (juryInscription.idInscription == inscription.idInscription) {
              dataList.add(juryInscription);
              notedInscriptions.add(inscription);
            }
          }
        }
      } else {
        if (cometionType == "adult_inscription") {
          for (var juryDoc in juryInscriptionAdult.docs) {
            JuryInscription juryInscription =
                JuryInscription.fromMapAdult(juryDoc.data());
            if (juryInscription.idInscription == inscription.idInscription &&
                inscription.isPassedFirstRound!) {
              dataList.add(juryInscription);
              notedInscriptions.add(inscription);
            }
          }
        } else {
          for (var juryDoc in juryInscriptionChild.docs) {
            JuryInscription juryInscription =
                JuryInscription.fromMapChild(juryDoc.data());
            if (juryInscription.idInscription == inscription.idInscription &&
                inscription.isPassedFirstRound!) {
              dataList.add(juryInscription);
              notedInscriptions.add(inscription);
            }
          }
        }
        print(
            "================================= inscriptions.length : ${inscriptions.length} , dataList.length : ${dataList.length} ====================");
      }
    }
    if (inscriptions.length == dataList.length &&
        dataList.isNotEmpty &&
        inscriptions.isNotEmpty) {
      return {
        "isNoted": true,
        "notedInscriptions": notedInscriptions,
        "dataList": dataList,
      };
    } else {
      return {
        "isNoted": false,
        "notedInscriptions": <Inscription>[],
        "dataList": <JuryInscription>[],
      };
    }
  }

  static Future<void> registerUser(
      {Jury? jury, Admin? admin, required BuildContext context}) async {
    try {
      if (jury != null) {
        await firebaseFirestore
            .collection("users")
            .add(jury.toMap())
            .then((val) async {
          await firebaseFirestore.collection("users").doc(val.id).update({
            "userID": val.id,
          });
        });
      } else {
        await firebaseFirestore
            .collection("users")
            .add(admin!.toMap())
            .then((val) async {
          await firebaseFirestore.collection("users").doc(val.id).update({
            "userID": val.id,
          });
        });
      }

      // If the set operation is successful, show the success dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("نجح"),
          content: const Text(
            "تم التسجيل بنجاح",
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                ),
                minimumSize: const Size(
                  double.infinity,
                  40.0,
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "حسنا",
                style: TextStyle(color: AppColors.whiteColor),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      // If there's an error, show the error dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text("خطأ"),
          content: const Text(
            "حصل خطأ أثناء التسجيل ",
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    10.0,
                  ),
                ),
                minimumSize: const Size(
                  double.infinity,
                  40.0,
                ),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const RegisterScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                "حسنا",
                style: TextStyle(color: AppColors.whiteColor),
              ),
            ),
          ],
        ),
      );
    }
  }

  static Future<Map<String, dynamic>> loginUser(
      {required Users user, required BuildContext context}) async {
    QuerySnapshot<Map<String, dynamic>> users;
    bool loggedIn = false;
    Users? existUser;

    var usersRef = firebaseFirestore.collection("users");
    users = await usersRef
        .where("phoneNumber", isEqualTo: user.phoneNumber)
        .where("password", isEqualTo: user.password)
        .where("isVerified", isEqualTo: true)
        .get();
    if (users.docs.isNotEmpty) {
      existUser = Users.fromMap(users.docs.first.data());

      if (existUser.role == "إداري") {
        loggedIn = true;
        Admin admin = Admin.fromMap(users.docs.first.data());
        return {
          "loggedIn": loggedIn,
          "currentUser": admin,
        };
      } else {
        loggedIn = true;
        Jury jury = Jury.fromMap(users.docs.first.data());
        return {
          "loggedIn": loggedIn,
          "currentUser": jury,
        };
      }
    } else {
      loggedIn = false;
      return {
        "loggedIn": loggedIn,
        "currentUser": null,
      };
    }
  }

  // Déconnecter l'utilisateur
  static Future<void> logoutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
      (route) => false,
    );
  }

  static void showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
