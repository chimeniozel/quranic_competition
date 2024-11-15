import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/models/admin.dart';
import 'package:quranic_competition/models/jury.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:quranic_competition/services/competion_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProviders extends ChangeNotifier {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Admin? _currentAdmin;
  Jury? _currentJury;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  List<Jury>? _jurys;
  List<Jury>? get jurys => _jurys;
  Admin? get currentAdmin => _currentAdmin;
  Jury? get currentJury => _currentJury;

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
  Future<void> setCurrentUser(String userID) async {
    Map<String, dynamic>? map = await AuthService.getCurrentUser(userID);
    if (map != null && map["role"] == "إداري") {
      _currentAdmin = map["user"];
      _currentJury = null;
      debugPrint("تم تعيين المشرف الحالي: ${_currentAdmin!.fullName}");
    } else if (map != null && map["role"] == "عضو لجنة التحكيم") {
      _currentJury = map["user"];
      _currentAdmin = null;
      debugPrint("تم تعيين المحكم الحالي: ${_currentJury!.fullName}");
    } else {
      debugPrint("المستخدم غير موجود أو لا يمتلك دور معروف");
    }
    notifyListeners();
  }

  Future<void> getJurys() async {
    _isLoading = true;
    notifyListeners();
    try {
      _jurys = await CompetitionService.getAllJurys();
      notifyListeners();
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }

  static const _userKey = 'user';
  Users? _user;

  Users? get user => _user; // Return the current user (nullable)

  // Call this function to check if the user is logged in and return the user
  Future<void> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);

    if (userJson != null) {
      _user = Users.fromMap(
          jsonDecode(userJson)); // Deserialize JSON into a User object
    } else {
      _user = null; // No user found in SharedPreferences
    }
    notifyListeners(); // Notify listeners to rebuild the widget
  }

  // Save user data when they log in
  Future<void> saveUser(Users user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userJson = jsonEncode(user.toMap()); // Serialize User object to JSON
    await prefs.setString(_userKey, userJson).whenComplete(() {
      print("User saved successfully");
    });
    _user = user;
    notifyListeners();
  }

  // Log out by removing user data
  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await AuthService.logoutUser(context);
    await prefs.remove(_userKey);
    _user = null;
    notifyListeners();
  }
}
