import 'constants.dart';
import 'reaction.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:frontend/models/favorite.dart';

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
    this.physicalHumorPreference = 25,
    this.linguisticHumorPreference = 25,
    this.situationalHumorPreference = 25,
    this.criticalHumorPreference = 25,
    this.reactionHistory = const [],
    List<String>? favoriteContent,
  }) : favoriteContent = favoriteContent ?? [];

  //add id of favorite content
  void addFavoriteById(String contentId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final favoritesRef = FirebaseFirestore.instance
        .collection('favorite')
        .doc(user.uid); // Use user ID as the doc ID

    await favoritesRef.set({
      'userId': user.uid,
      'contentIds': FieldValue.arrayUnion([contentId]),
      'favoritedAt': DateTime.now(),
    }, SetOptions(merge: true));

    await loadFavoriteContentStack(); // merge: true preserves existing data
  }

  void removeFavoriteById(String contentId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    print('Removing content ID from favorites: $contentId');

    // Remove from Firestore
    final favoritesRef = FirebaseFirestore.instance
        .collection('favorite')
        .doc(user.uid);

    await favoritesRef.update({
      'contentIds': FieldValue.arrayRemove([contentId]),
    });
    await loadFavoriteContentStack();
  }

  Future<void> loadFavoriteContentStack() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('User not logged in');

    final doc =
        await FirebaseFirestore.instance
            .collection('favorite')
            .doc(user.uid)
            .get();

    if (!doc.exists) {
      favoriteContent = [];
      return;
    }

    final data = doc.data();
    favoriteContent =
        List<String>.from(data?['contentIds'] ?? []).reversed.toList();
  }

  List<String> getFavoriteContentStack() {
    return List<String>.from(favoriteContent); // Defensive copy
    // return favoriteContent; // Return a copy to avoid direct modification
  }

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

  void updateByFavorite(HumorType humorType) async {
    double increment = 20;
    final currentScores = await getHumorTypeScores();

    switch (humorType) {
      case HumorType.physical:
        physicalHumorPreference = currentScores[humorType]! + increment;
        break;
      case HumorType.linguistic:
        linguisticHumorPreference = currentScores[humorType]! + increment;
        break;
      case HumorType.situational:
        situationalHumorPreference = currentScores[humorType]! + increment;
        break;
      case HumorType.critical:
        criticalHumorPreference = currentScores[humorType]! + increment;
        break;
    }

    final total =
        physicalHumorPreference +
        linguisticHumorPreference +
        situationalHumorPreference +
        criticalHumorPreference;
    double toPercentage(double score) => (score / total * 100).clamp(0, 100);

    physicalHumorPreference = toPercentage(physicalHumorPreference);
    linguisticHumorPreference = toPercentage(linguisticHumorPreference);
    situationalHumorPreference = toPercentage(situationalHumorPreference);
    criticalHumorPreference = toPercentage(criticalHumorPreference);
    await saveToFirebase();
  }

  // Update humor profile based on reaction
  void updateFromReaction(HumorType humorType, String reaction) async {
    double change = 0.0;
    final currentScores = await getHumorTypeScores();

    print('calling');

    // Define how the reaction affects humor preference
    switch (reaction) {
      case 'Not Funny':
        change = -10;
        print('reduced'); // Debugging
        break;
      case 'Meh':
        change = -5; // No change
        break;
      case 'Funny':
        change = 10; // Increase preference for humor type
        break;
      case 'Hilarious':
        change = 15; // Increase preference more
        break;
    }

    switch (humorType) {
      case HumorType.physical:
        physicalHumorPreference = currentScores[humorType]! + change;
        break;
      case HumorType.linguistic:
        linguisticHumorPreference = currentScores[humorType]! + change;
        break;
      case HumorType.situational:
        situationalHumorPreference = currentScores[humorType]! + change;
        break;
      case HumorType.critical:
        criticalHumorPreference = currentScores[humorType]! + change;
        break;
    }

    //clamp the vaues 0-100

    final total =
        physicalHumorPreference +
        linguisticHumorPreference +
        situationalHumorPreference +
        criticalHumorPreference;
    double toPercentage(double score) => (score / total * 100).clamp(0, 100);

    physicalHumorPreference = toPercentage(physicalHumorPreference);
    linguisticHumorPreference = toPercentage(linguisticHumorPreference);
    situationalHumorPreference = toPercentage(situationalHumorPreference);
    criticalHumorPreference = toPercentage(criticalHumorPreference);
    await saveToFirebase();
    // reactionHistory = [...reactionHistory, reaction];
  }

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
