import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_setup.dart';
import 'package:frontend/services/engine.dart';
import 'package:frontend/models/humor_profile.dart';
// contains initializeFirebase()

void main() {
  setUpAll(() async {
    print('Starting Firebase initialization...');
    await initializeFirebase();
    print('Firebase initialized.');

    if (!_isUsingEmulator()) {
      throw Exception('Not connected to emulator!');
    }

    await FirebaseAuth.instance.signInAnonymously();
    print('Signed in anonymously.');
    // Ensure we're connected to the emulator before running test setup
    assert(_isUsingEmulator(), ' Not connected to emulator. Aborting tests.');

    await seedTestData();
  });

  tearDownAll(() async {
    if (_isUsingEmulator()) {
      await clearFirestoreData();
    }
  });

  test('Test personalization feed retrieves expected data', () async {
    final snapshot =
        await FirebaseFirestore.instance.collection('content').get();
    expect(snapshot.docs.isNotEmpty, true);
    // Additional personalization assertions here
  });

  test(
    'fetchSurpriseMeJoke returns a joke from least-preferred humor types',
    () async {
      final user = FirebaseAuth.instance.currentUser;
      expect(user, isNotNull, reason: 'User must be signed in');

      final profile = HumorProfile(
        userId: user!.uid,
        physicalHumorPreference: 80, // HumorType 1
        linguisticHumorPreference: 15, // HumorType 2
        situationalHumorPreference: 2, // HumorType 4 (low weight)
        criticalHumorPreference: 3, // HumorType 3 (low weight)
      );

      final engine = HumorEngine(profile: profile);
      final joke = await engine.fetchSurpriseMeJoke();

      expect(joke.isNotEmpty, true, reason: 'No joke returned');
      expect(
        ['3', '4'].contains(joke['humorType']),
        true,
        reason: 'Expected a joke from lesser-weighted humor types',
      );

      print('🎉 Surprise joke: ${joke['text']} (Type ${joke['humorType']})');
    },
  );
}

/// Checks if Firestore is connected to emulator
bool _isUsingEmulator() {
  final host = FirebaseFirestore.instance.settings.host;
  if (host == null) return false;
  return host.contains('localhost') || host.contains('127.0.0.1');
}

/// Seeds only in emulator
Future<void> seedTestData() async {
  if (!_isUsingEmulator()) {
    throw Exception(' Attempted to seed data outside emulator.');
  }

  final contentCollection = FirebaseFirestore.instance.collection('content');

  // Clear any existing data
  final existingDocs = await contentCollection.get();
  for (final doc in existingDocs.docs) {
    await doc.reference.delete();
  }

  // Seed fresh test data
  await contentCollection.add({
    'id': 'joke1',
    'humorType': '1',
    'text': 'Why did the chicken cross the road? To get to the other side!',
  });

  await contentCollection.add({
    'id': 'joke2',
    'humorType': '2',
    'text':
        'I would tell you a joke about construction, but I’m still working on it.',
  });

  await contentCollection.add({
    'id': 'joke3',
    'humorType': '3',
    'text': 'Critical humor — the government is a joke!',
  });
  await contentCollection.add({
    'id': 'joke4',
    'humorType': '4',
    'text': 'Situational humor — spilled coffee before a job interview.',
  });
}

/// ✅ Clears emulator data safely
Future<void> clearFirestoreData() async {
  if (!_isUsingEmulator()) {
    print('Skipping data deletion — not connected to emulator.');
    return;
  }

  //  final collections = ['content', 'users'];
  //for (final name in collections) {
  // final collection = FirebaseFirestore.instance.collection(name);
  //final snapshot = await collection.get();
  //for (final doc in snapshot.docs) {
  //  await doc.reference.delete();
  // }
  //}
}
