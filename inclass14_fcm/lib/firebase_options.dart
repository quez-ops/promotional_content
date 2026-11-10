// Generated for inclass13
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
      default:
        return android;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCJqzfwGqXO1p--KjJwaiVONhotGg2mmhk',
    appId: '1:47870117885:web:2adc3e22fdae45ee5e3b94',
    messagingSenderId: '47870117885',
    projectId: 'inclass13-auth-64e6b',
    authDomain: 'inclass13-auth-64e6b.firebaseapp.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCJqzfwGqXO1p--KjJwaiVONhotGg2mmhk',
    appId: '1:47870117885:android:2adc3e22fdae45ee5e3b94',
    messagingSenderId: '47870117885',
    projectId: 'inclass13-auth-64e6b',
  );
}
