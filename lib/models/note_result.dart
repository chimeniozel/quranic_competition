class NoteResult {
  String? _cheikhName;
  NoteModel? _notes;

  NoteResult({
    String? cheikhName,
    NoteModel? notes,
  })  : _cheikhName = cheikhName,
        _notes = notes;

  // to Map
  Map<String, dynamic>? toMapAdult() {
    return {
      'اسم الشيخ': _cheikhName,
      'النتائج': _notes?.toMapAdult(),
    };
  }

// to Map
  Map<String, dynamic>? toMapChild() {
    return {
      'اسم الشيخ': _cheikhName,
      'النتائج': _notes?.toMapChild(),
    };
  }

  // from Map
  NoteResult.fromMapAdult(Map<String, dynamic> map) {
    cheikhName = map['اسم الشيخ'];
    notes = NoteModel.fromMapAdult(map['النتائج']);
  }

  // from Map
  NoteResult.fromMapChild(Map<String, dynamic> map) {
    cheikhName = map['اسم الشيخ'];
    notes = NoteModel.fromMapChild(map['النتائج']);
  }

  // getters
  String? get cheikhName => _cheikhName;
  NoteModel? get notes => _notes;
  // setters
  set cheikhName(String? value) {
    _cheikhName = value; // Correctly assign the value to the private field
  }

  set notes(NoteModel? value) {
    _notes = value; // Correctly assign the value to the private field
  }
}

class NoteModel {
  double? _noteTajwid;
  double? _noteHousnSawtt;
  double? _noteOu4oubetSawtt;
  double? _noteWaqfAndIbtidaa;
  double? _noteIltizamRiwaya;

  NoteModel({
    double? noteTajwid,
    double? noteHousnSawtt,
    double? noteOu4oubetSawtt,
    double? noteWaqfAndIbtidaa,
    double? noteIltizamRiwaya,
  })  : _noteTajwid = noteTajwid,
        _noteHousnSawtt = noteHousnSawtt,
        _noteOu4oubetSawtt = noteOu4oubetSawtt,
        _noteWaqfAndIbtidaa = noteWaqfAndIbtidaa,
        _noteIltizamRiwaya = noteIltizamRiwaya;

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

  // getters
  double? get noteTajwid => _noteTajwid;
  double? get noteHousnSawtt => _noteHousnSawtt;
  double? get noteOu4oubetSawtt => _noteOu4oubetSawtt;
  double? get noteWaqfAndIbtidaa => _noteWaqfAndIbtidaa;
  double? get noteIltizamRiwaya => _noteIltizamRiwaya;
  // from Map
  NoteModel.fromMapAdult(Map<String, dynamic> map) {
    noteTajwid = map["التجويد"].toDouble();
    noteHousnSawtt = map["حسن الصوت"].toDouble();
    noteIltizamRiwaya = map["الإلتزام بالرواية"].toDouble();
  }

  // from Map
  NoteModel.fromMapChild(Map<String, dynamic> map) {
    noteTajwid = map["التجويد"].toDouble();
    noteHousnSawtt = map["حسن الصوت"].toDouble();
    noteOu4oubetSawtt = map["عذوبة الصوت"].toDouble();
    noteWaqfAndIbtidaa = map["الوقف والإبتداء"].toDouble();
  }

  // to MapAdult
  Map<String, dynamic>? toMapAdult() {
    return {
      "التجويد": _noteTajwid,
      "حسن الصوت": _noteHousnSawtt,
      "الإلتزام بالرواية": _noteIltizamRiwaya,
    };
  }

  // to MapChild
  Map<String, dynamic>? toMapChild() {
    return {
      "التجويد": _noteTajwid,
      "حسن الصوت": _noteHousnSawtt,
      "عذوبة الصوت": _noteOu4oubetSawtt,
      "الوقف والإبتداء": _noteWaqfAndIbtidaa,
    };
  }
}
