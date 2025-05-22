import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/engine.dart';
import 'package:frontend/models/humor_profile.dart';
import '../mocks/firebase_mocks.mocks.dart';
import 'package:frontend/models/constants.dart';

void main() {
  late HumorEngine engine;
  late MockHumorProfile mockProfile;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late List<MockQueryDocumentSnapshot<Map<String, dynamic>>> mockDocs;

  final humorTypes = ['physical', 'linguistic', 'situational', 'critical'];

  setUp(() {
    // Initialize mocks
    mockProfile = MockHumorProfile();
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();

    // Create mock documents with string humor types
    mockDocs = List.generate(20, (index) {
      final mockDoc = MockQueryDocumentSnapshot<Map<String, dynamic>>();
      final humorType = humorTypes[index % 4];

      when(mockDoc.id).thenReturn('$index');
      when(mockDoc.data()).thenReturn({
        'id': '$index',
        'humor_type': humorType,
        'text': 'Joke #$index',
      });

      when(mockDoc['id']).thenReturn('$index');
      when(mockDoc['humor_type']).thenReturn(humorType);
      when(mockDoc['text']).thenReturn('Joke #$index');
      return mockDoc;
    });

    // Setup complete Firestore mock chain
    when(mockFirestore.collection('content')).thenReturn(mockCollection);
    when(
      mockCollection.where(any, isEqualTo: anyNamed('isEqualTo')),
    ).thenReturn(mockCollection);
    when(mockCollection.limit(any)).thenReturn(mockCollection);
    when(mockCollection.get()).thenAnswer((_) async => mockQuerySnapshot);
    when(mockQuerySnapshot.docs).thenReturn(mockDocs);

    // Initialize HumorEngine with mocked profile and firestore
    engine = HumorEngine(profile: mockProfile, firestore: mockFirestore);
  });

  test('fetchJokesProportionally returns correct number of jokes', () async {
    when(mockProfile.getHumorTypeScores()).thenAnswer(
      (_) async => {
        HumorType.physical: 10.0,
        HumorType.linguistic: 10.0,
        HumorType.situational: 10.0,
        HumorType.critical: 10.0,
      },
    );

    final jokes = await engine.fetchJokesProportionally(totalToPick: 5);
    expect(jokes.length, 5);
  });

  test('fetchJokesProportionally respects humor weights', () async {
    when(mockProfile.getHumorTypeScores()).thenAnswer(
      (_) async => {
        HumorType.physical: 20.0,
        HumorType.linguistic: 10.0,
        HumorType.situational: 10.0,
        HumorType.critical: 10.0,
      },
    );

    final jokes = await engine.fetchJokesProportionally(totalToPick: 5);

    // Count jokes per humorType
    final counts = <String, int>{};
    for (var joke in jokes) {
      counts[joke['humorType']] = (counts[joke['humorType']] ?? 0) + 1;
    }

    expect(jokes.length, 5);
    expect(counts['physical'] ?? 0, greaterThanOrEqualTo(1));
  });

  test('fetchSurpriseMeJoke returns joke from least preferred type', () async {
    when(mockProfile.getHumorTypeScores()).thenAnswer(
      (_) async => {
        HumorType.physical: 5.0,
        HumorType.linguistic: 20.0,
        HumorType.situational: 20.0,
        HumorType.critical: 20.0,
      },
    );

    final joke = await engine.fetchSurpriseMeJoke();
    expect(joke.isNotEmpty, true);
    expect(joke['humorType'], equals('physical'));
  });

  test('fetchJokesProportionally skips types with 0 weight', () async {
    when(mockProfile.getHumorTypeScores()).thenAnswer(
      (_) async => {
        HumorType.physical: 10.0,
        HumorType.linguistic: 0.0,
        HumorType.situational: 20.0,
        HumorType.critical: 10.0,
      },
    );

    final jokes = await engine.fetchJokesProportionally(totalToPick: 5);
    final types = jokes.map((j) => j['humorType']).toSet();

    // linguistic (0.0 weight) should not appear
    expect(types.contains('linguistic'), isFalse);
  });

  test('fetchJokesProportionally returns randomized order', () async {
    when(mockProfile.getHumorTypeScores()).thenAnswer(
      (_) async => {
        HumorType.physical: 1.0,
        HumorType.linguistic: 1.0,
        HumorType.situational: 1.0,
        HumorType.critical: 1.0,
      },
    );

    final jokes1 = await engine.fetchJokesProportionally(totalToPick: 5);
    final jokes2 = await engine.fetchJokesProportionally(totalToPick: 5);

    final ids1 = jokes1.map((j) => j['id']).toList();
    final ids2 = jokes2.map((j) => j['id']).toList();

    // Expect different orders most of the time
    expect(ids1, isNot(equals(ids2)));
  });

  test(
    'fetchJokesProportionally returns empty list when all humor weights are zero',
    () async {
      when(
        mockProfile.getHumorTypeScores(),
      ).thenAnswer((_) async => {for (var type in HumorType.values) type: 0.0});

      final result = await engine.fetchJokesProportionally();
      expect(result, isEmpty);
    },
  );
  test(
    'fetchJokesProportionally returns empty list when Firestore throws an exception',
    () async {
      when(
        mockProfile.getHumorTypeScores(),
      ).thenAnswer((_) async => {HumorType.physical: 1.0});

      when(
        mockCollection.where('humor_type', isEqualTo: anyNamed('isEqualTo')),
      ).thenThrow(Exception('Firestore failure'));

      final result = await engine.fetchJokesProportionally();
      expect(result, isEmpty);
    },
  );
  test(
    'fetchSurpriseMeJoke returns empty map when no jokes found for least preferred type',
    () async {
      when(mockProfile.getHumorTypeScores()).thenAnswer(
        (_) async => {
          HumorType.physical: 0.8,
          HumorType.linguistic: 0.6,
          HumorType.situational: 0.4,
          HumorType.critical: 0.1, // least preferred
        },
      );

      // Simulate no jokes for 'critical'
      when(
        mockCollection.where('humor_type', isEqualTo: 'critical'),
      ).thenReturn(mockCollection);
      when(mockCollection.get()).thenAnswer((_) async {
        final emptySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
        when(emptySnapshot.docs).thenReturn([]);
        return emptySnapshot;
      });

      final result = await engine.fetchSurpriseMeJoke();
      expect(result, isEmpty);
    },
  );
}
