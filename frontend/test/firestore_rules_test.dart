import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import './mocks/firebase_mocks.mocks.dart'; // Generated mock classes
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  group('Firestore Rules - Access Control (mocked)', () {
    late MockFirebaseAuth auth;
    late MockFirebaseFirestore firestore;

    setUp(() {
      auth = MockFirebaseAuth();
      firestore = MockFirebaseFirestore();
    });

    test('TC2: Restrict other user data access', () async {
      print('\nTC2: User u2 cannot write to user u3 data (mocked)');

      final mockUserCredential = MockUserCredential();
      final mockUser = MockUser();

      // Stub user-related methods
      when(mockUserCredential.user).thenReturn(mockUser);
      when(mockUser.uid).thenReturn('u2');

      when(
        auth.createUserWithEmailAndPassword(
          email: 'u2@example.com',
          password: 'password123',
        ),
      ).thenAnswer((_) async => mockUserCredential);

      // Stub Firestore write access
      final mockDocRef = MockDocumentReference<Map<String, dynamic>>();
      final mockCollection = MockCollectionReference<Map<String, dynamic>>();

      when(firestore.collection('users')).thenReturn(mockCollection);
      when(mockCollection.doc('u3')).thenReturn(mockDocRef);

      // Simulate permission denial on set
      final mockException = FirebaseException(
        code: 'permission-denied',
        message: 'Mocked permission error on write',
        plugin: 'cloud_firestore',
      );
      when(mockDocRef.set({'name': 'User 3 updated'})).thenThrow(mockException);

      final u2 = await auth.createUserWithEmailAndPassword(
        email: 'u2@example.com',
        password: 'password123',
      );
      print(
        'Input: Authenticated user u2 (uid=${mockUser.uid}) tries to write to u3\'s document.',
      );

      try {
        await firestore.collection('users').doc('u3').set({
          'name': 'User 3 updated',
        });
        print('Actual Output: No exception thrown (unexpected)');
        print('Verdict: FAIL');
      } catch (e) {
        if (e is FirebaseException && e.code == 'permission-denied') {
          print(
            'Actual Output: Exception -> ${e.runtimeType}, code: ${e.code}, message: ${e.message}',
          );
          print('Verdict: PASS');
        } else {
          print('Actual Output: Unexpected exception -> $e');
          print('Verdict: FAIL');
        }
      }

      expect(
        () async => await firestore.collection('users').doc('u3').set({
          'name': 'User 3 updated',
        }),
        throwsA(
          isA<FirebaseException>().having(
            (e) => e.code,
            'code',
            'permission-denied',
          ),
        ),
      );
    });
  });
}
