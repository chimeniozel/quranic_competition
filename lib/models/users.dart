import 'package:cloud_firestore/cloud_firestore.dart';

class Users {
  String? _userID;
  String? _fullName;
  String _phoneNumber;
  String _password;
  String? _role;
  bool? _isVerified;

  Users({
    String? userID,
    String? fullName,
    required String phoneNumber,
    required String password,
    String? role,
    bool? isVerified ,
  })  : _userID = userID,
        _fullName = fullName,
        _phoneNumber = phoneNumber,
        _role = role,
        _password = password,
  _isVerified = isVerified;

  // Getters
  String? get userID => _userID;
  String? get fullName => _fullName;
  String get phoneNumber => _phoneNumber;
  String get password => _password;
  String? get role => _role;
  bool? get isVerified => _isVerified;

  // Setters
  set userID(String? id) {
    _userID = id;
  }

  set fullName(String? name) {
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

  set isVerified(bool? isVerified) {
    _isVerified = isVerified;
  }

  // Convert a Users object to a map
  Map<String, dynamic> toMap() {
    return {
      'userID': _userID,
      'fullName': _fullName,
      'phoneNumber': _phoneNumber,
      'password': _password,
      'role': _role,
      'isVerified': _isVerified,
    };
  }

  // Create a Users object from a map
  factory Users.fromMap(Map<String, dynamic> map) {
    return Users(
      userID: map['userID'],
      fullName: map['fullName'],
      phoneNumber: map['phoneNumber'],
      password: map['password'],
      role: map['role'],
      isVerified: map['isVerified'],
    );
  }

  // create a users object from QueryDocumentSnapshot
  factory Users.fromSnapshot(QueryDocumentSnapshot snapshot) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return Users(
      userID: snapshot.id,
      fullName: data['fullName'],
      phoneNumber: data['phoneNumber'],
      password: data['password'],
      role: data['role'],
      isVerified: data['isVerified'],
    );
  }
}
