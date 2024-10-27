import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quranic_competition/models/archive_entry.dart';

class Competition {
  String? _competitionId;
  String? _competitionVirsion;
  DateTime? _startDate;
  DateTime? _endDate;
  bool? _isActive;
  List? _competitionTypes;
  ArchiveEntry? _archiveEntry;
  Competition({
    String? competitionId,
    String? competitionVirsion,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    List? competitionTypes,
    ArchiveEntry? archiveEntry,
  })  : _competitionId = competitionId,
        _competitionVirsion = competitionVirsion,
        _startDate = startDate,
        _endDate = endDate,
        _isActive = isActive,
        _competitionTypes = competitionTypes,
        _archiveEntry = archiveEntry;

  String? get competitionId => _competitionId;
  String? get competitionVirsion => _competitionVirsion;
  DateTime? get startDate => _startDate;
  DateTime? get endDate => _endDate;
  bool? get isActive => _isActive;
  List? get competitionTypes => _competitionTypes;
  ArchiveEntry? get archiveEntry => _archiveEntry;

  set setCompetitionId(String competitionId) {
    _competitionId = competitionId;
  }

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

  set setArchiveEntry(ArchiveEntry archiveEntry) {
    _archiveEntry = archiveEntry;
  }

// to Map
  Map<String, dynamic> toMap() {
    return {
      'competitionId': competitionId,
      'competitionVirsion': competitionVirsion,
      'startDate': startDate,
      'endDate': endDate,
      'isActive': isActive,
      'competitionTypes': competitionTypes,
      'archiveEntry': archiveEntry?.toMap(),
    };
  }

  // from Map
  Competition.fromMap(Map<String, dynamic>? map) {
    _competitionId = map?['competitionId'];
    _competitionVirsion = map?['competitionVirsion'];
    _startDate = (map?['startDate'] as Timestamp?)?.toDate();
    _endDate = (map?['endDate'] as Timestamp?)?.toDate();
    _isActive = map?['isActive'];
    _competitionTypes = map?['competitionTypes'];
    _archiveEntry = ArchiveEntry.fromMap(map?['archiveEntry']);
  }
}
