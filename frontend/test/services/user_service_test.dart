import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:frontend/services/user_service.dart'; // Your UserService class
// import 'package:frontend/models/user.dart';
import '../mocks/firebase_mocks.mocks.dart'; // Import the generated mocks
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

void main() {
  late MockFirebaseAuth mockAuth;
  late MockFirebaseFirestore mockFirestore;
  late UserService userService;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();

    FirebasePlatform.instance = FakeFirebasePlatform();
  });

  setUp(() {
    mockAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();

    userService = UserService(auth: mockAuth, firestore: mockFirestore);
  });

  group('UserService Tests', () {
    test('logout calls signOut', () async {
      when(mockAuth.signOut()).thenAnswer((_) async => {});

      await userService.logout();

      verify(mockAuth.signOut()).called(1);
    });

    test('deleteAccount deletes user and document', () async {
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('user123');
      when(mockUser.email).thenReturn('user@example.com');
      when(mockUser.delete()).thenAnswer((_) async {});

      // Mock reauthenticateWithCredential
      when(
        mockUser.reauthenticateWithCredential(any),
      ).thenAnswer((_) async => MockUserCredential());

      // Mock Firestore delete
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();

      // Collection name is 'user' (not 'users'!)
      when(mockFirestore.collection('user')).thenReturn(mockCollection);
      when(mockCollection.doc('user123')).thenReturn(mockDocRef);
      when(mockDocRef.delete()).thenAnswer((_) async {});

      // Mock signOut
      when(mockAuth.signOut()).thenAnswer((_) async {});

      // Call function
      final result = await userService.deleteAccount('correctPassword');

      // Verify
      verify(mockUser.reauthenticateWithCredential(any)).called(1);
      verify(mockDocRef.delete()).called(1);
      verify(mockUser.delete()).called(1);
      verify(mockAuth.signOut()).called(1);

      expect(result, 'success');
    });

    test('Successful Login', () async {
      final mockUserCredential = MockUserCredential();

      when(
        mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockUserCredential);

      final result = await mockAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      );

      verify(
        mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'password123',
        ),
      ).called(1);

      expect(result, isA<firebase_auth.UserCredential>());
    });

    test('Invalid Login', () async {
      when(
        mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
      ).thenThrow(
        firebase_auth.FirebaseAuthException(
          code: 'wrong-password',
          message: 'Incorrect password',
        ),
      );

      expect(
        () async => await mockAuth.signInWithEmailAndPassword(
          email: 'test@example.com',
          password: 'wrongpassword',
        ),
        throwsA(isA<firebase_auth.FirebaseAuthException>()),
      );
    });

    test('Update Password', () async {
      final mockUser = MockUser();
      when(mockAuth.currentUser).thenReturn(mockUser);
      when(mockUser.email).thenReturn('test@example.com');

      when(
        mockUser.reauthenticateWithCredential(any),
      ).thenAnswer((_) async => MockUserCredential());
      when(mockUser.updatePassword('newPassword123')).thenAnswer((_) async {});

      final result = await userService.updatePassword(
        currentPassword: 'currentPassword',
        newPassword: 'newPassword123',
      );

      verify(mockUser.reauthenticateWithCredential(any)).called(1);
      verify(mockUser.updatePassword('newPassword123')).called(1);

      expect(result, 'success');
    });
  });
}

class FakeFirebasePlatform extends FirebasePlatform {
  FakeFirebasePlatform() : super();

  @override
  FirebaseAppPlatform app([String? name]) {
    return FakeFirebaseAppPlatform();
  }

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
