import 'package:flutter/material.dart';
import 'package:frontend/models/humor_profile.dart';
import 'post_card.dart';

class FavoriteContentPage extends StatefulWidget {
  final HumorProfile humorProfile;

  const FavoriteContentPage({super.key, required this.humorProfile});

  @override
  State<FavoriteContentPage> createState() => _FavoriteContentPageState();
}

class _FavoriteContentPageState extends State<FavoriteContentPage> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    List<String> favoriteIds = widget.humorProfile.getFavoriteContentStack();

    // Filter the embedded jokes
    List<Map<String, dynamic>> favoriteJokes =
        _embeddedJokes.where((joke) {
          return favoriteIds.contains(joke['id'].toString());
        }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Saved Favorites")),
      body:
          favoriteJokes.isEmpty
              ? const Center(child: Text("No favorites yet"))
              : AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child:
                    expandedIndex == null
                        ? _buildMinimizedGrid(favoriteJokes)
                        : _buildExpandedCard(
                          favoriteJokes[expandedIndex!],
                          expandedIndex!,
                        ),
              ),
    );
  }

  Widget _buildMinimizedGrid(List<Map<String, dynamic>> jokes) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GridView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: jokes.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, // 2 per row → 4 per screen
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemBuilder: (context, index) {
        final joke = jokes[index]; // Get the joke data

        // Pass the joke data and humor profile to PostCard
        return GestureDetector(
          onTap: () => setState(() => expandedIndex = index),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color:
                  isDarkMode
                      ? Colors.grey[900] // Match PostCard dark bg
                      : const Color.fromARGB(255, 147, 146, 146),
            ), // Match light bg
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    joke['text'], // Show a truncated joke text
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Text(
                //"Type: ${joke['humorType']}", // Display humor type
                // style: const TextStyle(fontSize: 12),
                // ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedCard(Map<String, dynamic> joke, int index) {
    // Pass the joke data and humor profile to PostCard when expanded
    return Column(
      children: [
        Expanded(
          child: PostCard(
            jokeData: joke, // Pass the full joke data to PostCard
            humorProfile: widget.humorProfile, // Pass the humor profile
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: ElevatedButton.icon(
            onPressed: () => setState(() => expandedIndex = null),
            icon: const Icon(Icons.arrow_back),
            label: const Text("Back to Favorites"),
          ),
        ),
      ],
    );
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
