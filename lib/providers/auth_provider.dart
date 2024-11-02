import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/auth/login_screen.dart';
import 'package:quranic_competition/constants/colors.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/services/competion_service.dart';

class AuthProvider extends ChangeNotifier {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Users? _currentUser;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Users>? _users;
  List<Users>? get users => _users;
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


// get users information
  Future<void> setCurrentUser(String phoneNumber) async {
    _currentUser = await AuthService.getCurrentUser(phoneNumber);
    notifyListeners();
  }
  Future<void> getUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await CompetitionService.getJuryUsers();
      notifyListeners();
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }
}
