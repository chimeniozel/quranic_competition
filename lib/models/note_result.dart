class NoteResult {
  String? _cheikhName;
  NoteModel? _notes;
  bool? _isCorrected;

  NoteResult({
    String? cheikhName,
    NoteModel? notes,
    bool? isCorrected,
  })  : _cheikhName = cheikhName,
        _notes = notes,
        _isCorrected = isCorrected;

  // to Map
  Map<String, dynamic>? toMapAdult() {
    return {
      'اسم الشيخ': _cheikhName,
      'النتائج': _notes?.toMapAdult(),
      'تم التصحيح': _isCorrected,
    };
  }

// to Map
  Map<String, dynamic>? toMapChild() {
    return {
      'اسم الشيخ': _cheikhName,
      'النتائج': _notes?.toMapChild(),
      'تم التصحيح': _isCorrected,
    };
  }

  // from Map
  NoteResult.fromMapAdult(Map<String, dynamic> map) {
    cheikhName = map['اسم الشيخ'];
    notes = NoteModel.fromMapAdult(map['النتائج']);
    isCorrected = map['تم التصحيح'];
  }

  // from Map
  NoteResult.fromMapChild(Map<String, dynamic> map) {
    cheikhName = map['اسم الشيخ'];
    notes = NoteModel.fromMapChild(map['النتائج']);
    isCorrected = map['تم التصحيح'];
  }

  // getters
  String? get cheikhName => _cheikhName;
  NoteModel? get notes => _notes;
  bool? get isCorrected => _isCorrected;
  // setters
  set cheikhName(String? value) {
    _cheikhName = value; // Correctly assign the value to the private field
  }

  set notes(NoteModel? value) {
    _notes = value; // Correctly assign the value to the private field
  }

  set isCorrected(bool? value) {
    _isCorrected = value; // Correctly assign the value to the private field
  }
}

class NoteModel {
  double? _noteTajwid;
  double? _noteHousnSawtt;
  double? _noteOu4oubetSawtt;
  double? _noteWaqfAndIbtidaa;
  double? _noteIltizamRiwaya;
  double? _result;
  // bool? _isFirstCorrected;
  // bool? _isLastCorrected;

  NoteModel({
    double? noteTajwid,
    double? noteHousnSawtt,
    double? noteOu4oubetSawtt,
    double? noteWaqfAndIbtidaa,
    double? noteIltizamRiwaya,
    double? result,
    // required bool? isFirstCorrected,
    // required bool? isLastCorrected,
  })  : _noteTajwid = noteTajwid,
        _noteHousnSawtt = noteHousnSawtt,
        _noteOu4oubetSawtt = noteOu4oubetSawtt,
        _noteWaqfAndIbtidaa = noteWaqfAndIbtidaa,
        _noteIltizamRiwaya = noteIltizamRiwaya,
        _result = result;
  // _isFirstCorrected = isFirstCorrected,
  // _isLastCorrected = isLastCorrected;

  // setters
  set noteTajwid(double? value) {
    _noteTajwid = value;
  }

  set noteHousnSawtt(double? value) {
    _noteHousnSawtt = value;
  }

  set noteOu4oubetSawtt(double? value) {
    _noteOu4oubetSawtt = value;
  }

  set noteWaqfAndIbtidaa(double? value) {
    _noteWaqfAndIbtidaa = value;
  }

  set noteIltizamRiwaya(double? value) {
    _noteIltizamRiwaya = value;
  }

  set result(double? value) {
    _result = value;
  }

  // set isFirstCorrected(bool? value) {
  //   _isFirstCorrected = value;
  // }

  // set isLastCorrected(bool? value) {
  //   _isLastCorrected = value;
  // }

  // getters
  double? get noteTajwid => _noteTajwid;
  double? get noteHousnSawtt => _noteHousnSawtt;
  double? get noteOu4oubetSawtt => _noteOu4oubetSawtt;
  double? get noteWaqfAndIbtidaa => _noteWaqfAndIbtidaa;
  double? get noteIltizamRiwaya => _noteIltizamRiwaya;
  double? get result => _result;
  // bool? get isFirstCorrected => _isFirstCorrected;
  // bool? get isLastCorrected => _isLastCorrected;
  // from Map
  NoteModel.fromMapAdult(Map<String, dynamic> map) {
    noteTajwid = map["التجويد"].toDouble();
    noteHousnSawtt = map["حسن الصوت"].toDouble();
    noteIltizamRiwaya = map["الإلتزام بالرواية"].toDouble();
    result = map["النتيجة"].toDouble();
    // isFirstCorrected = map["isFirstCorrected"];
    // isLastCorrected = map["isLastCorrected"];
  }

  // from Map
  NoteModel.fromMapChild(Map<String, dynamic> map) {
    noteTajwid = map["التجويد"].toDouble();
    noteHousnSawtt = map["حسن الصوت"].toDouble();
    noteOu4oubetSawtt = map["عذوبة الصوت"].toDouble();
    noteWaqfAndIbtidaa = map["الوقف والإبتداء"].toDouble();
    result = map["النتيجة"].toDouble();
    // isFirstCorrected = map["isFirstCorrected"];
    // isLastCorrected = map["isLastCorrected"];
  }

  // to MapAdult
  Map<String, dynamic>? toMapAdult() {
    return {
      "التجويد": _noteTajwid,
      "حسن الصوت": _noteHousnSawtt,
      "الإلتزام بالرواية": _noteIltizamRiwaya,
      "النتيجة": _result,
      // "isFirstCorrected": _isFirstCorrected,
      // "isLastCorrected": _isLastCorrected,
    };
  }

  // to MapChild
  Map<String, dynamic>? toMapChild() {
    return {
      "التجويد": _noteTajwid,
      "حسن الصوت": _noteHousnSawtt,
      "عذوبة الصوت": _noteOu4oubetSawtt,
      "الوقف والإبتداء": _noteWaqfAndIbtidaa,
      "النتيجة": _result,
      // "isFirstCorrected": _isFirstCorrected,
      // "isLastCorrected": _isLastCorrected,
    };
  }
}
