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
        height: MediaQuery.of(context).size.height * 0.7,
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
                child: Text(
                  widget.jokeData['text'], // Display the joke text
                  style: TextStyle(
                    fontSize: 23,
                    color: isDarkMode ? Colors.white : Colors.black,
                    height: 1.6,
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
