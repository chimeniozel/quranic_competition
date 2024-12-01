import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityProvider with ChangeNotifier {
  late BuildContext scaffoldContext;
  bool _isConnected = false;

  bool get isConnected => _isConnected;

  // Set the scaffold context to show SnackBar
  void setScaffoldContext(BuildContext context) {
    scaffoldContext = context;
  }

  // Monitor and update connectivity status
  void updateConnectivity() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    _isConnected = [ConnectivityResult.wifi, ConnectivityResult.mobile]
        .contains(connectivityResult.first);
    notifyListeners();
  }

  // Show a SnackBar message when no connection is detected
  // void showNoConnectionSnackBar() {
  //   ScaffoldMessenger.of(_scaffoldContext).showSnackBar(
  //     const SnackBar(content: Text('No connection. Please try again.')),
  //   );
  // }
}
