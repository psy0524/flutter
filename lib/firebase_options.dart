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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB1jmyXrc0m2qnbGAjLEDEAjkHfSr8Po2E',
    appId: '1:722427738117:android:5bb4f622d9b1287f0b446c',
    messagingSenderId: '722427738117',
    projectId: 'sunmoonapp-15e86',
    databaseURL: 'https://sunmoonapp-15e86-default-rtdb.firebaseio.com',
    storageBucket: 'sunmoonapp-15e86.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBTyIPz_jNpBXU7_utOXYTG0v6Ntsi7B6o',
    appId: '1:722427738117:ios:0603062b7f46df3f0b446c',
    messagingSenderId: '722427738117',
    projectId: 'sunmoonapp-15e86',
    databaseURL: 'https://sunmoonapp-15e86-default-rtdb.firebaseio.com',
    storageBucket: 'sunmoonapp-15e86.firebasestorage.app',
    iosBundleId: 'com.example.untitled',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyA7yRo_luwObNzNqaKfxcJwZEdFMrOIwcU',
    appId: '1:722427738117:web:cb4e176a5efb4f020b446c',
    messagingSenderId: '722427738117',
    projectId: 'sunmoonapp-15e86',
    authDomain: 'sunmoonapp-15e86.firebaseapp.com',
    databaseURL: 'https://sunmoonapp-15e86-default-rtdb.firebaseio.com',
    storageBucket: 'sunmoonapp-15e86.firebasestorage.app',
  );

}