import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_setup.dart';
import 'package:frontend/services/engine.dart';
import 'package:frontend/models/humor_profile.dart';

void main() {
  setUpAll(() async {
    print('Starting setUpAll...');
    try {
      if (Firebase.apps.isEmpty) {
        print('Initializing Firebase...');
        await initializeFirebase().timeout(Duration(seconds: 10));
        print('Firebase initialized.');
      } else {
        print('Firebase already initialized.');
      }

      print('Configuring Firestore settings...');
      FirebaseFirestore.instance.settings = const Settings(
        host: '10.0.2.2:8080',
        sslEnabled: false,
        persistenceEnabled: false,
      );

      print('Checking emulator connection: ${_isUsingEmulator()}');
      if (!_isUsingEmulator()) {
        throw Exception('Not connected to emulator!');
      }

      print('Signing in anonymously...');
      await FirebaseAuth.instance.signInAnonymously().timeout(
        Duration(seconds: 5),
      );
      print('Signed in anonymously: ${FirebaseAuth.instance.currentUser?.uid}');

      print('Seeding test data...');
      await seedTestData().timeout(Duration(seconds: 10));
      print('Test data seeded.');
    } catch (e) {
      print('Error in setUpAll: $e');
      rethrow;
    }
  });

  tearDownAll(() async {
    if (_isUsingEmulator()) {
      print('Clearing Firestore data...');
      await clearFirestoreData().timeout(Duration(seconds: 5));
      print('Signing out...');
      await FirebaseAuth.instance.signOut().timeout(Duration(seconds: 5));
      print('Firestore data cleared and user signed out.');
    }
  });

  test('Test personalization feed retrieves expected data', () async {
    print('Running personalization feed test...');
    final snapshot = await FirebaseFirestore.instance
        .collection('content')
        .get()
        .timeout(Duration(seconds: 5));
    print('Retrieved ${snapshot.docs.length} documents');
    expect(snapshot.docs.isNotEmpty, true);
  });
}

bool _isUsingEmulator() {
  final host = FirebaseFirestore.instance.settings.host;
  print('Firestore host: $host');
  return host != null &&
      (host.contains('localhost:8080') ||
          host.contains('127.0.0.1:8080') ||
          host.contains('10.0.2.2:8080'));
}

Future<void> seedTestData() async {
  if (!_isUsingEmulator()) {
    throw Exception('Attempted to seed data outside emulator.');
  }

  final contentCollection = FirebaseFirestore.instance.collection('content');

  final existingDocs = await contentCollection.get();
  print('Existing documents before seeding: ${existingDocs.docs.length}');
  await Future.wait(
    existingDocs.docs.map((doc) {
      print('Deleting existing document: ${doc.id}');
      return doc.reference.delete();
    }),
  ).timeout(Duration(seconds: 5));

  final jokes = [
    {
      'id': 'joke1',
      'humorType': '1',
      'text': 'Why did the chicken cross the road? To get to the other side!',
    },
    {
      'id': 'joke2',
      'humorType': '2',
      'text':
          'I would tell you a joke about construction, but I’m still working on it.',
    },
    {
      'id': 'joke3',
      'humorType': '3',
      'text': 'Critical humor — the government is a joke!',
    },
    {
      'id': 'joke4',
      'humorType': '4',
      'text': 'Situational humor — spilled coffee before a job interview.',
    },
  ];

  await Future.wait(
    jokes.map((joke) {
      print('Seeding joke: ${joke['id']}');
      return contentCollection.doc(joke['id']).set(joke);
    }),
  ).timeout(Duration(seconds: 5));
}

Future<void> clearFirestoreData() async {
  if (!_isUsingEmulator()) {
    print('Skipping data deletion — not connected to emulator.');
    return;
  }

  final contentCollection = FirebaseFirestore.instance.collection('content');
  final snapshot = await contentCollection.get().timeout(Duration(seconds: 5));
  await Future.wait(
    snapshot.docs.map((doc) => doc.reference.delete()),
  ).timeout(Duration(seconds: 5));
  print('Cleared ${snapshot.docs.length} documents.');
}
