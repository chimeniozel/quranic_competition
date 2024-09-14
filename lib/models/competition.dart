import 'package:cloud_firestore/cloud_firestore.dart';

class Competition {
  String? _competitionVirsion;
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _isActive;
  List? _competitionTypes;
  Competition({
    String? competitionVirsion,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List? competitionTypes,
  })  : _competitionVirsion = competitionVirsion,
        _startDate = startDate,
        _endDate = endDate,
        _isActive = isActive,
        _competitionTypes = competitionTypes;

  String? get competitionVirsion => _competitionVirsion;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool? get isActive => _isActive;
  List? get competitionTypes => _competitionTypes;

  set setCompetitionVirsion(String competitionVirsion) {
    _competitionVirsion = competitionVirsion;
  }

  set setStartDate(DateTime startDate) {
    _startDate = startDate;
  }

  set setEndDate(DateTime endDate) {
    _endDate = endDate;
  }

  set setActive(bool isActive) {
    _isActive = isActive;
  }

  set setCompetitionType(List<String> competitionTypes) {
    _competitionTypes = competitionTypes;
  }

// to Map
  Map<String, dynamic> toMap() {
    return {
      'competitionVirsion': competitionVirsion,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'competitionTypes': competitionTypes,
    };
  }

  // from Map
  Competition.fromMap(Map<String, dynamic> map) {
    _competitionVirsion = map['competitionVirsion'];
    _startDate = (map['startDate'] as Timestamp?)?.toDate();
    _endDate = (map['endDate'] as Timestamp?)?.toDate();
    _isActive = map['isActive'];
    _competitionTypes = map['competitionTypes'];
  }
}
