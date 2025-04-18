import 'constants.dart';
import 'reaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HumorProfile {
  final String userId;
  List<String> interests;
  double physicalHumorPreference;
  double linguisticHumorPreference;
  double situationalHumorPreference;
  double criticalHumorPreference;
  List<Reaction> reactionHistory;
  List<dynamic> favoriteContent;

  HumorProfile({
    required this.userId,
    this.interests = const [],
    this.physicalHumorPreference = 0.0,
    this.linguisticHumorPreference = 0.0,
    this.situationalHumorPreference = 0.0,
    this.criticalHumorPreference = 0.0,
    this.reactionHistory = const [],
    this.favoriteContent = const [],
  });

  // void setPreferencesFromTest(Map<String, double> answers) {
  //   physicalHumorPreference = answers['physical'] ?? 0.0;
  //   linguisticHumorPreference = answers['linguistic'] ?? 0.0;
  //   situationalHumorPreference = answers['situational'] ?? 0.0;
  //   criticalHumorPreference = answers['critical'] ?? 0.0;
  // }

  static Future<HumorProfile> setPreferencesFromTest(
    List<String> responseList,
  ) async {
    // Slice off the first empty/null item if needed
    final responses = responseList.sublist(1);

    int physical = 0, linguistic = 0, situational = 0, critical = 0;

    for (var type in responses) {
      switch (type.toLowerCase()) {
        case 'physical':
          physical++;
          break;
        case 'linguistic':
          linguistic++;
          break;
        case 'situational':
          situational++;
          break;
        case 'critical':
          critical++;
          break;
      }
    }

    final total = physical + linguistic + situational + critical;
    double toPercentage(int score) => (score / total * 100).clamp(0, 100);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    return HumorProfile(
      userId: user.uid,
      interests: [], // default
      physicalHumorPreference: toPercentage(physical),
      linguisticHumorPreference: toPercentage(linguistic),
      situationalHumorPreference: toPercentage(situational),
      criticalHumorPreference: toPercentage(critical),
      reactionHistory: [],
      favoriteContent: [],
    );
  }

  Map<String, double> getUserPreferences() {
    return {
      'physical': double.parse(physicalHumorPreference.toStringAsFixed(2)),
      'linguistic': double.parse(linguisticHumorPreference.toStringAsFixed(2)),
      'situational': double.parse(
        situationalHumorPreference.toStringAsFixed(2),
      ),
      'critical': double.parse(criticalHumorPreference.toStringAsFixed(2)),
    };
  }

  HumorProfile updateFromReaction(Reaction reaction) {
    final delta =
        {
          ReactionType.notFunny: -0.1,
          ReactionType.meh: 0.0,
          ReactionType.funny: 0.2,
          ReactionType.hillarious: 0.4,
        }[reaction.reactionType] ??
        0.0;

    final content = _findContentById(reaction.contentId);
    if (content == null) return this;

    switch (content.humorType) {
      case HumorType.physical:
        physicalHumorPreference += delta;
        break;
      case HumorType.linguistic:
        linguisticHumorPreference += delta;
        break;
      case HumorType.situational:
        situationalHumorPreference += delta;
        break;
      case HumorType.critical:
        criticalHumorPreference += delta;
        break;
    }

    reactionHistory = [...reactionHistory, reaction];
    return this;
  }

  HumorProfile updateFromQuery(String textContains) {
    final text = textContains.toLowerCase();
    if (text.contains('physical')) physicalHumorPreference += 0.05;
    if (text.contains('linguistic')) linguisticHumorPreference += 0.05;
    if (text.contains('situational')) situationalHumorPreference += 0.05;
    if (text.contains('critical')) criticalHumorPreference += 0.05;
    return this;
  }

  // bool saveProfile() {
  //   try {
  //     // Add persistent storage logic here
  //     return true;
  //   } catch (_) {
  //     return false;
  //   }
  // }

  Future<void> saveToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final docRef = FirebaseFirestore.instance
        .collection('humor_profile')
        .doc(user.uid);

    await docRef.set({
      'userId': userId,
      'interests': interests,
      'physicalHumorPreference': physicalHumorPreference,
      'linguisticHumorPreference': linguisticHumorPreference,
      'situationalHumorPreference': situationalHumorPreference,
      'criticalHumorPreference': criticalHumorPreference,
      'reactionHistory': [], // serialize if needed
      'favoriteContent': favoriteContent,
    });
  }

  dynamic _findContentById(String contentId) {
    return favoriteContent.firstWhere(
      (c) => c.id.toString() == contentId,
      orElse: () => null,
    );
  }
}
