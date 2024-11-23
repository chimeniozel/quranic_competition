import 'package:flutter/foundation.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompetitionProvider with ChangeNotifier {
  Competition? _competition;
  bool _isLoading = false;
  int _hommeAdultNumber = 0;
  int _femmeAdultNumber = 0;
  int _hommeChildNumber = 0;
  int _femmeChildNumber = 0;

  bool get isLoading => _isLoading;
  Competition? get competition => _competition;
  int get hommeAdultNumber => _hommeAdultNumber;
  int get femmeAdultNumber => _femmeAdultNumber;
  int get hommeChildNumber => _hommeChildNumber;
  int get femmeChildNumber => _femmeChildNumber;

  late final Stream<QuerySnapshot> _competitionStream;

  CompetitionProvider() {
    _fetchAndListenToActiveCompetition();
  }

  void setCompetition(Competition? competition) {
    _competition = competition;
    notifyListeners();
    if (competition != null) {
      _fetchParticipantCounts(); // Fetch participant counts when competition is set
      _listenToParticipantChanges(); // Listen for real-time participant changes
    }
  }

  void resetCompetition() {
    _competition = null;
    _hommeAdultNumber = 0;
    _femmeAdultNumber = 0;
    _hommeChildNumber = 0;
    _femmeChildNumber = 0;
    notifyListeners();
  }

  Future<void> _fetchAndListenToActiveCompetition() async {
    await getCurrentCompetition();
    _listenToCompetitionChanges();
  }

  Future<void> getCurrentCompetition() async {
    _isLoading = true;
    notifyListeners();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('competitions')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final competitionData = querySnapshot.docs.first.data();
        setCompetition(Competition.fromMap(competitionData));
      } else {
        resetCompetition();
      }
    } catch (e) {
      print("Error fetching competition: $e");
    }
    _isLoading = false;
    notifyListeners();
  }

  void _listenToCompetitionChanges() {
    _competitionStream = FirebaseFirestore.instance
        .collection('competitions')
        .where('isActive', isEqualTo: true)
        .snapshots();

    _competitionStream.listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        final competitionData =
            snapshot.docs.first.data() as Map<String, dynamic>;
        setCompetition(Competition.fromMap(competitionData));
      } else {
        resetCompetition();
      }
    });
  }

  /// Fetch the number of homme and femme participants
  Future<void> _fetchParticipantCounts() async {
    if (_competition == null) return;

    final competitionVersion = _competition!.competitionVirsion;

    try {
      final hommeAdultCountQuery = await FirebaseFirestore.instance
          .collection("inscriptions")
          .doc(competitionVersion)
          .collection("adult_inscription")
          .where("الجنس", isEqualTo: "ذكر")
          .get();

      final femmeAdultCountQuery = await FirebaseFirestore.instance
          .collection("inscriptions")
          .doc(competitionVersion)
          .collection("adult_inscription")
          .where("الجنس", isNotEqualTo: "ذكر")
          .get();
      final hommeChildCountQuery = await FirebaseFirestore.instance
          .collection("inscriptions")
          .doc(competitionVersion)
          .collection("child_inscription")
          .where("الجنس", isEqualTo: "ذكر")
          .get();

      final femmeChildCountQuery = await FirebaseFirestore.instance
          .collection("inscriptions")
          .doc(competitionVersion)
          .collection("child_inscription")
          .where("الجنس", isNotEqualTo: "ذكر")
          .get();

      _hommeAdultNumber = hommeAdultCountQuery.docs.length;
      _femmeAdultNumber = femmeAdultCountQuery.docs.length;

      _hommeChildNumber = hommeChildCountQuery.docs.length;
      _femmeChildNumber = femmeChildCountQuery.docs.length;

      notifyListeners();
    } catch (e) {
      print("Error fetching participant counts: $e");
    }
  }

  /// Listen to real-time changes in participant counts
  void _listenToParticipantChanges() {
    if (_competition == null) return;

    final competitionVersion = _competition!.competitionVirsion;

    // Listen to changes in adult participants
    FirebaseFirestore.instance
        .collection("inscriptions")
        .doc(competitionVersion)
        .collection("adult_inscription")
        .snapshots()
        .listen((snapshot) {
      final hommeAdultCount =
          snapshot.docs.where((doc) => doc["الجنس"] == "ذكر").length;

      final femmeAdultCount =
          snapshot.docs.where((doc) => doc["الجنس"] != "ذكر").length;

      _hommeAdultNumber = hommeAdultCount;
      _femmeAdultNumber = femmeAdultCount;

      notifyListeners();
    });

    // Listen to changes in child participants
    FirebaseFirestore.instance
        .collection("inscriptions")
        .doc(competitionVersion)
        .collection("child_inscription")
        .snapshots()
        .listen((snapshot) {
      final hommeChildCount =
          snapshot.docs.where((doc) => doc["الجنس"] == "ذكر").length;

      final femmeChildCount =
          snapshot.docs.where((doc) => doc["الجنس"] != "ذكر").length;

      _hommeChildNumber = hommeChildCount;
      _femmeChildNumber = femmeChildCount;

      notifyListeners();
    });
  }
}
