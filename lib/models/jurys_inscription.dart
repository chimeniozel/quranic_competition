import 'package:quranic_competition/models/note_result.dart';

class JuryInscription {
  String? _idCollection;
  String _idJury;
  int _idInscription;
  NoteModel? _firstNotes;
  NoteModel? _lastNotes;
  bool? _isAdult;
  bool? _isFirstCorrected;
  bool? _isLastCorrected;

  // Constructor
  JuryInscription({
    String? idCollection,
    required String idJury,
    required int idInscription,
    NoteModel? firstNotes,
    NoteModel? lastNotes,
    bool? isAdult,
    bool? isFirstCorrected,
  bool? isLastCorrected,
  })  : _idCollection = idCollection,
        _idJury = idJury,
        _idInscription = idInscription,
        _firstNotes = firstNotes,
        _lastNotes = lastNotes,
        _isAdult = isAdult,
        _isFirstCorrected = isFirstCorrected,
        _isLastCorrected = isLastCorrected;

  // Getters and Setters
  String? get idCollection => _idCollection;
  set idCollection(String? value) => _idCollection = value;

  String get idJury => _idJury;
  set idJury(String value) => _idJury = value;

  int get idInscription => _idInscription;
  set idInscription(int value) => _idInscription = value;

  NoteModel? get firstNotes => _firstNotes;
  set firstNotes(NoteModel? value) => _firstNotes = value;

  NoteModel? get lastNotes => _lastNotes;
  set lastNotes(NoteModel? value) => _lastNotes = value;

  bool? get isAdult => _isAdult;
  set isAdult(bool? value) => _isAdult = value;

  bool? get isFirstCorrected => _isFirstCorrected;
  set isFirstCorrected(bool? value) => _isFirstCorrected = value;
  
  bool? get isLastCorrected => _isLastCorrected;
  set isLastCorrected(bool? value) => _isLastCorrected = value;

  // Convert to map for adult contestants
  Map<String, dynamic> toMapAdult() {
    return {
      'idCollection': _idCollection,
      'idJury': _idJury,
      'idInscription': _idInscription,
      'firstResult': _firstNotes?.toMapAdult(),
      'lastResult': _lastNotes?.toMapAdult(),
      'isAdult': _isAdult,
      'isFirstCorrected': _isFirstCorrected,
      'isLastCorrected': _isLastCorrected,
    };
  }

  // Convert to map for child contestants
  Map<String, dynamic> toMapChild() {
    return {
      'idCollection': _idCollection,
      'idJury': _idJury,
      'idInscription': _idInscription,
      'firstResult': _firstNotes?.toMapChild(),
      'lastResult': _lastNotes?.toMapChild(),
      'isAdult': _isAdult,
      'isFirstCorrected': _isFirstCorrected,
      'isLastCorrected': _isLastCorrected,
    };
  }

  // Factory constructor to create a JuryInscription instance from map for adult contestants
  factory JuryInscription.fromMapAdult(Map<String, dynamic> map) {
    return JuryInscription(
      idCollection: map['idCollection'] as String?,
      idJury: map['idJury'] as String,
      idInscription: map['idInscription'] as int,
      firstNotes: map['firstResult'] != null
          ? NoteModel.fromMapAdult(map['firstResult'] as Map<String, dynamic>)
          : null,
      lastNotes: map['lastResult'] != null
          ? NoteModel.fromMapAdult(map['lastResult'] as Map<String, dynamic>)
          : null,
          isAdult: map['isAdult'] as bool?,
          isFirstCorrected: map['isFirstCorrected'] as bool?,
      isLastCorrected: map['isLastCorrected'] as bool?,
    );
  }

  // Factory constructor to create a JuryInscription instance from map for child contestants
  factory JuryInscription.fromMapChild(Map<String, dynamic> map) {
    return JuryInscription(
      idCollection: map['idCollection'] as String?,
      idJury: map['idJury'] as String,
      idInscription: map['idInscription'] as int,
      firstNotes: map['firstResult'] != null
          ? NoteModel.fromMapChild(map['firstResult'] as Map<String, dynamic>)
          : null,
      lastNotes: map['lastResult'] != null
          ? NoteModel.fromMapChild(map['lastResult'] as Map<String, dynamic>)
          : null,
          isAdult: map['isAdult'] as bool?,
          isFirstCorrected: map['isFirstCorrected'] as bool?,
      isLastCorrected: map['isLastCorrected'] as bool?,
    );
  }
}
