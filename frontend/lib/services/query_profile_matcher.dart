import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/humor_profile.dart';
import 'package:frontend/services/engine.dart';

class QueryProfileMatcher {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> matchQueryAndProfile({
    required String userId,
    required String queryId,
  }) async {
    try {
      // Step 1: Fetch query document
      final queryDoc =
          await _firestore.collection('user_queries').doc(queryId).get();
      if (!queryDoc.exists) {
        log("Query not found for ID: $queryId");
        return [
          {
            'error': true,
            'text': 'Sorry, we couldn’t process your search. Try again.',
          },
        ];
      }

      // Step 2: Extract and clean term weights
      final Map<String, dynamic> rawWeights = Map<String, dynamic>.from(
        queryDoc.data()?['term_weights'] ?? {},
      );
      if (rawWeights.isEmpty) {
        log("Empty or missing term_weights for query $queryId");
        return [
          {'error': true, 'text': 'No valid data to search with.'},
        ];
      }

      final Map<String, double> termWeights = rawWeights.map(
        (k, v) => MapEntry(k.toLowerCase(), (v as num).toDouble()),
      );

      // Step 3: Parallel fetch of term content index
      final termDocs = await Future.wait(
        termWeights.keys.map(
          (term) => _firestore.collection('content_index').doc(term).get(),
        ),
      );

      final Set<String> matchedContentIds = {};
      for (final doc in termDocs) {
        if (doc.exists) {
          final data = doc.data();
          final List contentList = data?['content'] ?? [];
          for (final item in contentList) {
            if (item is Map && item['id'] != null) {
              matchedContentIds.add(item['id']);
            }
          }
        }
      }

      if (matchedContentIds.isEmpty) {
        log("No matches found for terms: ${termWeights.keys}");
        return [
          {'error': true, 'text': 'No matching content found.'},
        ];
      }

      // Step 4: Fetch jokes based on content IDs and profile
      final profile = HumorProfile(userId: userId);
      await profile.loadFavoriteContentStack();
      final engine = HumorEngine(profile: profile);

      final filteredContent = await engine.fetchJokesProportionally(
        contentIds: matchedContentIds.toList(),
      );

      if (filteredContent.isEmpty) {
        return [
          {'error': true, 'text': 'No personalized results found.'},
        ];
      }

      // Step 5: Score and sort results by query relevance
      filteredContent.sort((a, b) {
        final aScore = _scoreText(a['text'], termWeights);
        final bScore = _scoreText(b['text'], termWeights);
        return bScore.compareTo(aScore);
      });

      return filteredContent;
    } catch (e, stack) {
      log("Error in matchQueryAndProfile: $e\n$stack");
      return [
        {'error': true, 'text': 'An error occurred while matching your query.'},
      ];
    }
  }

  double _scoreText(String text, Map<String, double> weights) {
    double score = 0.0;
    final lowerText = text.toLowerCase();
    for (final entry in weights.entries) {
      if (lowerText.contains(entry.key)) {
        score += entry.value;
      }
    }
    return score;
  }
}
