import 'package:quranic_competition/models/users.dart';

class Admin extends Users {

  Admin({super.fullName, required super.phoneNumber, required super.password , super.userID , super.role});

  // Setters
  @override
  set fullName(String? fullName) {
    if (fullName!= null && fullName.isNotEmpty) {
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
  static Admin fromMap(Map<String, dynamic> map) {
    return Admin(
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
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'password': password,
      'userID': userID,
      'role': role,
    };
  }

}