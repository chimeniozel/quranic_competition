// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCautJ-9EXaIOaIzA3F1yRc7V6QhYh9rv4',
    appId: '1:395894434800:web:02012d174233d9be060b35',
    messagingSenderId: '395894434800',
    projectId: 'quranic-competition-app',
    authDomain: 'quranic-competition-app.firebaseapp.com',
    storageBucket: 'quranic-competition-app.appspot.com',
    measurementId: 'G-SR492G399T',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCeb978MKkEBgvHuAE5-DV4krwI3aQM0OU',
    appId: '1:395894434800:android:e1e8de52d1b2ce61060b35',
    messagingSenderId: '395894434800',
    projectId: 'quranic-competition-app',
    storageBucket: 'quranic-competition-app.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDWd2MYNh0mi3XwxZ0d5hDN-PagF8YiiMI',
    appId: '1:395894434800:ios:e828cad7cfd88172060b35',
    messagingSenderId: '395894434800',
    projectId: 'quranic-competition-app',
    storageBucket: 'quranic-competition-app.appspot.com',
    iosBundleId: 'com.chemeni.quranic-competitions',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDWd2MYNh0mi3XwxZ0d5hDN-PagF8YiiMI',
    appId: '1:395894434800:ios:e828cad7cfd88172060b35',
    messagingSenderId: '395894434800',
    projectId: 'quranic-competition-app',
    storageBucket: 'quranic-competition-app.appspot.com',
    iosBundleId: 'com.chemeni.quranic-competitions',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCautJ-9EXaIOaIzA3F1yRc7V6QhYh9rv4',
    appId: '1:395894434800:web:bc3fa054cefc8527060b35',
    messagingSenderId: '395894434800',
    projectId: 'quranic-competition-app',
    authDomain: 'quranic-competition-app.firebaseapp.com',
    storageBucket: 'quranic-competition-app.appspot.com',
    measurementId: 'G-640SK7Q5S2',
  );
}
