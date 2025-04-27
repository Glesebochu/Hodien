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
  List<String> favoriteContent;

  HumorProfile({
    required this.userId,
    this.interests = const [],
    this.physicalHumorPreference = 0.25,
    this.linguisticHumorPreference = 0.25,
    this.situationalHumorPreference = 0.25,
    this.criticalHumorPreference = 0.25,
    this.reactionHistory = const [],
    List<String>? favoriteContent,
  }) : favoriteContent = favoriteContent ?? [];

  //add id of favorite content
  void addFavoriteById(String contentId) {
    print('Adding content ID to favorites: $contentId');
    if (!favoriteContent.contains(contentId)) {
      favoriteContent.insert(0, contentId);
    } // Only add if not already in the stack// Console log for debugging
    print('Current favorites stack: $favoriteContent'); //
  }

  void removeFavoriteById(String contentId) {
    print('Removing content ID from favorites: $contentId');
    if (favoriteContent.contains(contentId)) {
      favoriteContent.remove(contentId);
    } // Only add if not already in the stack// Console log for debugging
    print('Current favorites stack: $favoriteContent'); //
  }

  // Getter to retrieve the stack of favorite IDs
  List<String> getFavoriteContentStack() {
    return favoriteContent; // Return a copy to avoid direct modification
  }

  // Ensure preferences stay within bounds (0-1)

  // Future<Map<HumorType, double>> getHumorTypeScores() async {
  //   //retrieve the humor type scores from database for current user

  //   return {
  //     HumorType.physical: double.parse(physical// ),
  //     HumorType.linguistic: double.parse(
  //       linguisticHumorPreference.toStringAsFixed(2),
  //     ),
  //     HumorType.situational: double.parse(
  //       situationalHumorPreference.toStringAsFixed(2),
  //     ),
  //     HumorType.critical: double.parse(
  //       criticalHumorPreference.toStringAsFixed(2),
  //     ),
  //   };
  // }

  Future<Map<HumorType, double>> getHumorTypeScores() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception('No user logged in.');
    }

    final docRef = FirebaseFirestore.instance
        .collection('humor_profile')
        .doc(user.uid);

    final docSnap = await docRef.get();

    if (!docSnap.exists) {
      throw Exception('Humor profile not found.');
    }

    final data = docSnap.data()!;

    return {
      HumorType.physical: (data['physicalHumorPreference'] ?? 0.0).toDouble(),
      HumorType.linguistic:
          (data['linguisticHumorPreference'] ?? 0.0).toDouble(),
      HumorType.situational:
          (data['situationalHumorPreference'] ?? 0.0).toDouble(),
      HumorType.critical: (data['criticalHumorPreference'] ?? 0.0).toDouble(),
    };
  }

  double _clampPreference(double value) {
    return value.clamp(0.0, 1.0);
  }

  void updateByFavorite(HumorType humorType) async {
    double increment = 0.3; // Example increment

    switch (humorType) {
      case HumorType.physical:
        physicalHumorPreference = _clampPreference(
          physicalHumorPreference + increment,
        );
        break;
      case HumorType.linguistic:
        linguisticHumorPreference = _clampPreference(
          linguisticHumorPreference + increment,
        );
        break;
      case HumorType.situational:
        situationalHumorPreference = _clampPreference(
          situationalHumorPreference + increment,
        );
        break;
      case HumorType.critical:
        criticalHumorPreference = _clampPreference(
          criticalHumorPreference + increment,
        );
        break;
    }
    await saveToFirebase();
  }

  // Update humor profile based on reaction
  void updateFromReaction(HumorType humorType, String reaction) async {
    double change = 0.0;
    print('calling');

    // Define how the reaction affects humor preference
    switch (reaction) {
      case 'Not Funny':
        change = -0.2;
        print('reduced'); // Decrease preference for humor type
        break;
      case 'Meh':
        change = -0.1; // No change
        break;
      case 'Funny':
        change = 0.1; // Increase preference for humor type
        break;
      case 'Hilarious':
        change = 0.2; // Increase preference more
        break;
    }

    switch (humorType) {
      case HumorType.physical:
        physicalHumorPreference = _clampPreference(
          physicalHumorPreference + change,
        );
        break;
      case HumorType.linguistic:
        linguisticHumorPreference = _clampPreference(
          linguisticHumorPreference + change,
        );
        break;
      case HumorType.situational:
        situationalHumorPreference = _clampPreference(
          situationalHumorPreference + change,
        );
        break;
      case HumorType.critical:
        criticalHumorPreference = _clampPreference(
          criticalHumorPreference + change,
        );
        break;
    }
    await saveToFirebase();
    // reactionHistory = [...reactionHistory, reaction];
  }
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

  //dynamic _findContentById(String contentId) {
  // return favoriteContent.firstWhere(
  // (c) => c.id.toString() == contentId,
  //orElse: () => null,
  //);
  //}
}
