import 'package:flutter/foundation.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CompetitionProvider with ChangeNotifier {
  Competition? _competition;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Competition? get competition => _competition;
  late final Stream<QuerySnapshot> _competitionStream;

  CompetitionProvider() {
    _fetchAndListenToActiveCompetition();
  }

  void setCompetition(Competition? competition) {
    _competition = competition;
    notifyListeners();
  }

  void resetCompetition() {
    _competition = null;
    notifyListeners();
  }

  /// Fetch the active competition initially and then start listening to updates
  Future<void> _fetchAndListenToActiveCompetition() async {
    await getCurrentCompetition();  // Fetches the initial active competition
    _listenToCompetitionChanges();  // Sets up the listener for real-time updates
  }

  Future<void> getCurrentCompetition() async {
    _isLoading = true;
    notifyListeners();
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('competitions')
          .where('isActive', isEqualTo: true)
          .limit(1)  // Get only one document
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
        final competitionData = snapshot.docs.first.data() as Map<String, dynamic>;
        setCompetition(Competition.fromMap(competitionData));
      } else {
        resetCompetition();  // Reset if no active competitions are found
      }
    });
  }
}
