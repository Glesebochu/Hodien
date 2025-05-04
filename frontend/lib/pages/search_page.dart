import 'package:flutter/material.dart';
import '../components/search_input_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:frontend/models/humor_profile.dart';
import 'post_card.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool showNoResults = false; // 🟡 Flag to toggle "No results found"
  String? errorMessage;
  bool isSearchLoading = false;
  List<Map<String, dynamic>> searchResults = [];
  late HumorProfile profile; // Declare the profile variable as late

  @override
  void initState() {
    super.initState();
    initializeProfile(); // Call the initializer
  }

  Future<void> initializeProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle the case when no user is logged in
      setState(() {
        profile = HumorProfile(userId: 'anonymous');
      });
      return;
    }

    // Initialize the profile with the userId
    setState(() {
      profile = HumorProfile(userId: user.uid);
    });

    // Load the user's favorite content stack
    await profile.loadFavoriteContentStack();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header Row
              Center(
                child: const shadcn.Text(
                  'Explore',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const SizedBox(height: 20),

              // SearchInputBar with error callback
              SearchInputBar(
                onSearchStart: () {
                  setState(() {
                    isSearchLoading = true;
                    showNoResults = false;
                    errorMessage = null;
                    searchResults = [];
                  });
                },
                onError: (String error) {
                  setState(() {
                    showNoResults = true;
                    errorMessage = error;
                    isSearchLoading = false;
                    searchResults = [];
                  });
                },
                onSearchResults: (List<Map<String, dynamic>> results) {
                  setState(() {
                    isSearchLoading = false;
                    searchResults = results;
                  });
                },
              ),
              const SizedBox(height: 8),
              const shadcn.Divider(),
              const SizedBox(height: 12),

              Expanded(
                child: Builder(
                  builder: (_) {
                    if (isSearchLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color.fromARGB(255, 225, 204, 15),
                        ),
                      );
                    } else if (showNoResults) {
                      return Center(
                        child: shadcn.Text(
                          errorMessage ?? 'No Results Found',
                          style: const shadcn.TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    } else if (searchResults.isNotEmpty) {
                      return ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          return PostCard(
                            jokeData: searchResults[index],
                            humorProfile: profile, // Pass humor profile
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: shadcn.Text(
                          'Search results will appear here.',
                          style: shadcn.TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
