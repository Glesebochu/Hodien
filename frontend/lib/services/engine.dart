import 'dart:math';
import 'package:frontend/models/humor_profile.dart';
import 'package:frontend/models/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HumorEngine {
  final HumorProfile profile;
  final Random _random = Random();
  final FirebaseFirestore firestore;

  HumorEngine({required this.profile, FirebaseFirestore? firestore})
    : firestore = firestore ?? FirebaseFirestore.instance;

  // Convert between HumorType and Firestore values
  static String _toFirestoreValue(HumorType type) => type.index.toString();
  static HumorType _fromFirestoreValue(String value) =>
      HumorType.values[int.tryParse(value) ?? 0];

  Future<List<Map<String, dynamic>>> fetchJokesProportionally({
    int totalToPick = 5,
    List<String>? contentIds,
    Map<HumorType, double>? overrideWeights,
  }) async {
    try {
      // 1. Get weights from profile
      final weights = overrideWeights ?? await profile.getHumorTypeScores();
      //final weights = await profile.getHumorTypeScores();
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
      print("Calculated Type Counts");

      // 3. Fetch jokes in batches per type to reduce reads
      final selectedJokes = await _fetchJokesByTypeCounts(
        typeCounts,
        contentIds,
      );
      print("Fetched Jokes: count ${selectedJokes.length}");
      // 4. Shuffle and take the required number
      selectedJokes.shuffle(_random);

      if (contentIds != null) {
        // Return everything if contentIds were passed
        return selectedJokes.map(_formatJoke).toList();
      } else {
        // Otherwise, limit to totalToPick
        return selectedJokes.take(totalToPick).map(_formatJoke).toList();
      }
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

  Map<String, dynamic> _parseJokeDoc(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    return {
      'id': doc.id,
      'text': doc['text'],
      'humorType': _fromFirestoreValue(doc['humor_type']),
    };
  }

  Future<List<Map<String, dynamic>>> _fetchJokesByTypeCounts(
    Map<HumorType, int> typeCounts,
    List<String>? contentIds,
  ) async {
    final selectedJokes = <Map<String, dynamic>>[];

    for (final entry in typeCounts.entries) {
      if (entry.value <= 0) continue;
      final humorType = entry.key;
      final countNeeded = entry.value;

      if (contentIds != null && contentIds.isNotEmpty) {
        // 🔁 Fetch ALL docs in parallel
        final docs = await Future.wait(
          contentIds.map((id) => firestore.collection('content').doc(id).get()),
        );
        // 🔍 Filter by humor type
        final matchingDocs =
            docs.where((doc) {
              final data = doc.data();
              return doc.exists &&
                  data != null &&
                  data['humor_type'] == _toFirestoreValue(humorType);
            }).toList();

        // 🎯 Convert + take the needed amount
        final jokes =
            matchingDocs.map(_parseJokeDoc).toList()..shuffle(_random);
        selectedJokes.addAll(jokes.take(countNeeded));
      } else {
        // 🔄 Use normal Firestore query
        final querySnapshot =
            await firestore
                .collection('content')
                .where('humor_type', isEqualTo: _toFirestoreValue(humorType))
                .limit(countNeeded * 3)
                .get();

        final jokes =
            querySnapshot.docs.map(_parseJokeDoc).toList()..shuffle(_random);
        selectedJokes.addAll(jokes.take(countNeeded));
      }
    }

    return selectedJokes;
  }

  Map<String, dynamic> _formatJoke(Map<String, dynamic> joke) {
    return {
      'id': joke['id'],
      'text': joke['text'],
      'humorType': joke['humorType'].toString().split('.').last,
    };
  }

  Future<Map<String, dynamic>> fetchSurpriseMeJoke({
    Map<HumorType, double>? overrideWeights,
  }) async {
    try {
      final weights = overrideWeights ?? await profile.getHumorTypeScores();
      //final Map<HumorType, double> weights = await profile.getHumorTypeScores();

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
          await firestore
              .collection('content')
              .where('humor_type', isEqualTo: _toFirestoreValue(surpriseType))
              .limit(10)
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
