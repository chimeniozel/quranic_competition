import 'package:flutter/foundation.dart';
import 'package:quranic_competition/models/competition.dart';
import 'package:quranic_competition/services/competion_service.dart';

class CompetitionProvider with ChangeNotifier {
  Competition? _competition = Competition();

  Competition? get competition => _competition;

  void setCompetition(Competition? competition) {
    _competition = competition;
    notifyListeners();
  }

  void resetCompetition() {
    _competition = Competition();
    notifyListeners();
  }

  void getCurrentCompetition() async {
    Competition? competition = await CompetitionService.getCurrentCompetition();
    setCompetition(competition);
    notifyListeners();
  }
}
