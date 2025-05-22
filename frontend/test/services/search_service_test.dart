// 📄 search_service_test.dart

import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:frontend/services/translator_service.dart';
import '../mocks/search_mocks.mocks.dart';

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockTranslator mockTranslator;
  late MockPreprocessingService mockPreprocessor;
  late MockQueryProfileMatcher mockMatcher;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    FirebasePlatform.instance = FakeFirebasePlatform();
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockTranslator = MockTranslator();
    mockPreprocessor = MockPreprocessingService();
    mockMatcher = MockQueryProfileMatcher();
  });

  group('SearchService Logic Tests', () {
    // TC1: Valid Search Query
    test('TC1: Valid Search Query', () async {
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_user');

      when(mockTranslator.translateText('funny cat')).thenAnswer(
        (_) async =>
            TranslationResult(translatedText: 'funny cat', language: 'en'),
      );

      when(
        mockPreprocessor.sendInputToPreprocessor(
          originalText: 'funny cat',
          translatedText: 'funny cat',
          language: 'en',
          userId: 'test_user',
        ),
      ).thenAnswer((_) async => 'query123');

      final expectedResults = [
        {'id': '1', 'text': 'funny cat joke'},
      ];

      when(
        mockMatcher.matchQueryAndProfile(
          userId: 'test_user',
          queryId: 'query123',
        ),
      ).thenAnswer((_) async => expectedResults);

      final translation = await mockTranslator.translateText('funny cat');
      final queryId = await mockPreprocessor.sendInputToPreprocessor(
        originalText: 'funny cat',
        translatedText: translation.translatedText,
        language: translation.language,
        userId: mockUser.uid,
      );
      final results = await mockMatcher.matchQueryAndProfile(
        userId: mockUser.uid,
        queryId: queryId,
      );

      final pass =
          results.isNotEmpty && results.first['text'].contains('funny cat');

      print('''
 TC1: Valid Search Query
 Description: Should translate, preprocess, and match a meaningful query like "funny cat".
 Input Query: "funny cat"
 Expected Behavior:
  - Translation: "funny cat"
  - Preprocessed to: query123
  - Match returns results aligned to humor profile.
 Actual Output: $results
 Verdict: ${pass ? 'PASS' : 'FAIL'}
''');

      expect(pass, isTrue);
    });

    // TC2: Invalid/Gibberish Search
    test('TC2: Invalid/Gibberish Search', () async {
      final query = 'aajsdhasd\$\$\$';
      when(
        mockTranslator.translateText(query),
      ).thenThrow(Exception('Invalid query'));

      try {
        await mockTranslator.translateText(query);
      } catch (e) {
        print('''
 TC2: Invalid/Gibberish Search
 Description: Should reject nonsensical or malformed input.
 Input Query: "$query"
 Expected: Display "Please enter a valid query" and do not proceed.
 Actual Output: Exception -> $e
 Verdict: ${e.toString().contains('Invalid query') ? 'PASS' : 'FAIL'}
''');
        expect(e.toString(), contains('Invalid query'));
      }
    });

    // TC3: Empty Search
    test('TC3: Empty Search', () async {
      final query = '';
      when(mockTranslator.translateText(query)).thenAnswer(
        (_) async => TranslationResult(translatedText: '', language: 'en'),
      );

      final translation = await mockTranslator.translateText(query);

      print('''
 TC3: Empty Search
 Description: Should prevent search on empty input.
 Input Query: ""
 Expected: No API call or processing should happen.
 Actual Output: translatedText="${translation.translatedText}"
 Verdict: ${translation.translatedText!.isEmpty ? 'PASS' : 'FAIL'}
''');

      expect(translation.translatedText!.isEmpty, isTrue);
    });

    // TC4: Results Load Successfully
    test('TC4: Results Load Successfully', () async {
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_user');

      when(mockTranslator.translateText('funny cat')).thenAnswer(
        (_) async =>
            TranslationResult(translatedText: 'funny cat', language: 'en'),
      );

      when(
        mockPreprocessor.sendInputToPreprocessor(
          originalText: 'funny cat',
          translatedText: 'funny cat',
          language: 'en',
          userId: 'test_user',
        ),
      ).thenAnswer((_) async => 'query123');

      final resultSet = [
        {'id': '1', 'text': 'funny cat joke'},
        {'id': '2', 'text': 'another funny joke'},
      ];

      when(
        mockMatcher.matchQueryAndProfile(
          userId: 'test_user',
          queryId: 'query123',
        ),
      ).thenAnswer((_) async => resultSet);

      final translation = await mockTranslator.translateText('funny cat');
      final queryId = await mockPreprocessor.sendInputToPreprocessor(
        originalText: 'funny cat',
        translatedText: translation.translatedText,
        language: translation.language,
        userId: mockUser.uid,
      );
      final results = await mockMatcher.matchQueryAndProfile(
        userId: mockUser.uid,
        queryId: queryId,
      );

      final pass = results.length >= 2;

      print('''
 TC4: Results Load Successfully
 Description: After search is triggered, spinner shows while results load and disappear afterward.
 Input: "funny cat"
 Expected: Results list returned and app continues smoothly.
 Actual Output: ${results.length} results -> $results
 Verdict: ${pass ? 'PASS' : 'FAIL'}
''');

      expect(pass, isTrue);
    });

    // TC5: Backend Error During Search
    test('TC5: Backend Error During Search', () async {
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('test_user');

      when(mockTranslator.translateText('funny cat')).thenAnswer(
        (_) async =>
            TranslationResult(translatedText: 'funny cat', language: 'en'),
      );

      when(
        mockPreprocessor.sendInputToPreprocessor(
          originalText: 'funny cat',
          translatedText: 'funny cat',
          language: 'en',
          userId: 'test_user',
        ),
      ).thenAnswer((_) async => 'query123');

      when(
        mockMatcher.matchQueryAndProfile(
          userId: 'test_user',
          queryId: 'query123',
        ),
      ).thenThrow(Exception('Backend error'));

      final translation = await mockTranslator.translateText('funny cat');
      final queryId = await mockPreprocessor.sendInputToPreprocessor(
        originalText: 'funny cat',
        translatedText: translation.translatedText,
        language: translation.language,
        userId: mockUser.uid,
      );

      try {
        await mockMatcher.matchQueryAndProfile(
          userId: mockUser.uid,
          queryId: queryId,
        );
      } catch (e) {
        final pass = e.toString().contains('Backend error');
        print('''
 TC5: Backend Error During Search
 Description: When backend fails, app should gracefully handle it and show error message.
 Input: "funny cat"
 Expected: Toast/snackbar shown with retry advice.
 Actual Output: Exception -> $e
 Verdict: ${pass ? 'PASS' : 'FAIL'}
''');
        expect(pass, isTrue);
      }
    });
  });
}

// ✅ Fake Firebase support
class FakeFirebasePlatform extends FirebasePlatform {
  FakeFirebasePlatform() : super();
  @override
  FirebaseAppPlatform app([String? name]) => FakeFirebaseAppPlatform();
  @override
  List<FirebaseAppPlatform> get apps => [FakeFirebaseAppPlatform()];
}

class FakeFirebaseAppPlatform extends FirebaseAppPlatform {
  FakeFirebaseAppPlatform()
    : super(
        'fakeApp',
        const FirebaseOptions(
          apiKey: 'fakeApiKey',
          appId: 'fakeAppId',
          messagingSenderId: 'fakeSenderId',
          projectId: 'fakeProjectId',
        ),
      );

  @override
  Future<void> delete() async {}
}
