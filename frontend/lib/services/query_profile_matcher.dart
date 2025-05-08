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

      // Step 2: Extract term weights from query
      final Map<String, dynamic> rawWeights = Map<String, dynamic>.from(
        queryDoc.data()?['term_weights'] ?? {},
      );
      log("rawWeights: $rawWeights");
      if (rawWeights.isEmpty) {
        log("Term weights missing or empty for query $queryId");
        return [
          {'error': true, 'text': 'Invalid or incomplete query data.'},
        ];
      }

      // Convert weights to lowercase keys for matching
      final Map<String, double> termWeights = rawWeights.map(
        (k, v) => MapEntry(k.toLowerCase(), (v as num).toDouble()),
      );

      // Step 3: Get matching content IDs from index
      final termDocs = await Future.wait(
        termWeights.keys.map(
          (term) => _firestore.collection('content_index').doc(term).get(),
        ),
      );

      List<String> matchedContentIds = [];

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

      matchedContentIds = matchedContentIds.toSet().toList(); 
      log("Matched content count: ${matchedContentIds.length}");

      if (matchedContentIds.isEmpty) {
        log("No content found for matched terms.");
        return [
          {'error': true, 'text': 'No matching content found for your query.'},
        ];
      }

      // Step 4: Fetch and filter content through HumorEngine
      final profile = HumorProfile(userId: userId);
      final engine = HumorEngine(profile: profile);

      final filteredContent = await engine.fetchJokesProportionally(
        contentIds: matchedContentIds,
      );

      if (filteredContent.isEmpty) {
        return [
          {
            'error': true,
            'text': 'No personalized results found for your profile.',
          },
        ];
      }

      // Step 5: Score and sort the filtered content by query relevance
      // filteredContent.sort((a, b) {
      //   final aScore = _scoreText(a['text'], termWeights);
      //   final bScore = _scoreText(b['text'], termWeights);
      //   return bScore.compareTo(aScore); // Descending
      // });
      log("Sending results to seacrh bar | from query_profile_matcher");

      return filteredContent;
    } catch (e, stack) {
      log("Exception in matchQueryAndProfile: $e\n$stack");
      return [
        {
          'error': true,
          'text': 'Unexpected error occurred while processing your query.',
        },
      ];
    }
  }

  // double _scoreText(String text, Map<String, double> weights) {
  //   double score = 0.0;
  //   final lowerText = text.toLowerCase();
  //   for (final entry in weights.entries) {
  //     if (lowerText.contains(entry.key)) {
  //       score += entry.value;
  //     }
  //   }
  //   return score;
  // }
}
