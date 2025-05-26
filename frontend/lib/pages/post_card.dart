import 'package:flutter/material.dart';
import 'package:frontend/services/reactions.dart';
import 'package:frontend/models/humor_profile.dart';
import 'package:frontend/models/constants.dart';

class PostCard extends StatefulWidget {
  final Map<String, dynamic> jokeData;
  final HumorProfile humorProfile;

  const PostCard({
    super.key,
    required this.jokeData,
    required this.humorProfile,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool isFavorite = false;
  late HumorType currentHumorType;

  @override
  void initState() {
    super.initState();
    currentHumorType = HumorType.values.firstWhere(
      (e) => e.toString() == 'HumorType.${widget.jokeData['humorType']}',
      orElse:
          () => HumorType.physical, // Fallback to default if invalid humor type
    );

    // Initialize favorite status from the humorProfile
    String jokeId = widget.jokeData['id'].toString();
    // Correctly check if the joke is in the favorites stack
    isFavorite = widget.humorProfile.getFavoriteContentStack().contains(jokeId);
  }

  // Function to toggle favorite and update humor profile
  void toggleFavorite() {
    setState(() {
      isFavorite = !isFavorite; // Toggle the favorite status
    });

    widget.humorProfile.updateByFavorite(currentHumorType);

    String jokeId = widget.jokeData['id'].toString();

    // Add the joke ID to the favorite stack
    if (isFavorite) {
      print("Adding joke ID $jokeId to favorites");
      widget.humorProfile.addFavoriteById(jokeId);
    } else {
      print("Removing joke ID $jokeId from favorites");
      widget.humorProfile.removeFavoriteById(jokeId);
    }
  }

  // Function to handle reaction update and update humor profile
  void handleReaction(String reactionType) {
    // Call the updateFromReaction function from HumorProfile
    widget.humorProfile.updateFromReaction(currentHumorType, reactionType);
  }

  String toSentenceCase(String text) {
    if (text.isEmpty) return text;

    // Ensure consistent spacing after periods
    text = text.trim().replaceAll(RegExp(r'\s+'), ' ');

    final buffer = StringBuffer();
    bool capitalizeNext = true;

    for (int i = 0; i < text.length; i++) {
      final char = text[i];

      if (capitalizeNext && RegExp(r'[a-zA-Z]').hasMatch(char)) {
        buffer.write(char.toUpperCase());
        capitalizeNext = false;
      } else {
        buffer.write(char);
      }

      if (char == '.' || char == '!' || char == '?') {
        capitalizeNext = true;
      }
    }

    return buffer.toString();
  }

  String toTitleCase(String text) {
    if (text.isEmpty) return text;

    return text
        .toLowerCase()
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? '${word[0].toUpperCase()}${word.substring(1)}'
                  : '',
        )
        .join(' ');
  }

  double estimateCardHeight1(String text) {
    int wordCount = text.split(' ').length;
    if (wordCount < 10) return 0.3;
    if (wordCount < 13) return 0.33;
    if (wordCount < 16) return 0.36;
    if (wordCount < 19) return 0.39;
    if (wordCount < 24) return 0.42;
    if (wordCount < 30) return 0.45;
    if (wordCount < 35) return 0.5;
    return 0.52;
  }

  double estimateCardHeight(String text) {
    int charCount = text.length;

    if (charCount < 70) return 0.33;
    if (charCount < 90) return 0.37;
    if (charCount < 120) return 0.42;
    if (charCount < 150) return 0.46;
    if (charCount < 200) return 0.5;
    if (charCount < 250) return 0.52;
    if (charCount < 300) return 0.55;
    return 0.58;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.grey[900]
                  : const Color.fromARGB(255, 147, 146, 146),
          borderRadius: BorderRadius.circular(24),
        ),
        height:
            MediaQuery.of(context).size.height *
            (estimateCardHeight(widget.jokeData['text'])),
        //height: estimateCardHeight(widget.jokeData['text']),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Save button (with favorite toggle logic)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.bookmark : Icons.bookmark_border,
                    color:
                        isFavorite
                            ? Colors.yellow
                            : isDarkMode
                            ? Colors.white
                            : Colors.black,
                  ),
                  onPressed: toggleFavorite, // Trigger toggle favorite
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: toSentenceCase(widget.jokeData['text']) + ' ',
                        style: TextStyle(
                          fontSize: 23,
                          color: isDarkMode ? Colors.white : Colors.black,
                          height: 1.6,
                        ),
                      ),
                      TextSpan(
                        text:
                            '#${widget.jokeData['humorType']} #${widget.jokeData['humorScore']}',
                        style: TextStyle(
                          fontSize: 16, // Smaller than main text
                          color: Colors.yellow[700], // Yellow hashtag
                          height: 1.6,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Reaction(
                  emoji: '😒',
                  label: 'Not Funny',
                  onTap: () => handleReaction('Not Funny'),
                ),
                Reaction(
                  emoji: '😐',
                  label: 'Meh',
                  onTap: () => handleReaction('Meh'),
                ),
                Reaction(
                  emoji: '😂',
                  label: 'Funny',
                  onTap: () => handleReaction('Funny'),
                ),
                Reaction(
                  emoji: '🤣',
                  label: 'Hilarious',
                  onTap: () => handleReaction('Hilarious'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
