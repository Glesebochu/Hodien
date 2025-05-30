import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:frontend/models/humor_profile.dart';
import 'post_card.dart';
import 'package:google_fonts/google_fonts.dart';

class FavoriteContentPage extends StatefulWidget {
  final HumorProfile humorProfile;

  const FavoriteContentPage({super.key, required this.humorProfile});

  @override
  State<FavoriteContentPage> createState() => _FavoriteContentPageState();
}

class _FavoriteContentPageState extends State<FavoriteContentPage> {
  int? expandedIndex;
  List<Map<String, dynamic>> favoriteJokes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteJokesFromFirestore();
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

  Map<String, dynamic> normalizeJokeData(Map<String, dynamic> rawJoke) {
    final dynamic humorTypeValue =
        rawJoke['humorType'] ?? rawJoke['humor_type'];
    return {
      'id': rawJoke['id'],
      'text': rawJoke['text'],
      'humorType': _getHumorTypeLabel(humorTypeValue),
      'humorScore': rawJoke['humor_type_score'] ?? rawJoke['humorScore'],
    };
  }

  Future<void> _fetchFavoriteJokesFromFirestore() async {
    List<String> favoriteIds = widget.humorProfile.getFavoriteContentStack();

    if (favoriteIds.isEmpty) {
      setState(() {
        favoriteJokes = [];
        isLoading = false;
      });
      return;
    }

    try {
      final firestore = FirebaseFirestore.instance;
      final jokesRef = firestore.collection('content');

      // Fetch each favorite joke by ID
      final futures = favoriteIds.map((id) => jokesRef.doc(id).get());
      final snapshots = await Future.wait(futures);

      final jokes =
          snapshots
              .where((snap) => snap.exists)
              .map((snap) => {'id': snap.id, ...snap.data()!})
              .toList();

      setState(() {
        favoriteJokes = jokes;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching favorite jokes: $e');
      setState(() {
        favoriteJokes = [];
        isLoading = false;
      });
    }
  }

  String _getHumorTypeLabel(dynamic type) {
    switch (type.toString()) {
      case '1':
        return 'physical';
      case '2':
        return 'linguistic';
      case '3':
        return 'situational';
      case '4':
        return 'critical';
      default:
        return 'unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Saved Favorites',
          style: GoogleFonts.varela(
            fontSize: 16,
            //color: widget.isDarkMode ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : favoriteJokes.isEmpty
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
        childAspectRatio: 1.2,
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
                      : const Color.fromARGB(255, 186, 186, 186),
            ), // Match light bg
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Vertically center
              crossAxisAlignment: CrossAxisAlignment.start,
              //crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    toSentenceCase(joke['text']), // Show a truncated joke text
                    //textAlign: TextAlign.center,
                    maxLines: 5,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      color: isDarkMode ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color:
                            isDarkMode
                                ? Colors.yellow[800]?.withOpacity(0.15)
                                : const Color.fromARGB(255, 255, 236, 179),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${((joke['humor_type_score']) * 100).toStringAsFixed(0)}% ${toTitleCase(_getHumorTypeLabel(joke['humor_type']))}',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              isDarkMode
                                  ? Colors.yellow[700]
                                  : const Color.fromARGB(255, 94, 70, 9),
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpandedCard(Map<String, dynamic> joke, int index) {
    return Expanded(
      // Fills the vertical space from parent
      child: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Ensures the column shrinks to fit its content
          children: [
            PostCard(
              jokeData: normalizeJokeData(joke),
              humorProfile: widget.humorProfile,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  expandedIndex = null;
                  isLoading = true;
                });

                _fetchFavoriteJokesFromFirestore().then((_) {
                  setState(() {
                    isLoading = false;
                  });
                });
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text("Back to Favorites"),
            ),
          ],
        ),
      ),
    );
  }
}
