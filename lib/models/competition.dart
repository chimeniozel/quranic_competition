import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:quranic_competition/models/archive_entry.dart';

class Competition {
  String? _competitionId;
  String? _competitionVirsion;
  DateTime? _startDate;
  bool? _isActive;
  List? _competitionTypes;
  ArchiveEntry? _archiveEntry;
  bool? _firstRoundIsPublished;
  bool? _lastRoundIsPublished;
  double? _successMoyenneChild;
  double? _successMoyenneAdult;
  int? _adultNumber;
  int? _childNumber;
  bool? _isInscriptionOpen;
  int? _adultNumberMax;
  int? _childNumberMax;

  Competition({
    String? competitionId,
    String? competitionVirsion,
    DateTime? startDate,
    bool? isActive,
    List? competitionTypes,
    ArchiveEntry? archiveEntry,
    bool? firstRoundIsPublished,
    bool? lastRoundIsPublished,
    double? successMoyenneChild,
    double? successMoyenneAdult,
    int? adultNumber,
    int? childNumber,
    bool? isInscriptionOpen,
    int? adultNumberMax,
    int? childNumberMax,
  })  : _competitionId = competitionId,
        _competitionVirsion = competitionVirsion,
        _startDate = startDate,
        _isActive = isActive,
        _competitionTypes = competitionTypes,
        _archiveEntry = archiveEntry,
        _firstRoundIsPublished = firstRoundIsPublished,
        _lastRoundIsPublished = lastRoundIsPublished,
        _successMoyenneChild = successMoyenneChild,
        _successMoyenneAdult = successMoyenneAdult,
        _adultNumber = adultNumber,
        _childNumber = childNumber,
        _isInscriptionOpen = isInscriptionOpen,
        _adultNumberMax = adultNumberMax,
        _childNumberMax = childNumberMax;

  String? get competitionId => _competitionId;
  String? get competitionVirsion => _competitionVirsion;
  DateTime? get startDate => _startDate;
  bool? get isActive => _isActive;
  List? get competitionTypes => _competitionTypes;
  ArchiveEntry? get archiveEntry => _archiveEntry;
  bool? get firstRoundIsPublished => _firstRoundIsPublished;
  bool? get lastRoundIsPublished => _lastRoundIsPublished;
  double? get successMoyenneChild => _successMoyenneChild;
  double? get successMoyenneAdult => _successMoyenneAdult;
  int? get adultNumber => _adultNumber;
  int? get childNumber => _childNumber;
  bool? get isInscriptionOpen => _isInscriptionOpen;
  int? get adultNumberMax => _adultNumberMax;
  int? get childNumberMax => _childNumberMax;

  set setCompetitionId(String competitionId) {
    _competitionId = competitionId;
  }

  set setCompetitionVirsion(String competitionVirsion) {
    _competitionVirsion = competitionVirsion;
  }

  set setStartDate(DateTime startDate) {
    _startDate = startDate;
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

  set firstRoundIsPublished(bool? value) {
    _firstRoundIsPublished = value;
  }

  set lastRoundIsPublished(bool? value) {
    _lastRoundIsPublished = value;
  }

  set successMoyenneChild(double? successMoyenne) {
    _successMoyenneChild = successMoyenne;
  }

  set successMoyenneAdult(double? successMoyenne) {
    _successMoyenneAdult = successMoyenne;
  }

  set adultNumber(int? adultNumber) {
    _adultNumber = adultNumber;
  }

  set childNumber(int? childNumber) {
    _childNumber = childNumber;
  }

  set isInscriptionOpen(bool? value) {
    _isInscriptionOpen = value;
  }

  set adultNumberMax(int? adultNumberMax) {
    _adultNumberMax = adultNumberMax;
  }

  set childNumberMax(int? childNumberMax) {
    _childNumberMax = childNumberMax;
  }

// to Map
  Map<String, dynamic> toMap() {
    return {
      'competitionId': competitionId,
      'competitionVirsion': competitionVirsion,
      'startDate': startDate,
      'isActive': isActive,
      'competitionTypes': competitionTypes,
      'archiveEntry': archiveEntry?.toMap(),
      "firstRoundIsPublished": _firstRoundIsPublished,
      "lastRoundIsPublished": _lastRoundIsPublished,
      "successMoyenneChild": _successMoyenneChild,
      "successMoyenneAdult": _successMoyenneAdult,
      "adultNumber": _adultNumber,
      "childNumber": _childNumber,
      "isInscriptionOpen": _isInscriptionOpen,
      "adultNumberMax": _adultNumberMax,
      "childNumberMax": _childNumberMax,
    };
  }

  // from Map
  Competition.fromMap(Map<String, dynamic>? map) {
    _competitionId = map?['competitionId'];
    _competitionVirsion = map?['competitionVirsion'];
    _startDate = (map?['startDate'] as Timestamp?)?.toDate();
    // _endDate = (map?['endDate'] as Timestamp?)?.toDate();
    _isActive = map?['isActive'];
    _competitionTypes = map?['competitionTypes'];
    _archiveEntry = ArchiveEntry.fromMap(map?['archiveEntry']);
    _firstRoundIsPublished = map?["firstRoundIsPublished"];
    _lastRoundIsPublished = map?["lastRoundIsPublished"];
    _successMoyenneChild = map?["successMoyenneChild"];
    _successMoyenneAdult = map?["successMoyenneAdult"];
    _adultNumber = map?["adultNumber"];
    _childNumber = map?["childNumber"];
    _isInscriptionOpen = map?["isInscriptionOpen"];
    _adultNumberMax = map?["adultNumberMax"];
    _childNumberMax = map?["childNumberMax"];
  }
}
