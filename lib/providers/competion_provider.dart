import 'package:flutter/foundation.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/services/competion_service.dart';

class CompetitionProvider with ChangeNotifier {
  Competition? _competition;
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  Competition? get competition => _competition;

  void setCompetition(Competition? competition) {
    _competition = competition;
    notifyListeners();
  }

  void resetCompetition() {
    _competition = Competition();
    notifyListeners();
  }

  Future<void> getCurrentCompetition() async {
    _isLoading = true;
    notifyListeners();
    try {
      Competition? competition =
          await CompetitionService.getCurrentCompetition();
      setCompetition(competition);
    } catch (e) {
      print(e);
    }
    _isLoading = false;
    notifyListeners();
  }
}
