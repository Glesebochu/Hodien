import 'dart:math';
import 'package:frontend/models/humor_profile.dart';
import 'package:frontend/models/constants.dart';

class HumorEngine {
  final HumorProfile profile;

  HumorEngine({required this.profile});

  Future<List<Map<String, dynamic>>> fetchJokesProportionally({
    int totalToPick = 5,
  }) async {
    try {
      if (_embeddedJokes.isEmpty) {
        print("No jokes available in _embeddedJokes");
        return [];
      }

      final random = Random();

      // Step 1: Convert raw joke list to parsed structure
      final jokes =
          _embeddedJokes.map((j) {
            final humorType = HumorType.values.firstWhere(
              (e) =>
                  e.name.toLowerCase() ==
                  j['humorType'].toString().toLowerCase(),
              orElse: () => HumorType.physical, // fallback
            );
            return {'id': j['id'], 'text': j['text'], 'humorType': humorType};
          }).toList();

      // Step 2: Get weights from profile
      final Map<HumorType, double> weights = await profile.getHumorTypeScores();
      final totalWeight = weights.values.fold(0.0, (a, b) => a + b);

      if (totalWeight == 0) {
        print("All humor weights are zero");
        return [];
      }

      // Step 3: Calculate proportional count for each humor type
      final Map<HumorType, int> typeCounts = {};
      weights.forEach((type, weight) {
        typeCounts[type] = ((weight / totalWeight) * totalToPick).round();
      });

      // Fix total count (ensure exactly totalToPick jokes)
      int currentTotal = typeCounts.values.fold(0, (a, b) => a + b);
      while (currentTotal != totalToPick) {
        final diff = totalToPick - currentTotal;
        final keys = typeCounts.keys.toList();
        final randomType = keys[random.nextInt(keys.length)];
        typeCounts[randomType] = (typeCounts[randomType] ?? 0) + diff.sign;
        currentTotal = typeCounts.values.fold(0, (a, b) => a + b);
      }

      // Step 4: Select jokes proportionally
      final List<Map<String, dynamic>> selected = [];
      typeCounts.forEach((type, count) {
        final jokesForType =
            jokes.where((j) => j['humorType'] == type).toList();
        jokesForType.shuffle(random);
        selected.addAll(jokesForType.take(count));
      });

      // Return structured jokes (id, humorType, text)
      return selected
          .map(
            (e) => {
              'id': e['id'],
              'humorType':
                  e['humorType'].toString().split('.').last, // Enum to string
              'text': e['text'],
            },
          )
          .toList();
    } catch (e) {
      print("Error fetching jokes: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> fetchSurpriseMeJoke() async {
    try {
      if (_embeddedJokes.isEmpty) {
        print("No jokes available in _embeddedJokes");
        return {};
      }
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
      final random = Random();
      final surpriseType =
          leastPreferredTypes[random.nextInt(leastPreferredTypes.length)];

      // Step 3: Try to find a random joke of that type
      final jokesShuffled = List<Map<String, dynamic>>.from(_embeddedJokes)
        ..shuffle(random);
      for (final joke in jokesShuffled) {
        final humorType = HumorType.values.firstWhere(
          (e) =>
              e.name.toLowerCase() ==
              joke['humorType'].toString().toLowerCase(),
          orElse: () => HumorType.physical,
        );

        if (humorType == surpriseType) {
          return {
            'id': joke['id'],
            'humorType': humorType.name,
            'text': joke['text'],
          };
        }
      }

      print("Couldn't find a surprise joke for type $surpriseType");
      return {};
    } catch (e) {
      print("Error in surpriseMe: $e");
      return {};
    }
  }
}

final List<Map<String, dynamic>> _embeddedJokes = [
  {
    "id": 1,
    "text": "Why don’t skeletons fight each other? They don’t have the guts.",
    "isHumorous": true,
    "humorScore": 8.5,
    "humorType": "Physical",
    "topics": ["skeleton", "death", "humor"],
    "tone": "Funny",
    "emojiPresence": true,
    "textLength": 56,
    "mediaType": "Text",
  },
  {
    "id": 2,
    "text":
        "I told my wife she was drawing her eyebrows too high. She looked surprised.",
    "isHumorous": true,
    "humorScore": 7.5,
    "humorType": "Situational",
    "topics": ["wife", "eyebrows", "humor"],
    "tone": "Funny",
    "emojiPresence": false,
    "textLength": 87,
    "mediaType": "Text",
  },
  {
    "id": 3,
    "text":
        "Parallel lines have so much in common. It’s a shame they’ll never meet.",
    "isHumorous": true,
    "humorScore": 8.0,
    "humorType": "Critical",
    "topics": ["math", "geometry", "humor"],
    "tone": "Dry",
    "emojiPresence": false,
    "textLength": 83,
    "mediaType": "Text",
  },
  {
    "id": 4,
    "text": "Why do cows wear bells? Because their horns don’t work.",
    "isHumorous": true,
    "humorScore": 6.5,
    "humorType": "Physical",
    "topics": ["animals", "cows", "humor"],
    "tone": "Silly",
    "emojiPresence": false,
    "textLength": 70,
    "mediaType": "Text",
  },
  {
    "id": 5,
    "text":
        "I would tell you a joke about an elevator, but it’s an uplifting experience.",
    "isHumorous": true,
    "humorScore": 7.8,
    "humorType": "Situational",
    "topics": ["elevator", "humor"],
    "tone": "Dry",
    "emojiPresence": false,
    "textLength": 88,
    "mediaType": "Text",
  },
  {
    "id": 6,
    "text": "What’s orange and sounds like a parrot? A carrot.",
    "isHumorous": true,
    "humorScore": 6.8,
    "humorType": "Physical",
    "topics": ["food", "animals", "humor"],
    "tone": "Silly",
    "emojiPresence": false,
    "textLength": 66,
    "mediaType": "Text",
  },
  {
    "id": 7,
    "text":
        "I told my computer I needed a break, and now it won’t stop sending me Kit-Kats.",
    "isHumorous": true,
    "humorScore": 8.1,
    "humorType": "Critical",
    "topics": ["technology", "computers", "jokes"],
    "tone": "Funny",
    "emojiPresence": true,
    "textLength": 97,
    "mediaType": "Text",
  },
  {
    "id": 8,
    "text":
        "I’m reading a book about anti-gravity. It’s impossible to put down!",
    "isHumorous": true,
    "humorScore": 8.2,
    "humorType": "Linguistic",
    "topics": ["books", "science", "humor"],
    "tone": "Dry",
    "emojiPresence": false,
    "textLength": 90,
    "mediaType": "Text",
  },
  {
    "id": 9,
    "text": "Why don’t oysters share their pearls? Because they’re shellfish.",
    "isHumorous": true,
    "humorScore": 7.2,
    "humorType": "Situational",
    "topics": ["oysters", "seafood", "humor"],
    "tone": "Silly",
    "emojiPresence": false,
    "textLength": 80,
    "mediaType": "Text",
  },
  {
    "id": 10,
    "text": "I used to be a baker, but I couldn’t make enough dough.",
    "isHumorous": true,
    "humorScore": 7.6,
    "humorType": "Linguistic",
    "topics": ["baking", "food", "humor"],
    "tone": "Dry",
    "emojiPresence": false,
    "textLength": 77,
    "mediaType": "Text",
  },
  {
    "id": 11,
    "text": "I’m on a seafood diet. I see food, and I eat it.",
    "isHumorous": true,
    "humorScore": 8.0,
    "humorType": "Physical",
    "topics": ["food", "diet", "humor"],
    "tone": "Funny",
    "emojiPresence": true,
    "textLength": 72,
    "mediaType": "Text",
  },
  {
    "id": 12,
    "text":
        "I told my friend 10 jokes to make him laugh. Sadly, no pun in ten did.",
    "isHumorous": true,
    "humorScore": 7.9,
    "humorType": "Situational",
    "topics": ["jokes", "friends", "humor"],
    "tone": "Dry",
    "emojiPresence": false,
    "textLength": 93,
    "mediaType": "Text",
  },
  {
    "id": 13,
    "text": "The rotation of the earth really makes my day.",
    "isHumorous": true,
    "humorScore": 7.1,
    "humorType": "Critical",
    "topics": ["science", "earth", "humor"],
    "tone": "Dry",
    "emojiPresence": false,
    "textLength": 70,
    "mediaType": "Text",
  },
  {
    "id": 14,
    "text":
        "Did you hear about the mathematician who’s afraid of negative numbers? He’ll stop at nothing to avoid them.",
    "isHumorous": true,
    "humorScore": 8.4,
    "humorType": "Critical",
    "topics": ["math", "numbers", "humor"],
    "tone": "Funny",
    "emojiPresence": false,
    "textLength": 105,
    "mediaType": "Text",
  },
  {
    "id": 15,
    "text":
        "I’m friends with all electricians. We have such good current connections.",
    "isHumorous": true,
    "humorScore": 7.7,
    "humorType": "Situational",
    "topics": ["electricians", "connections", "humor"],
    "tone": "Silly",
    "emojiPresence": false,
    "textLength": 90,
    "mediaType": "Text",
  },
];
