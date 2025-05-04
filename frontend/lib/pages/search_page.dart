import 'package:flutter/material.dart';
import '../components/search_input_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:frontend/models/humor_profile.dart';
import 'post_card.dart';

class SearchPage extends StatefulWidget {
  final HumorProfile profile; // Declare the profile variable
  const SearchPage({
    super.key,
    required this.profile,
  }); // Constructor with profile
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  bool showNoResults = false; // 🟡 Flag to toggle "No results found"
  String? errorMessage;
  bool isSearchLoading = false;
  List<Map<String, dynamic>> searchResults = [];
  @override
  bool get wantKeepAlive => true; // Keep the state alive when navigating away

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
                            humorProfile: widget.profile, // Pass humor profile
                          );
                        },
                      );
                    } else {
                      return const Center(
                        child: shadcn.Text(
                          'A spark of humor, a slice of soul - discover joy tailored just for you...',
                          style: shadcn.TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 0.5,
                            letterSpacing: 0.5,
                            fontFamily: 'Helvetica',
                            color: Color.fromARGB(255, 176, 173, 114),
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
