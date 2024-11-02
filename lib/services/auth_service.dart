import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/auth/login_screen.dart';
import 'package:quranic_competition/auth/register_screen.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/inscription.dart';
import 'package:quranic_competition/models/note_result.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/providers/auth_provider.dart'
    as auth_provider;
import 'package:quranic_competition/services/inscription_service.dart';

class AuthService {
  static FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String? _verificationId;

  static Future<Users> getCurrentUser(String phoneNumber) async {
    var usersRef = firebaseFirestore.collection("users");
    var users = await usersRef.doc(phoneNumber).get();
    return Users.fromMap(users.data()!);
  }

  // Update a Contestant
  static Future<void> updateContestant(
    BuildContext context,
    String fullName,
    NoteResult noteResult,
    Inscription inscription,
    String competitionVersion,
    String competitionType,
    String competitionRound,
  ) async {
    try {
      firebaseFirestore.collection("users");
      var cometitionTypeRef = firebaseFirestore
          .collection("inscriptions")
          .doc(competitionVersion)
          .collection(competitionType)
          .doc(inscription.phoneNumber);

      noteResult.cheikhName = fullName;
      List<Users>? users = auth_provider.AuthProvider().users;
      int userIndex = 0;
      for (var i = 0; i < users!.length; i++) {
        if (users[i].fullName == fullName) {
          userIndex = i;
          break;
        }
      }
      DocumentSnapshot<Map<String, dynamic>> doc =
          await cometitionTypeRef.get();

      List<dynamic> myList = doc['tashihMachaikhs'][competitionRound];
      print("=================\n ${myList[userIndex]}");

      if (competitionType == "adult_inscription") {
        noteResult = NoteResult(
            cheikhName: fullName,
            notes: noteResult.notes!,
            isCorrected: noteResult.isCorrected);
        myList[userIndex] = noteResult.toMapAdult(); // Update the element
        print(
            "===========================================\n ${myList[userIndex]}");
        await cometitionTypeRef.update({
          "tashihMachaikhs.$competitionRound": myList,
        });
      } else {
        noteResult = NoteResult(
            cheikhName: fullName,
            notes: noteResult.notes!,
            isCorrected: noteResult.isCorrected);
        myList[userIndex] = noteResult.toMapChild(); // Update the element
        print(
            "===========================================\n ${myList[userIndex]}");
        await cometitionTypeRef.update({
          "tashihMachaikhs.$competitionRound": myList,
        });
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
      Navigator.pop(context);
    } catch (e) {
      // Snackbar for exception
      final errorSnackBar = SnackBar(
        content: Text('حدث خطأ أثناء حفظ العلامة: $e'),
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
  }

  // check if all constraints have notes and return result and list of constraints

  static Future<Map<String, dynamic>> checkAllNotes(String version,
      String cometionType, String fullName, String competitionRound) async {
    CollectionReference inscriptionCollection = FirebaseFirestore.instance
        .collection('inscriptions')
        .doc(version)
        .collection(cometionType);

    QuerySnapshot querySnapshot = await inscriptionCollection
        .orderBy("رقم التسجيل", descending: false)
        .get();

    List<Inscription> inscriptions = [];
    List<Inscription> notedInscriptions = [];
    List<Map<String, dynamic>> dataList = [];

    // Parse each document into an Inscription object and a map
    for (var doc in querySnapshot.docs) {
      Inscription inscription = Inscription.fromDocumentSnapshot(doc);
      inscriptions.add(inscription);
      if (competitionRound == "التصفيات الأولى") {
        if (cometionType == "adult_inscription") {
          for (var note in inscription.tashihMachaikhs!.firstRound!) {
            NoteResult noteResult = NoteResult.fromMapAdult(note);
            if (noteResult.cheikhName == fullName && noteResult.isCorrected!) {
              dataList.add(noteResult.toMapAdult()!);
              notedInscriptions.add(inscription);
            }
          }
        } else {
          for (var note in inscription.tashihMachaikhs!.firstRound!) {
            NoteResult noteResult = NoteResult.fromMapChild(note);
            if (noteResult.cheikhName == fullName && noteResult.isCorrected!) {
              dataList.add(noteResult.toMapChild()!);
              notedInscriptions.add(inscription);
            }
          }
        }
      } else {
        if (cometionType == "adult_inscription") {
          for (var note in inscription.tashihMachaikhs!.finalRound!) {
            NoteResult noteResult = NoteResult.fromMapAdult(note);
            if (noteResult.cheikhName == fullName && noteResult.isCorrected!) {
              dataList.add(noteResult.toMapAdult()!);
              notedInscriptions.add(inscription);
            }
          }
        } else {
          for (var note in inscription.tashihMachaikhs!.finalRound!) {
            NoteResult noteResult = NoteResult.fromMapChild(note);
            if (noteResult.cheikhName == fullName && noteResult.isCorrected!) {
              dataList.add(noteResult.toMapChild()!);
              notedInscriptions.add(inscription);
            }
          }
        }
      }
    }

    if (inscriptions.length == dataList.length) {
      return {
        "isNoted": true,
        "notedInscriptions": notedInscriptions,
        "dataList": dataList,
      };
    } else {
      return {
        "isNoted": false,
        "notedInscriptions": <Inscription>[],
        "dataList": <Map<String, dynamic>>[],
      };
    }
  }

  Future<void> signInWithPhoneNumber(
      String verificationId, String smsCode) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      // Create a PhoneAuthCredential with the code
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      // Sign in the user with the credential
      UserCredential userCredential =
          await auth.signInWithCredential(credential);
      print("User signed in: ${userCredential.user?.uid}");
    } on FirebaseAuthException catch (e) {
      // Handle errors
      print("Sign in failed: $e");
    }
  }

  static Future<void> registerUser(Users user, BuildContext context) async {
    try {
      await firebaseFirestore
          .collection("users")
          .doc(user.phoneNumber)
          .set(user.toMap());

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
      Users user, BuildContext context) async {
    var usersRef = firebaseFirestore.collection("users");
    bool loggedIn = false;
    Users? existUser;
    var users = await usersRef.doc(user.phoneNumber).get();
    if (users.exists) {
      existUser = Users.fromMap(users.data()!);
      auth_provider.AuthProvider().setCurrentUser(user.phoneNumber);
      loggedIn = true;
    } else {
      loggedIn = false;
    }
    return {
      "loggedIn": loggedIn,
      "currentUser": existUser,
    };
  }

  // Déconnecter l'utilisateur
  static Future<void> logoutUser(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  static void showMessage(String message, BuildContext context) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  static Future<bool> sendVerificationCode({
    required String phoneNumber,
    required BuildContext context,
  }) async {
    final Completer<bool> completer = Completer<bool>();
    final FirebaseAuth _auth = FirebaseAuth.instance;

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: "+222$phoneNumber",
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithCredential(credential);
          showMessage(
              'تم التحقق من رقم الهاتف وتسجيل الدخول تلقائيًا.', context);
          completer.complete(true); // Mark as successful
        },
        verificationFailed: (FirebaseAuthException e) {
          showMessage('فشل التحقق: ${e.message}', context);
          completer.complete(false); // Mark as failed
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          showMessage('تم إرسال رمز التحقق.', context);
          completer.complete(true); // Code was successfully sent
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          completer.complete(false); // Timeout; treat as a failure
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      showMessage('فشل إرسال رمز التحقق: $e', context);
      completer.complete(false); // Exception occurred
    }

    return completer.future; // Await the completion of this future
  }

  // static void showMessage(String message, BuildContext context) {
  //   final snackBar = SnackBar(content: Text(message));
  //   ScaffoldMessenger.of(context).showSnackBar(snackBar);
  // }

  static Future<void> verifyCode(
      {required void Function() function,
      required List<TextEditingController> codeControllers,
      required BuildContext context,
      Users? user,
      Inscription? inscription,
      String? competitionVirsion}) async {
    String code = codeControllers.map((controller) => controller.text).join();
    if (code.length != 4) {
      AuthService.showMessage('يرجى إدخال الرمز الكامل.', context);
      return;
    }

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: code,
      );

      await _auth.signInWithCredential(credential).whenComplete(
        () {
          function();
        },
      );
      AuthService.showMessage('تم التحقق من الرقم بنجاح!', context);
    } catch (e) {
      AuthService.showMessage('فشل التحقق من الرمز: $e', context);
    }
  }
}
