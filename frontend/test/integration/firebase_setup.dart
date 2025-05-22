import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> initializeFirebase() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  try {
    // Initialize Firebase with emulator-compatible options
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'dummy-api-key',
        appId: 'dummy-app-id',
        messagingSenderId: 'dummy-sender-id',
        projectId: 'hodien-f5535', // Replace with your emulator project ID
      ),
    );
    print('Firebase initialized successfully.');

    // Connect Firestore to emulator
    FirebaseFirestore.instance.useFirestoreEmulator('10.0.2.2', 8080);
    FirebaseFirestore.instance.settings = const Settings(
      host: '10.0.2.2:8080',
      sslEnabled: false,
      persistenceEnabled: false,
    );
    print('Firestore connected to emulator at 10.0.2.2:8080.');

    // Connect Auth to emulator
    await FirebaseAuth.instance.useAuthEmulator('10.0.2.2', 9099);
    print('Firebase Auth connected to emulator at 10.0.2.2:9099.');

    // Verify emulator connection
    final host = FirebaseFirestore.instance.settings.host;
    if (!(host?.contains('10.0.2.2') ?? false) &&
        !(host?.contains('localhost') ?? false)) {
      throw Exception('Firestore is not connected to emulator.');
    }

    // Optional: Test Firestore connection
    // await FirebaseFirestore.instance.collection('test').doc('test').set({'data': 'test'});
    //final doc = await FirebaseFirestore.instance.collection('test').doc('test').get();
    //if (!doc.exists) {
    // throw Exception('Failed to connect to Firestore emulator.');
    //}
    print('Firestore emulator connection verified.');
  } catch (e) {
    print('Firebase initialization failed: $e');
    rethrow;
  }
}
