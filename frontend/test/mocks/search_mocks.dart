// 📦 search_mocks.dart
import 'package:mockito/annotations.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/services/translator_service.dart';
import 'package:frontend/services/preprocessing_service.dart';
import 'package:frontend/services/query_profile_matcher.dart';

@GenerateMocks([
  firebase_auth.FirebaseAuth,
  firebase_auth.User,
  firebase_auth.UserCredential,
  firebase_auth.AuthCredential,
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  QueryDocumentSnapshot,
  Translator,
  PreprocessingService,
  QueryProfileMatcher,
])
void main() {}
