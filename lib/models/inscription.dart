import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:quranic_competition/constants/colors.dart';

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
  Map<String, dynamic>? _noteTajwid;
  Map<String, dynamic>? _noteHousnSawtt;
  Map<String, dynamic>? _noteOu4oubetSawtt;
  Map<String, dynamic>? _noteWaqfAndIbtidaa;
  Map<String, dynamic>? _noteIltizamRiwaya;
  Map<String, dynamic>? _result;

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
    Map<String, dynamic>? noteTajwid,
    Map<String, dynamic>? noteHousnSawtt,
    Map<String, dynamic>? noteOu4oubetSawtt,
    Map<String, dynamic>? noteWaqfAndIbtidaa,
    Map<String, dynamic>? noteIltizamRiwaya,
    Map<String, dynamic>? result,
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
        _noteTajwid = noteTajwid,
        _noteHousnSawtt = noteHousnSawtt,
        _noteOu4oubetSawtt = noteOu4oubetSawtt,
        _noteWaqfAndIbtidaa = noteWaqfAndIbtidaa,
        _noteIltizamRiwaya = noteIltizamRiwaya,
        _result = result;

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
  Map<String, dynamic>? get noteTajwid => _noteTajwid;
  Map<String, dynamic>? get noteHousnSawtt => _noteHousnSawtt;
  Map<String, dynamic>? get noteOu4oubetSawtt => _noteOu4oubetSawtt;
  Map<String, dynamic>? get noteWaqfAndIbtidaa => _noteWaqfAndIbtidaa;
  Map<String, dynamic>? get noteIltizamRiwaya => _noteIltizamRiwaya;
  Map<String, dynamic>? get result => _result;

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

  set noteTajwid(Map<String, dynamic>? value) {
    _noteTajwid = value;
  }

  set noteHousnSawtt(Map<String, dynamic>? value) {
    _noteHousnSawtt = value;
  }

  set noteOu4oubetSawtt(Map<String, dynamic>? value) {
    _noteOu4oubetSawtt = value;
  }

  set noteWaqfAndIbtidaa(Map<String, dynamic>? value) {
    _noteWaqfAndIbtidaa = value;
  }

  set noteIltizamRiwaya(Map<String, dynamic>? value) {
    _noteIltizamRiwaya = value;
  }

  set result(Map<String, dynamic>? value) {
    _result = value;
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
      "التجويد": _noteTajwid,
      "حسن الصوت": _noteHousnSawtt,
      "عذوبة الصوت": _noteOu4oubetSawtt,
      "الوقف والإبتداء": _noteWaqfAndIbtidaa,
      "الإلتزام بالرواية": _noteIltizamRiwaya,
      "المجموع": _result,
    };
  }

  factory Inscription.fromMap(Map<String, dynamic> map) {
    return Inscription(
      idInscription: map["رقم التسجيل"] as int?,
      fullName: map["الاسم الثلاثي"] as String?,
      phoneNumber: map["رقم الهاتف"] as String?,
      birthDate: DateTime.parse(map["تاريخ الميلاد"] as String),
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
      noteTajwid: map["التجويد"] as Map<String, dynamic>?,
      noteHousnSawtt: map["حسن الصوت"] as Map<String, dynamic>?,
      noteOu4oubetSawtt: map["عذوبة الصوت"] as Map<String, dynamic>?,
      noteWaqfAndIbtidaa: map["الوقف والإبتداء"] as Map<String, dynamic>?,
      noteIltizamRiwaya: map["الإلتزام بالرواية"] as Map<String, dynamic>?,
      result: map["المجموع"] as Map<String, dynamic>?,
    );
  }

  factory Inscription.fromDocumentSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Inscription.fromMap(data);
  }

  static Future<int> getNextId() async {
    final counterDoc = FirebaseFirestore.instance
        .collection('counters')
        .doc('inscriptionIdCounter');
    final snapshot = await counterDoc.get();

    int currentId = 0;
    if (snapshot.exists) {
      currentId = snapshot.data()!['currentId'] as int;
    }

    int newId = currentId + 1;
    await counterDoc.set({'currentId': newId});

    return newId;
  }

  }
