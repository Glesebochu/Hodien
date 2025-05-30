import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

class TestQueryMatcher {
  late List<Map<String, dynamic>> corpus;

  final List<Map<String, dynamic>> processedQueries = [
    {
      'queryId': 'q1',
      'term_weights': {
        'road': 0.9,
        'safety': 0.8,
        'warning': 0.7,
        'accidents': 0.85,
      },
    },
    {
      'queryId': 'q2',
      'term_weights': {
        'domestic': 0.8,
        'violence': 0.9,
        'women': 0.75,
        'rights': 0.7,
      },
    },
    {
      'queryId': 'q3',
      'term_weights': {
        'addis': 0.6,
        'ababa': 0.6,
        'education': 0.9,
        'challenges': 0.8,
        'capacity': 0.7,
      },
    },
    {
      'queryId': 'q4',
      'term_weights': {
        'ethiopia': 0.6,
        'agriculture': 0.9,
        'climate': 0.8,
        'change': 0.7,
      },
    },
    {
      'queryId': 'q5',
      'term_weights': {
        'inflation': 0.9,
        'impact': 0.8,
        'urban': 0.6,
        'households': 0.75,
        'ethiopia': 0.6,
      },
    },
    {
      'queryId': 'q6',
      'term_weights': {
        'urban': 0.6,
        'road': 0.8,
        'accidents': 0.9,
        'causes': 0.7,
        'trends': 0.65,
      },
    },
    {
      'queryId': 'q7',
      'term_weights': {
        'mental': 0.9,
        'health': 0.9,
        'awareness': 0.7,
        'campaigns': 0.6,
        'east': 0.5,
        'africa': 0.5,
      },
    },
    {
      'queryId': 'q8',
      'term_weights': {
        'technology': 0.85,
        'increase': 0.7,
        'productivity': 0.8,
        'ethiopian': 0.6,
        'farming': 0.9,
      },
    },
    {
      'queryId': 'q9',
      'term_weights': {
        'foreign': 0.9,
        'currency': 0.8,
        'shortage': 0.75,
        'remittances': 0.7,
        'diaspora': 0.65,
      },
    },
    {
      'queryId': 'q10',
      'term_weights': {
        'water': 0.85,
        'resources': 0.7,
        'agriculture': 0.9,
        'services': 0.6,
        'linkage': 0.6,
      },
    },
  ];

  Future<void> loadCorpusFromAssets() async {
    print("[Log] Loading corpus from assets...");
    final String jsonString = await rootBundle.loadString(
      'assets/test_corpus.json',
    );
    final List<dynamic> jsonData = json.decode(jsonString);
    corpus = jsonData.cast<Map<String, dynamic>>();
    print("[Log] Corpus loaded: ${corpus.length} entries.");
  }

  Future<void> runMatchingAndSaveResults() async {
    print("[Log] Starting matching and scoring...");
    final List<Map<String, dynamic>> output = [];

    for (var query in processedQueries) {
      final queryId = query['queryId'];
      final termWeights = Map<String, double>.from(query['term_weights']);

      final matchedDocs = _matchDocuments(termWeights);
      final scoredDocs = _scoreDocuments(matchedDocs, termWeights);
      scoredDocs.sort((a, b) => b['score'].compareTo(a['score']));

      output.add({'queryId': queryId, 'results': scoredDocs});
      print(
        "[Log] Processed query $queryId — matched ${scoredDocs.length} docs.",
      );
    }

    final file = File('matcher_output.json');
    final now = DateTime.now();
    final timestamp = '--- Results generated at ${now.toLocal()} ---\n';
    final dataBlock = JsonEncoder.withIndent('  ').convert(output);

    await file.writeAsString('$timestamp$dataBlock\n\n', mode: FileMode.append);
    print("[Log] Output written to matcher_output.json");
  }

  List<Map<String, dynamic>> _matchDocuments(Map<String, double> termWeights) {
    return corpus.where((doc) {
      final text = doc['text'].toString().toLowerCase();
      return termWeights.keys.any((term) => text.contains(term));
    }).toList();
  }

  List<Map<String, dynamic>> _scoreDocuments(
    List<Map<String, dynamic>> docs,
    Map<String, double> termWeights,
  ) {
    return docs.map((doc) {
      final text = doc['text'].toString().toLowerCase();
      double score = 0.0;
      for (var term in termWeights.keys) {
        if (text.contains(term)) {
          score += termWeights[term]!;
        }
      }

      return {'id': doc['id'], 'text': doc['text'], 'score': score};
    }).toList();
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final matcher = TestQueryMatcher();
  await matcher.loadCorpusFromAssets();
  await matcher.runMatchingAndSaveResults();
}
