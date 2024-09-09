import 'package:cloud_firestore/cloud_firestore.dart';

class Competion {
  String? _competionVirsion;
  DateTime? _competionDate;
  Competion({
    String? competionVirsion,
    DateTime? competionDate,
  })  : _competionVirsion = competionVirsion,
        _competionDate = competionDate;

  String? get competionVirsion => _competionVirsion;
  DateTime? get competionDate => _competionDate;

  set setCompetionVirsion(String competionVirsion) {
    _competionVirsion = competionVirsion;
  }

  set setCompetionDate(DateTime competionDate) {
    _competionDate = competionDate;
  }

// to Map
  Map<String, dynamic> toMap() {
    return {
      'competionVirsion': competionVirsion,
      'competionDate': competionDate?.toUtc().toString(),
    };
  }

  // from Map
  Competion.fromMap(Map<String, dynamic> map) {
    _competionVirsion = map['competionVirsion'];
    _competionDate = map['competionDate'];
  }

  
}
