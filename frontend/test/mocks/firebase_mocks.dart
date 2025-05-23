import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/annotations.dart';
import 'package:frontend/models/humor_profile.dart';

@GenerateMocks([
  firebase_auth.FirebaseAuth,
  firebase_auth.User,
  firebase_auth.UserCredential,
  firebase_auth.AuthCredential,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  FirebaseFirestore,
  QuerySnapshot,
  Query,
  QueryDocumentSnapshot,
  HumorProfile,
])
void main() {}
