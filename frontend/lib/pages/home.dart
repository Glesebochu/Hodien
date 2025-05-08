import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'post_card.dart';
import '../services/engine.dart';
import 'package:frontend/models/humor_profile.dart';
import 'dart:ui';
import 'favorite_content.dart';
import '../utils/theme.dart';
import 'settings.dart';
import 'search_page.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isDarkMode = false;

  void toggleTheme() {
    setState(() {
      isDarkMode = !isDarkMode;
    });
  }

  List<Map<String, dynamic>> jokes = []; // List of jokes
  bool showSurprise = false;
  Map<String, dynamic>? surpriseJoke;
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();
  int _selectedTabIndex = 0;

  late HumorProfile profile; // Declare the profile variable as late
  late HumorEngine engine;

  @override
  void initState() {
    super.initState();
    _initializeProfile();
    //await HumorProfile.loadFavoriteContentStack(); // Load favorite content stack
  }

  Future<void> _initializeProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Handle case when no user is logged in
      print('No user logged in');
      return;
    }
    // Initialize the profile with the userId
    setState(() {
      profile = HumorProfile(userId: user.uid);
    });
    await profile.loadFavoriteContentStack();
    // Initialize the humor engine after profile is set
    engine = HumorEngine(profile: profile);

    // Fetch jokes after profile and engine are initialized
    fetchMoreJokes();

    // Infinite scroll logic
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !isLoading) {
        fetchMoreJokes();
      }
    });
  }

  Future<void> showSurpriseJoke() async {
    final joke = await engine.fetchSurpriseMeJoke();
    setState(() {
      surpriseJoke = joke;
      showSurprise = true;
    });
  }

  // Safely fetch more jokes and handle errors gracefully
  Future<void> fetchMoreJokes() async {
    if (isLoading) return; // Prevent fetching when already loading

    setState(() => isLoading = true);

    try {
      final newJokes = await engine.fetchJokesProportionally();
      if (newJokes.isNotEmpty) {
        setState(() {
          jokes.addAll(newJokes); // Add jokes to the list
        });
      } else {
        print("No jokes fetched. End of feed?");
      }
    } catch (e) {
      print("Error fetching jokes: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  // Build the feed view with jokes
  Widget _buildFeedView() {
    return ListView.builder(
      controller: _scrollController,
      itemCount: jokes.length + 1,
      itemBuilder: (context, index) {
        if (index == jokes.length) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child:
                  isLoading
                      ? const CircularProgressIndicator()
                      : const Text(
                        'You have reached the end',
                        style: TextStyle(color: Colors.white70),
                      ),
            ),
          );
        }

        return PostCard(
          jokeData: jokes[index], // Pass joke data
          humorProfile: profile, // Pass humor profile
        );
      },
    );
  }

  // Build the body of the page
  Widget _buildBody() {
    Color textColor =
        Theme.of(context).brightness == Brightness.dark
            ? AppTheme.darkTheme.textTheme.bodyLarge?.color ?? Colors.white
            : AppTheme.lightTheme.textTheme.bodyLarge?.color ?? Colors.black;

    switch (_selectedTabIndex) {
      case 0:
        return _buildFeedView();
      case 1:
        return SearchPage(profile: profile);
      case 2:
        return FavoriteContentPage(humorProfile: profile);
      case 3:
        return SettingsPage();
      default:
        return _buildFeedView();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Ho',
                style: GoogleFonts.pacifico(
                  fontSize: 28,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
              TextSpan(
                text: 'diEn',
                style: GoogleFonts.pacifico(
                  fontSize: 28,
                  color: Colors.yellow[700],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isDarkMode ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: Stack(
        children: [
          _buildBody(),
          if (_selectedTabIndex == 0)
            Positioned(
              top: 16,
              left: 16,
              child: FloatingActionButton(
                heroTag: 'surpriseBtn',
                backgroundColor: Colors.yellow[700],
                onPressed: showSurpriseJoke,
                child: const Icon(Icons.auto_awesome),
              ),
            ),
          if (showSurprise && surpriseJoke != null) ...[
            GestureDetector(
              onTap: () => setState(() => showSurprise = false),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                child: Container(color: Colors.black.withOpacity(0.4)),
              ),
            ),
            Center(
              child: AnimatedScale(
                scale: showSurprise ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: PostCard(jokeData: surpriseJoke!, humorProfile: profile),
              ),
            ),
          ],
        ],
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedTabIndex,
        onTap: (index) => setState(() => _selectedTabIndex = index),
        selectedItemColor: isDarkMode ? Colors.amber : Colors.black,
        unselectedItemColor:
            isDarkMode ? Colors.yellow : const Color.fromARGB(255, 91, 90, 90),
        backgroundColor:
            isDarkMode ? Colors.black : Theme.of(context).canvasColor,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: 'Saved',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Account',
          ),
        ],
      ),
    );
  }
}
