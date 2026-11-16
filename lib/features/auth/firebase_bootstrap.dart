import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// No production configuration or privileged credential is embedded in the app.
/// The web API key is an app identifier, not a security boundary.
class FirebaseBootstrap {
  static bool ready = false;
  static String? error;
  static const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const senderId = String.fromEnvironment(
    'FIREBASE_MESSAGING_SENDER_ID',
  );
  static const authDomain = String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const useEmulators = bool.fromEnvironment('FIREBASE_EMULATORS');
  static const emulatorHost = String.fromEnvironment(
    'FIREBASE_EMULATOR_HOST',
    defaultValue: 'localhost',
  );
  static bool get isConfigured =>
      apiKey.isNotEmpty &&
      appId.isNotEmpty &&
      projectId.isNotEmpty &&
      senderId.isNotEmpty &&
      authDomain.isNotEmpty;
  static Future<void> initialize() async {
    ready = false;
    error = null;
    if (!isConfigured) return;
    // FlutterFire web restores the emulator before persisted auth only in
    // debug mode on localhost. Fail closed in other configurations so a
    // reload cannot silently contact a production Auth endpoint.
    if (useEmulators &&
        (!kDebugMode ||
            !kIsWeb ||
            Uri.base.host != 'localhost' ||
            emulatorHost != 'localhost')) {
      error =
          'Firebase emülatörleri yalnızca localhost üzerinde Flutter Web debug modunda desteklenir.';
      return;
    }
    try {
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: apiKey,
          appId: appId,
          messagingSenderId: senderId,
          projectId: projectId,
          authDomain: authDomain,
        ),
      );
      if (useEmulators) {
        await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);
        FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8085);
      }
      ready = true;
    } catch (_) {
      error =
          'Firebase başlatılamadı. Yapılandırmayı ve bağlantıyı kontrol edin.';
    }
  }
}
