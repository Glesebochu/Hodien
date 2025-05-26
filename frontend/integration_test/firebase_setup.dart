import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> initializeFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  try {
    // Check if Firebase is already initialized to avoid duplicate initialization
    if (Firebase.apps.isNotEmpty) {
      print('⚡ Firebase already initialized, skipping initialization.');
      return;
    }

    // Initialize Firebase without options for emulator-only testing
    await Firebase.initializeApp();
    print('✅ Firebase initialized.');

    // Detect whether we're running in Android emulator or locally
    final isRunningOnAndroidEmulator =
        Platform.environment.containsKey('ANDROID_EMULATOR') ||
        !Platform.environment.containsKey('FLUTTER_TEST');
    final host = isRunningOnAndroidEmulator ? '10.0.2.2' : 'localhost';

    // Firestore Emulator
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    print('✅ Firestore connected to emulator at $host:8080.');

    // Auth Emulator
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    print('✅ Firebase Auth connected to emulator at $host:9099.');

    // Verify Firestore emulator connection
    final effectiveHost = FirebaseFirestore.instance.settings.host;
    if (!(effectiveHost?.contains(host) ?? false)) {
      throw Exception('⚠️ Firestore is NOT connected to the emulator.');
    }

    print('✅ Firestore emulator connection verified.');
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
    rethrow;
  }
}
