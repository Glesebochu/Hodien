import 'package:flutter/material.dart';
import '../models/reusable_back_button.dart';
import '../models/search_input_bar.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  bool showNoResults = false; // 🟡 Flag to toggle "No results found"
  String? errorMessage;

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
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ReusableBackButton(),
                  ),
                  const Text(
                    'Explore',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              const SizedBox(height: 100),

              // SearchInputBar with error callback
              SearchInputBar(
                // Callback to handle invalid input or error from search bar
                onError: (String error) {
                  setState(() {
                    showNoResults = true;
                    errorMessage = error;
                  });
                },
                onValidSearch: () {
                  setState(() {
                    showNoResults = false;
                  });
                },
              ),
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 12),

              // Conditional display based on input
              if (showNoResults)
                Expanded(
                  child: Center(
                    child: Text(
                      errorMessage ??
                          'No Results Found', // Use the errorMessage if it exists
                      style: const TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                )
              else
                const Expanded(
                  child: Center(
                    child: Text(
                      'Search results will appear here.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
              // loading/empty state previews
              // const Center(
              //   child: SizedBox(
              //     width: 20,
              //     height: 20,
              //     child: CircularProgressIndicator(
              //       color: Color.fromARGB(255, 225, 204, 15),
              //     ),
              //   ),
              // ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
