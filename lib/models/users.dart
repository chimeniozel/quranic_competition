import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String _fullName;
  String _phoneNumber;
  String _password;
  String? _role;

  Users({
    required String fullName,
    required String phoneNumber,
    required String password,
    String? role,
  })  : _fullName = fullName,
        _phoneNumber = phoneNumber,
        _role = role,
        _password = password;

  // Getters
  String get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get password => _password;
  String? get role => _role;

  // Setters
  set fullName(String name) {
    _fullName = name;
  }

  set phoneNumber(String phone) {
    _phoneNumber = phone;
  }

  set password(String pass) {
    _password = pass;
  }

  set role(String? role) {
    _role = role;
  }

  // Convert a Users object to a map
  Map<String, dynamic> toMap() {
    return {
      'fullName': _fullName,
      'phoneNumber': _phoneNumber,
      'password': _password,
      'role': _role,
    };
  }

  // Create a Users object from a map
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
      role: map['role'],
    );
  }

  // create a users object from QueryDocumentSnapshot
  factory Users.fromSnapshot(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Users(
      fullName: data['fullName'],
      phoneNumber: data['phoneNumber'],
      password: data['password'],
      role: data['role'],
    );
  }
}
