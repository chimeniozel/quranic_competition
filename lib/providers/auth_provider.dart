import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/screens/home_screen.dart';
import 'package:quranic_competition/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Users? _currentUser;
  Users? get currentUser => _currentUser;

  Future<void> verifyPhoneNumber(String phoneNumber) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await auth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // Auto-retrieve or instant verification
        await auth.signInWithCredential(credential);
        print("User signed in: ${auth.currentUser?.uid}");
      },
      verificationFailed: (FirebaseAuthException e) {
        // Handle errors
        print("Verification failed: $e");
      },
      codeSent: (String verificationId, int? resendToken) {
        // Save the verification ID so you can use it later
        print("Code sent. Verification ID: $verificationId");
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        // Auto-resolution timed out...
        print("Auto retrieval timeout. Verification ID: $verificationId");
      },
    );
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

  Future<void> registerUser(Users user, BuildContext context) async {
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
                Navigator.pop(context);
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
                Navigator.pop(context);
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

  Future<Map<String, dynamic>> loginUser(
      Users user, BuildContext context) async {
    var usersRef = firebaseFirestore.collection("users");
    bool loggedIn = false;
    Users? existUser;
    var users = await usersRef.doc(user.phoneNumber).get();
    if (users.exists) {
      // Navigate to the home screen
      existUser = Users.fromMap(users.data()!);
      setCurrentUser(user.phoneNumber);
      loggedIn = true;
    } else {
      loggedIn = false;
    }
    return {
      "loggedIn": loggedIn,
      "currentUser": existUser,
    };
  }

  // get users information
  Future<void> setCurrentUser(String phoneNumber) async {
    _currentUser = await AuthService.getCurrentUser(phoneNumber);
    notifyListeners();
  }
}
