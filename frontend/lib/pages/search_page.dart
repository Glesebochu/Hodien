import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../components/search_input_bar.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import 'package:frontend/models/humor_profile.dart';
import '../services/query_profile_matcher.dart';
import 'post_card.dart';

class SearchPage extends StatefulWidget {
  final HumorProfile? profile;
  const SearchPage({super.key, this.profile});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  late HumorProfile _profile;
  bool showNoResults = false;
  String? errorMessage;
  bool isSearchLoading = false;
  bool isLoadingMore = false;
  List<Map<String, dynamic>> searchResults = [];
  final ScrollController _scrollController = ScrollController();
  String? lastQueryId;

  @override
  void initState() {
    super.initState();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      throw Exception("User not logged in.");
    }
    _profile = widget.profile ?? HumorProfile(userId: user.uid);

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoadingMore) {
        _fetchMoreSearchResults();
      }
    });
  }

  Future<void> _fetchMoreSearchResults() async {
    if (lastQueryId == null) return;
    setState(() => isLoadingMore = true);

    try {
      final results = await QueryProfileMatcher().matchQueryAndProfile(
        userId: _profile.userId,
        queryId: lastQueryId!,
      );
      if (results.isNotEmpty && results.first['error'] != true) {
        setState(() {
          searchResults.addAll(results);
        });
      }
    } catch (_) {
    } finally {
      setState(() => isLoadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const Center(
              child: shadcn.Text(
                'Explore',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),
            SearchInputBar(
              onSearchStart: () {
                setState(() {
                  isSearchLoading = true;
                  showNoResults = false;
                  errorMessage = null;
                  searchResults = [];
                  lastQueryId = null;
                });
              },
              onError: (String error) {
                setState(() {
                  showNoResults = true;
                  errorMessage = error;
                  isSearchLoading = false;
                  searchResults = [];
                  lastQueryId = null;
                });
              },
              onSearchResults: (List<Map<String, dynamic>> results) {
                setState(() {
                  isSearchLoading = false;
                  searchResults = results;
                  if (results.isNotEmpty &&
                      results.first.containsKey("queryId")) {
                    lastQueryId = results.first["queryId"];
                  }
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
                          color: Color.fromARGB(255, 176, 173, 114),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    );
                  } else if (searchResults.isNotEmpty) {
                    return ListView.builder(
                      controller: _scrollController,
                      itemCount: searchResults.length + 1,
                      itemBuilder: (context, index) {
                        if (index == searchResults.length) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child:
                                  isLoadingMore
                                      ? const CircularProgressIndicator()
                                      : const Text(
                                        'You have reached the end',
                                        style: TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            176,
                                            173,
                                            114,
                                          ),
                                        ),
                                      ),
                            ),
                          );
                        }
                        return PostCard(
                          jokeData: searchResults[index],
                          humorProfile: _profile,
                        );
                      },
                    );
                  } else {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.0),
                        child: shadcn.Text(
                          'A spark of humor, a slice of soul - discover joy tailored just for you...',
                          textAlign: TextAlign.center,
                          style: shadcn.TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                            letterSpacing: 0.5,
                            fontFamily: 'Helvetica',
                            color: Color.fromARGB(255, 176, 173, 114),
                          ),
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
