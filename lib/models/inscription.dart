import 'package:cloud_firestore/cloud_firestore.dart';

class Inscription {
  int? _idInscription;
  String? _fullName;
  String? _phoneNumber;
  DateTime? _birthDate;
  String? _residencePlace;
  String? _howMuchYouMemorize;
  String? _haveYouIhaza;
  String? _howMuchRiwayaYouHave;
  String? _haveYouParticipatedInACompetition;
  String? _haveYouEverWon1stTo2ndPlace;
  TashihMachaikhs? _tashihMachaikhs;
  double? _resultFirstRound;
  double? _resultLastRound;
  bool? _isPassedFirstRound;

  Inscription({
    int? idInscription,
    String? fullName,
    String? phoneNumber,
    DateTime? birthDate,
    String? residencePlace,
    String? howMuchYouMemorize,
    String? haveYouIhaza,
    String? howMuchRiwayaYouHave,
    String? haveYouParticipatedInACompetition,
    String? haveYouEverWon1stTo2ndPlace,
    TashihMachaikhs? tashihMachaikhs,
    double? resultFirstRound,
    double? resultLastRound,
    bool? isPassedFirstRound,
  })  : _idInscription = idInscription,
        _fullName = fullName,
        _phoneNumber = phoneNumber,
        _birthDate = birthDate,
        _residencePlace = residencePlace,
        _howMuchYouMemorize = howMuchYouMemorize,
        _haveYouIhaza = haveYouIhaza,
        _howMuchRiwayaYouHave = howMuchRiwayaYouHave,
        _haveYouParticipatedInACompetition = haveYouParticipatedInACompetition,
        _haveYouEverWon1stTo2ndPlace = haveYouEverWon1stTo2ndPlace,
        _tashihMachaikhs = tashihMachaikhs,
        _resultFirstRound = resultFirstRound,
        _resultLastRound = resultLastRound,
        _isPassedFirstRound = isPassedFirstRound;

  // Getters
  int? get idInscription => _idInscription;
  String? get fullName => _fullName;
  String? get phoneNumber => _phoneNumber;
  DateTime? get birthDate => _birthDate;
  String? get residencePlace => _residencePlace;
  String? get howMuchYouMemorize => _howMuchYouMemorize;
  String? get haveYouIhaza => _haveYouIhaza;
  String? get howMuchRiwayaYouHave => _howMuchRiwayaYouHave;
  String? get haveYouParticipatedInACompetition =>
      _haveYouParticipatedInACompetition;
  String? get haveYouEverWon1stTo2ndPlace => _haveYouEverWon1stTo2ndPlace;
  TashihMachaikhs? get tashihMachaikhs => _tashihMachaikhs;
  double? get resultFirstRound => _resultFirstRound;
  double? get resultLastRound => _resultLastRound;
  bool? get isPassedFirstRound => _isPassedFirstRound;

  // Setters
  set idInscription(int? value) {
    _idInscription = value;
  }

  set fullName(String? value) {
    _fullName = value;
  }

  set phoneNumber(String? value) {
    _phoneNumber = value;
  }

  set birthDate(DateTime? value) {
    _birthDate = value;
  }

  set residencePlace(String? value) {
    _residencePlace = value;
  }

  set howMuchYouMemorize(String? value) {
    _howMuchYouMemorize = value;
  }

  set haveYouIhaza(String? value) {
    _haveYouIhaza = value;
  }

  set howMuchRiwayaYouHave(String? value) {
    _howMuchRiwayaYouHave = value;
  }

  set haveYouParticipatedInACompetition(String? value) {
    _haveYouParticipatedInACompetition = value;
  }

  set haveYouEverWon1stTo2ndPlace(String? value) {
    _haveYouEverWon1stTo2ndPlace = value;
  }

  set tashihMachaikhs(TashihMachaikhs? value) {
    _tashihMachaikhs = value;
  }

  set resultFirstRound(double? value) {
    _resultFirstRound = value;
  }

  set resultLastRound(double? value) {
    _resultLastRound = value;
  }

  set isPassedFirstRound(bool? value) {
    _isPassedFirstRound = value;
  }

  Map<String, dynamic> toMap() {
    return {
      "رقم التسجيل": _idInscription,
      "الاسم الثلاثي": _fullName,
      "رقم الهاتف": _phoneNumber,
      "تاريخ الميلاد": _birthDate?.toIso8601String(),
      "مكان الإقامة الحالية": _residencePlace,
      "كم تحفظ من القرآن الكريم": _howMuchYouMemorize,
      "هل حصلت على إجازة": _haveYouIhaza,
      "كم رواية تقرأ بها": _howMuchRiwayaYouHave,
      "هل سبق وأن شاركت في نسخة ماضية من مسابقة أهل القرآن الوتسابية":
          _haveYouParticipatedInACompetition,
      "هل سبق وأن حصلت على المراتب 1 إلى 2  في مسابقة أهل القرآن الوتسابية أو أي مسابقة أخرى":
          _haveYouEverWon1stTo2ndPlace,
      "tashihMachaikhs": _tashihMachaikhs?.toMap(),
      "نتائج التصفيات الأولى": _resultFirstRound,
      "نتائج التصفيات النهائية": _resultLastRound,
      "isPassedFirstRound": _isPassedFirstRound,
    };
  }

  factory Inscription.fromMap(Map<String, dynamic> map) {
    return Inscription(
      idInscription: map["رقم التسجيل"] as int?,
      fullName: map["الاسم الثلاثي"] as String?,
      phoneNumber: map["رقم الهاتف"] as String?,
      birthDate: DateTime.parse(map["تاريخ الميلاد"]),
      residencePlace: map["مكان الإقامة الحالية"] as String?,
      howMuchYouMemorize: map["كم تحفظ من القرآن الكريم"] as String?,
      haveYouIhaza: map["هل حصلت على إجازة"] as String?,
      howMuchRiwayaYouHave: map["كم رواية تقرأ بها"] as String?,
      haveYouParticipatedInACompetition:
          map["هل سبق وأن شاركت في نسخة ماضية من مسابقة أهل القرآن الوتسابية"]
              as String?,
      haveYouEverWon1stTo2ndPlace:
          map["هل سبق وأن حصلت على المراتب 1 إلى 2  في مسابقة أهل القرآن الوتسابية أو أي مسابقة أخرى"]
              as String?,
      tashihMachaikhs: TashihMachaikhs.fromMap(map["tashihMachaikhs"]),
      resultFirstRound: map["نتائج التصفيات الأولى"].toDouble(),
      resultLastRound: map["نتائج التصفيات النهائية"].toDouble(),
      isPassedFirstRound: map["isPassedFirstRound"],
    );
  }

  factory Inscription.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Inscription.fromMap(data);
  }
}

class TashihMachaikhs {
  List<dynamic>? _firstRound;
  List<dynamic>? _finalRound;

  TashihMachaikhs({
    List<dynamic>? firstRound,
    List<dynamic>? finalRound,
  })  : _firstRound = firstRound,
        _finalRound = finalRound;

  // Getters
  List<dynamic>? get firstRound => _firstRound;
  List<dynamic>? get finalRound => _finalRound;

  // Setters
  set firstRound(List<dynamic>? value) {
    _firstRound = value;
  }

  set finalRound(List<dynamic>? value) {
    _finalRound = value;
  }

  Map<String, dynamic> toMap() {
    return {
      "التصفيات الأولى": _firstRound,
      "التصفيات النهائية": _finalRound,
    };
  }

  factory TashihMachaikhs.fromMap(Map<String, dynamic> map) {
    return TashihMachaikhs(
      firstRound: map["التصفيات الأولى"],
      finalRound: map["التصفيات النهائية"],
    );
  }
}
