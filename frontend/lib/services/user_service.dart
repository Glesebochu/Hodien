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
          .collection('user')
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
        .collection('user')
        .doc(uid)
        .snapshots()
        .map((doc) {
          if (doc.exists) {
            return User.fromFirestore(doc.data() as Map<String, dynamic>, uid);
          }
          return null;
        });
  }

  // Get current user (snapshot)
  Future<User?> getCurrentUser() async {
    final firebaseUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (firebaseUser == null) return null;
    final doc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .get();
    return User.fromFirestore(doc.data()!, firebaseUser.uid);
  }

  Future<void> updateUser(User user) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(user.userId)
        .set(
          user.toFirestore(),
          SetOptions(merge: true), // Merge to avoid overwriting fields
        );
  }

  // Update email with reauthentication
  Future<void> updateEmail(String newEmail, String password) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user signed in');

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updateEmail(newEmail);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'email': newEmail,
    });
  }

  // Update password with reauthentication
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user signed in');

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  // Delete account with reauthentication
  Future<void> deleteAccount(String password) async {
    final user = firebase_auth.FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('No user signed in');

    final credential = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}
