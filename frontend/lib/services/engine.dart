import 'dart:math';
import 'package:frontend/models/humor_profile.dart';
import 'package:frontend/models/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HumorEngine {
  final HumorProfile profile;
  final Random _random = Random();

  HumorEngine({required this.profile});

  // Convert between HumorType and Firestore values
  static String _toFirestoreValue(HumorType type) => type.index.toString();
  static HumorType _fromFirestoreValue(String value) =>
      HumorType.values[int.tryParse(value) ?? 0];

  Future<List<Map<String, dynamic>>> fetchJokesProportionally({
    int totalToPick = 5,
  }) async {
    try {
      // 1. Get weights from profile
      final weights = await profile.getHumorTypeScores();
      print("Weights: $weights");
      final totalWeight = weights.values.fold(0.0, (a, b) => a + b);
      print("Total Weight: $totalWeight");

      if (totalWeight == 0) {
        print("All humor weights are zero");
        return [];
      }

      // 2. Calculate proportional counts for each type
      final typeCounts = _calculateProportionalCounts(
        weights: weights,
        totalToPick: totalToPick,
      );

      // 3. Fetch jokes in batches per type to reduce reads
      final selectedJokes = await _fetchJokesByTypeCounts(typeCounts);

      // 4. Shuffle and take the required number
      selectedJokes.shuffle(_random);
      return selectedJokes.take(totalToPick).map(_formatJoke).toList();
    } catch (e, stackTrace) {
      print("Error fetching jokes: $e\n$stackTrace");
      return [];
    }
  }

  Map<HumorType, int> _calculateProportionalCounts({
    required Map<HumorType, double> weights,
    required int totalToPick,
  }) {
    final typeCounts = <HumorType, int>{};
    final totalWeight = weights.values.fold(0.0, (a, b) => a + b);

    // Initial proportional distribution
    weights.forEach((type, weight) {
      typeCounts[type] = ((weight / totalWeight) * totalToPick).round();
    });

    // Adjust counts to match exactly totalToPick
    int currentTotal = typeCounts.values.fold(0, (a, b) => a + b);
    while (currentTotal != totalToPick) {
      final diff = totalToPick - currentTotal;
      final randomType = weights.keys.elementAt(
        _random.nextInt(weights.length),
      );
      typeCounts[randomType] = (typeCounts[randomType] ?? 0) + diff.sign;
      currentTotal = typeCounts.values.fold(0, (a, b) => a + b);
    }

    return typeCounts;
  }

  Future<List<Map<String, dynamic>>> _fetchJokesByTypeCounts(
    Map<HumorType, int> typeCounts,
  ) async {
    final selectedJokes = <Map<String, dynamic>>[];

    for (final entry in typeCounts.entries) {
      if (entry.value <= 0) continue;

      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('content')
              .where('humor_type', isEqualTo: _toFirestoreValue(entry.key))
              .limit(entry.value * 3) // Fetch extra to allow random selection
              .get();

      final jokes =
          querySnapshot.docs.map((doc) => _parseJokeDoc(doc)).toList()
            ..shuffle(_random);

      selectedJokes.addAll(jokes.take(entry.value));
    }

    return selectedJokes;
  }

  Map<String, dynamic> _parseJokeDoc(QueryDocumentSnapshot doc) {
    return {
      'id': doc.id,
      'text': doc['text'],
      'humorType': _fromFirestoreValue(doc['humor_type']),
    };
  }

  Map<String, dynamic> _formatJoke(Map<String, dynamic> joke) {
    return {
      'id': joke['id'],
      'text': joke['text'],
      'humorType': joke['humorType'].toString().split('.').last,
    };
  }

  Future<Map<String, dynamic>> fetchSurpriseMeJoke() async {
    try {
      final Map<HumorType, double> weights = await profile.getHumorTypeScores();

      if (weights.values.every((w) => w == 0)) {
        print("All humor weights are zero");
        return {};
      }

      // Step 1: Find the lowest score(s)
      final minScore = weights.values.reduce((a, b) => a < b ? a : b);
      final leastPreferredTypes =
          weights.entries
              .where((entry) => entry.value == minScore)
              .map((entry) => entry.key)
              .toList();

      // Step 2: Pick one least-preferred humor type randomly
      final surpriseType =
          leastPreferredTypes[_random.nextInt(leastPreferredTypes.length)];

      // Step 3: Fetch jokes from Firestore with that type
      final querySnapshot =
          await FirebaseFirestore.instance
              .collection('content')
              .where('humor_type', isEqualTo: _toFirestoreValue(surpriseType))
              .limit(10) // Fetch a few to allow random choice
              .get();

      final jokes =
          querySnapshot.docs.map((doc) => _parseJokeDoc(doc)).toList();

      if (jokes.isEmpty) {
        print("No jokes found for surpriseType: $surpriseType");
        return {};
      }

      // Step 4: Pick one randomly and format it
      jokes.shuffle(_random);
      final joke = jokes.first;

      return _formatJoke(joke);
    } catch (e, stackTrace) {
      print("Error in fetchSurpriseMeJoke: $e\n$stackTrace");
      return {};
    }
  }
}
