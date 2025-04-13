import 'package:flutter/material.dart';
import 'reusable_back_button.dart';
import 'search_input_bar.dart';

class SearchPage extends StatelessWidget {
  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),

              // Header Row
              Row(
                children: [
                  ReusableBackButton(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Explore',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // SearchBar with Cancel (as suffix icon)
              SearchInputBar(),
              // Column(
              //   children: [
              //     shadcn.TextField(
              //       placeholder: const Text('Enter your name'),
              //       features: [
              //         const shadcn.InputFeature.clear(),
              //         shadcn.InputFeature.hint(
              //           popupBuilder: (context) {
              //             return const shadcn.TooltipContainer(
              //               child: Text('This is for your username'),
              //             );
              //           },
              //         ),
              //         const shadcn.InputFeature.copy(),
              //         const shadcn.InputFeature.paste(),
              //       ],
              //     ),
              //     const shadcn.Gap(24),
              //     const shadcn.TextField(
              //       placeholder: Text('Enter your password'),
              //       features: [
              //         shadcn.InputFeature.clear(),
              //         shadcn.InputFeature.passwordToggle(
              //           mode: shadcn.PasswordPeekMode.hold,
              //         ),
              //       ],
              //     ),
              //   ],
              // ),
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
