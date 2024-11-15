import 'package:quranic_competition/models/users.dart';

class Jury extends Users {
  // bool? _isFinishedCorrecting;
  List<dynamic>? _competitions;

  Jury(
      {required super.phoneNumber,
      required super.password,
      super.fullName,
      super.role,
      super.userID,
      List<dynamic>? competitions})
      : _competitions = competitions;

  // Getters
  // bool? get isFinishedCorrecting => _isFinishedCorrecting;
  List<dynamic>? get competitions => _competitions;

  // Setters
  // void setIsFinishedCorrecting(bool? isFinishedCorrecting) {
  //   _isFinishedCorrecting = isFinishedCorrecting;
  // }
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

  // from map
  static Jury fromMap(Map<String, dynamic> map) {
    return Jury(
      // isFinishedCorrecting: map['isFinishedCorrecting'],
      competitions: map['competitions'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
      userID: map['userID'],
      role: map['role'],
    );
  }

  // to map
  @override
  Map<String, dynamic> toMap() {
    return {
      // 'isFinishedCorrecting': isFinishedCorrecting,
      'competitions': _competitions,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'password': password,
      'userID': userID,
      'role': role,
    };
  }
}
