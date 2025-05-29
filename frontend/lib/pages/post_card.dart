import 'package:flutter/material.dart';
import 'package:frontend/services/reactions.dart';
import 'package:frontend/models/humor_profile.dart';
import 'package:frontend/models/constants.dart';
import 'package:google_fonts/google_fonts.dart';

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
    final String jokeText = widget.jokeData['text'];
    final int charCount = jokeText.length;
    const int scrollThreshold = 300; // Adjust as needed

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color:
              isDarkMode
                  ? Colors.grey[900]
                  : const Color.fromARGB(255, 189, 188, 188),
          borderRadius: BorderRadius.circular(24),
        ),
        // Remove fixed height, let content dictate height
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
            LayoutBuilder(
              builder: (context, constraints) {
                // If text is long, constrain height and enable scroll
                if (charCount > scrollThreshold) {
                  return ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.33,
                    ),
                    child: SingleChildScrollView(
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: '${toSentenceCase(jokeText)} ',
                              style: GoogleFonts.varela(
                                fontSize: 23,
                                color: isDarkMode ? Colors.white : Colors.black,
                                height: 1.6,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                            WidgetSpan(
                              alignment: PlaceholderAlignment.middle,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isDarkMode
                                          ? Colors.yellow[800]?.withOpacity(
                                            0.15,
                                          )
                                          : const Color.fromARGB(
                                            255,
                                            255,
                                            236,
                                            179,
                                          ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '${(widget.jokeData['humorScore'] * 100).toStringAsFixed(0)}% ${toTitleCase(widget.jokeData['humorType'])}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                        isDarkMode
                                            ? Colors.yellow[700]
                                            : const Color.fromARGB(
                                              255,
                                              94,
                                              70,
                                              9,
                                            ),
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  // Short/medium text: no scroll, auto-size
                  return RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${toSentenceCase(jokeText)} ',
                          style: GoogleFonts.varela(
                            fontSize: 23,
                            color: isDarkMode ? Colors.white : Colors.black,
                            height: 1.6,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  isDarkMode
                                      ? Colors.yellow[800]?.withOpacity(0.15)
                                      : const Color.fromARGB(
                                        255,
                                        255,
                                        236,
                                        179,
                                      ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(widget.jokeData['humorScore'] * 100).toStringAsFixed(0)}% ${toTitleCase(widget.jokeData['humorType'])}',
                              style: TextStyle(
                                fontSize: 16,
                                color:
                                    isDarkMode
                                        ? Colors.yellow[700]
                                        : const Color.fromARGB(255, 94, 70, 9),
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              },
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
