import 'package:quranic_competition/models/users.dart';

class Admin extends Users {
  final bool? _isSuperAdmin;
  Admin({
    super.fullName,
    required super.phoneNumber,
    required super.password,
    super.userID,
    super.role,
    required super.isVerified,
    bool? isSuperAdmin,
  }) : _isSuperAdmin = isSuperAdmin;

  // Setters
  @override
  set fullName(String? fullName) {
    if (fullName != null && fullName.isNotEmpty) {
      super.fullName = fullName;
    }
  }

  set isSuperAdmin(bool? isSuperAdmin) {
    isSuperAdmin = isSuperAdmin;
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

  // Getters
  bool? get isSuperAdmin => _isSuperAdmin;

  // from map
  static Admin fromMap(Map<String, dynamic> map) {
    return Admin(
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
      userID: map['userID'],
      role: map['role'],
      isVerified: map['isVerified'],
      isSuperAdmin: map['isSuperAdmin'],
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
      'isVerified': isVerified,
      'isSuperAdmin': isSuperAdmin,
    };
  }
}
