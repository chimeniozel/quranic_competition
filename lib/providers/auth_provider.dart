import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/models/admin.dart';
import 'package:quranic_competition/models/jury.dart';
import 'package:quranic_competition/models/users.dart';
import 'package:quranic_competition/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthProviders extends ChangeNotifier {
  FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  Admin? _currentAdmin;
  Jury? _currentJury;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  // List<Jury>? _jurys;
  // List<Jury>? get jurys => _jurys;
  Admin? get currentAdmin => _currentAdmin;
  Jury? get currentJury => _currentJury;
  static const _userKey = 'user';
  Users? _user;

  Users? get user => _user; // Return the current user (nullable)
// get users information
  Future<void> setCurrentUser(String userID) async {
    Map<String, dynamic>? map = await AuthService.getCurrentUser(userID);
    if (map != null && map["role"] == "إداري") {
      _currentAdmin = map["user"];
      _currentJury = null;
    } else if (map != null && map["role"] == "عضو لجنة التحكيم") {
      _currentJury = map["user"];
      _currentAdmin = null;
      debugPrint("تم تعيين المحكم الحالي: ${_currentJury!.fullName}");
    } else {
      _currentAdmin = null;
      _currentJury = null;
      debugPrint("المستخدم غير موجود أو لا يمتلك دور معروف");
    }
    notifyListeners();
  }

  // Call this function to check if the user is logged in and return the user
  Future<void> getUser() async {
    _isLoading = true;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userJson = prefs.getString(_userKey);

    if (userJson != null) {
      _user = Users.fromMap(
          jsonDecode(userJson)); // Deserialize JSON into a User object
    } else {
      _user = null; // No user found in SharedPreferences
    }
    _isLoading = false;
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
    _currentAdmin = null;
    _currentJury = null;
    _user = null;
    notifyListeners();
  }
}
