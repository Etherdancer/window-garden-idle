import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyC0ewVeqbl1XklqvhqgHYW43KhddWsYU8w',
    appId: '1:629704576770:web:19e849894664150978fc1b',
    messagingSenderId: '629704576770',
    projectId: 'window-garden-82313',
    authDomain: 'window-garden-82313.firebaseapp.com',
    storageBucket: 'window-garden-82313.firebasestorage.app',
    measurementId: 'G-DKPZJ2B8NJ',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC0ewVeqbl1XklqvhqgHYW43KhddWsYU8w',
    appId: '1:629704576770:android:placeholder',
    messagingSenderId: '629704576770',
    projectId: 'window-garden-82313',
    storageBucket: 'window-garden-82313.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyC0ewVeqbl1XklqvhqgHYW43KhddWsYU8w',
    appId: '1:629704576770:ios:placeholder',
    messagingSenderId: '629704576770',
    projectId: 'window-garden-82313',
    storageBucket: 'window-garden-82313.firebasestorage.app',
    iosBundleId: 'com.windowgarden.window_garden_idle',
  );

  static const FirebaseOptions macos = ios;
}
