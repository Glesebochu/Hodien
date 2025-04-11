import 'package:flutter/material.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header Row
              Row(
                children: [
                  const BackButton(),
                  const SizedBox(width: 8),
                  const Text(
                    'Search',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SearchBar with Cancel (as suffix icon)
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search humor...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: TextButton(
                    onPressed: () {
                    },
                    child: const Text('Cancel'),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
              ),

              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Placeholder for Conditional Content
              Expanded(
                child: Center(
                  child: Text(
                    'Search results will appear here.',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),

              // Optional: Uncomment one of these for loading/empty state previews

              // const Center(child: CircularProgressIndicator()),
              // const Center(child: Text('No results found')),
            ],
          ),
        ),
      ),
    );
  }
}
