import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  List<Map<String, dynamic>> favoriteJokes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchFavoriteJokesFromFirestore();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Favorites")),
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
            onPressed: () {
              // Force a complete refresh by resetting the state
              setState(() {
                expandedIndex = null; // Collapse the view
                isLoading = true; // Show loading indicator
              });

              // Reload the data
              _fetchFavoriteJokesFromFirestore().then((_) {
                setState(() {
                  isLoading = false; // Hide loading indicator
                });
              });
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text("Back to Favorites"),
          ),
        ),
      ],
    );
  }
}
