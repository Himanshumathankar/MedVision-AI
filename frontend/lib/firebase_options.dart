import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
        return ios;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        throw UnsupportedError('DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDOshITBYC6sg6xNqVfpQZspdlP76_RWG0',
    appId: '1:953948179840:web:4355e43c96ed9813fd4565',
    messagingSenderId: '953948179840',
    projectId: 'medvision-d2394',
    authDomain: 'medvision-d2394.firebaseapp.com',
    storageBucket: 'medvision-d2394.firebasestorage.app',
    measurementId: 'G-MVJMWMNDLV',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB27i8TZ3Nm-Q2WDCKEov-gUhnXTUeoIXA',
    appId: '1:953948179840:android:bb25f528598041bbfd4565',
    messagingSenderId: '953948179840',
    projectId: 'medvision-d2394',
    storageBucket: 'medvision-d2394.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD54xmEWQIHXGsYoCkghwRoWdJSTi2x97o',
    appId: '1:953948179840:ios:f4d798bd32f276affd4565',
    messagingSenderId: '953948179840',
    projectId: 'medvision-d2394',
    storageBucket: 'medvision-d2394.firebasestorage.app',
    iosBundleId: 'com.medvision.ai',
  );
}
