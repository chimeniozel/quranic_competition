import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkService {
  static final Connectivity _connectivity = Connectivity();

  // Check current connectivity status
  static Future<bool> isConnected() async {
    var connectivityResult = await _connectivity.checkConnectivity();
    // Check if the result is wifi or mobile
    return connectivityResult.first == ConnectivityResult.wifi ||
           connectivityResult.first == ConnectivityResult.mobile;
  }

  // Monitor connectivity changes
  static Stream<bool> monitorConnection() async* {
    await for (var result in _connectivity.onConnectivityChanged) {
      // Emit true if result is wifi or mobile
      yield result.first == ConnectivityResult.wifi || 
            result.first == ConnectivityResult.mobile;
    }
  }
}
