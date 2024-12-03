import 'package:flutter/material.dart';
import 'package:quranic_competition/services/network_service.dart';

class ConnectivityWidget extends StatelessWidget {
  final Widget child;

  const ConnectivityWidget({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: NetworkService.monitorConnection(),
      initialData: true,
      builder: (context, snapshot) {
        final isConnected = snapshot.data ?? true;
        if (isConnected) {
          return child;
        } else {
          return Scaffold(
            body: Center(
              child: Container(
                color: Colors.red,
                padding: const EdgeInsets.all(8.0),
                child: const Text(
                  'No Internet Connection',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
