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
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const Home({required this.toggleTheme, required this.isDarkMode, super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  //bool isDarkMode = false;

  //void toggleTheme() {
  //  setState(() {
  //    isDarkMode = !isDarkMode;
  //  });
  //}

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
    // Defensive: ensure all required fields are non-null and String-typed
    final safeJoke = {
      'id': joke['id']?.toString() ?? '',
      'text': joke['text']?.toString() ?? '',
      'humorType': joke['humorType']?.toString() ?? '',
      'humorScore': joke['humorScore'] ?? 0.0,
      // add other fields as needed
    };
    setState(() {
      surpriseJoke = safeJoke;
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
                      ? const CircularProgressIndicator(
                        color: Color.fromARGB(255, 225, 204, 15),
                      )
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 20, 0, 0),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Image.asset('assets/hodien.png', height: 60),
              const SizedBox(width: 4),
              Text(
                'Hodien',
                style: GoogleFonts.varela(
                  fontSize: 28,
                  color:
                      Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
              child: IconButton(
                icon: Icon(
                  widget.isDarkMode ? Icons.wb_sunny : Icons.nightlight_round,
                ),
                onPressed: widget.toggleTheme,
              ),
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
                child: RawMaterialButton(
                  onPressed: showSurpriseJoke,
                  fillColor: Colors.yellow[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 140,
                    minHeight: 56,
                  ), // wider & taller
                  elevation: 6,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.black),
                      SizedBox(width: 8),
                      Text(
                        'Surprise Me',
                        style: GoogleFonts.varela(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
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
                  child: PostCard(
                    jokeData: surpriseJoke!,
                    humorProfile: profile,
                  ),
                ),
              ),
            ],
          ],
        ),

        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedTabIndex,
          onTap: (index) => setState(() => _selectedTabIndex = index),
          selectedItemColor:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.amber
                  : Colors.black,
          unselectedItemColor:
              Theme.of(context).brightness == Brightness.dark
                  ? Colors.yellow
                  : const Color.fromARGB(255, 91, 90, 90),
          backgroundColor:
              widget.isDarkMode ? Colors.black : Theme.of(context).canvasColor,
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
      ),
    );
  }
}
