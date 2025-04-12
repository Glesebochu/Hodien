import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:frontend/models/user.dart';

class UserService {
  Future<void> registerUser(
    String email,
    String password,
    String username,
  ) async {
    try {
      // Create user with Firebase Authentication
      firebase_auth.UserCredential userCredential = await firebase_auth
          .FirebaseAuth
          .instance
          .createUserWithEmailAndPassword(email: email, password: password);
      String? uid = userCredential.user?.uid;

      if (uid == null) {
        throw Exception('Failed to retrieve user UID');
      }

      // Create User model instance
      User user = User(userId: uid, username: username, email: email);

      // Write to Firestore with explicit error handling
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set(user.toFirestore(), SetOptions(merge: false))
          .catchError((e) {
            throw Exception('Firestore write failed: $e');
          });
    } catch (e) {
      print('Registration error: $e');
      rethrow; // Rethrow to allow UI to handle the error
    }
  }

  Stream<User?> getCurrentUserStream() {
    final uid = firebase_auth.FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(null);
    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return User.fromFirestore(doc.data() as Map<String, dynamic>, uid);
          }
          return null;
        });
  }

  Future<void> updateUser(User user) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.userId)
        .set(
          user.toFirestore(),
          SetOptions(merge: true), // Merge to avoid overwriting fields
        );
  }
}
