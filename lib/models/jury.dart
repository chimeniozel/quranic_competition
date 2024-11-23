import 'package:quranic_competition/models/users.dart';

class Jury extends Users {
  List<dynamic>? _competitions;

  Jury(
      {required super.phoneNumber,
      required super.password,
      super.fullName,
      super.role,
      super.userID,
      List<dynamic>? competitions, required super.isVerified})
      : _competitions = competitions;

  // Getters
  List<dynamic>? get competitions => _competitions;

  // Setters
  void setcompetitions(List<dynamic>? competitions) {
    _competitions = competitions;
  }

  @override
  set fullName(String? fullName) {
    if (fullName != null && fullName.isNotEmpty) {
      super.fullName = fullName;
    }
  }

  @override
  set phoneNumber(String phoneNumber) {
    if (phoneNumber.length == 11) {
      super.phoneNumber = phoneNumber;
    }
  }

  @override
  set password(String password) {
    if (password.length >= 8) {
      super.password = password;
    }
  }

  @override
  set userID(String? userID) {
    super.userID = userID;
  }

  @override
  set isVerified(bool? role) {
    super.isVerified = role;
  }

  // from map
  static Jury fromMap(Map<String, dynamic> map) {
    return Jury(
      competitions: map['competitions'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
      userID: map['userID'],
      role: map['role'],
      isVerified: map['isVerified'],
    );
  }

  // to map
  @override
  Map<String, dynamic> toMap() {
    return {
      'competitions': _competitions,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'password': password,
      'userID': userID,
      'role': role,
      'isVerified': isVerified,
    };
  }
}
