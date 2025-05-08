import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:frontend/models/user.dart';

class UserService {
  final firebase_auth.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserService({firebase_auth.FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? firebase_auth.FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

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
            .collection('user')
            .doc(firebaseUser.uid)
            .get();
    return User.fromFirestore(doc.data()!, firebaseUser.uid);
  }

  // Future<void> updateUser(User user) async {
  //   await FirebaseFirestore.instance
  //       .collection('user')
  //       .doc(user.userId)
  //       .set(
  //         user.toFirestore(),
  //         SetOptions(merge: true), // Merge to avoid overwriting fields
  //       );
  // }

  Future<String> updateProfileInfo({
    required String newUsername,
    // required String newEmail,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not logged in');

    // Check if email is already in use
    // final emailMethods = await _auth.fetchSignInMethodsForEmail(newEmail);
    // if (newEmail != currentUser.email && emailMethods.isNotEmpty) {
    //   throw Exception('Email already in use');
    // }
    // print(emailMethods);

    // final existingEmailSnapshot =
    //     await FirebaseFirestore.instance
    //         .collection('user')
    //         .where('email', isEqualTo: newEmail)
    //         .limit(1)
    //         .get();

    // if (existingEmailSnapshot.docs.isNotEmpty &&
    //     existingEmailSnapshot.docs.first.id != currentUser.uid) {
    //   throw Exception('Email already in use');
    // }

    // print(existingEmailSnapshot);

    // Check if username exists
    final usernameSnapshot =
        await _firestore
            .collection('user')
            .where('username', isEqualTo: newUsername)
            .get();
    // print(usernameSnapshot.docs);
    if (usernameSnapshot.docs.isNotEmpty &&
        usernameSnapshot.docs.first.id != currentUser.uid) {
      return 'Username already taken';
    }

    // Update Firebase Auth Email
    // if (newEmail != currentUser.email) {
    //   await currentUser.updateEmail(newEmail);
    // }

    // Update Firestore user document
    await _firestore.collection('user').doc(currentUser.uid).update({
      'username': newUsername,
      // 'email': newEmail,
    });

    return 'success';
  }

  Future<String> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not logged in');
    }

    final cred = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
      return 'success';
    } catch (e) {
      return 'Incorrect password or network issue';
      // throw Exception('Incorrect password or network issue');
    }
  }

  Future<String> deleteAccount(String password) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw Exception('User not logged in');
    }

    final cred = firebase_auth.EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );

    try {
      await user.reauthenticateWithCredential(cred);
      await _firestore.collection('user').doc(user.uid).delete();
      await user.delete();
      await _auth.signOut();
      return 'success';
    } catch (e) {
      // return '$e';
      return 'Password incorrect or failed to delete account';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<bool> checkHumorProfileExists() async {
    final user = _auth.currentUser;
    if (user == null) return false;

    final doc =
        await FirebaseFirestore.instance
            .collection('humor_profile')
            .doc(user.uid)
            .get();

    return doc.exists;
  }
}
