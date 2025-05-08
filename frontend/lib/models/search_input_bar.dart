import 'dart:async'; // For Timer (debounce)
import 'package:flutter/material.dart';
import '../services/translator_service.dart';
// import '../services/preprocessing_service.dart';
import 'dart:developer'; // For using the log() function instead of print
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication

class SearchInputBar extends StatefulWidget {
  // Callbacks for empty and valid search
  final VoidCallback? onValidSearch;
  final void Function(String error)? onError;

  const SearchInputBar({super.key, this.onValidSearch, this.onError});

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

// --- STATE CLASS FOR SEARCH INPUT BAR ---
class _SearchInputBarState extends State<SearchInputBar> {
  final TextEditingController _controller = TextEditingController();
  final Translator _translatorService = Translator();
  // final PreprocessingService _preprocessingService = PreprocessingService();

  // --- STATE VARIABLES ---
  String? translatedText; // Final translation result
  String? language; // Detected language (if needed)
  String? error; // Any error message (connection, failure, etc.)
  bool isLoading = false; // Tracks loading spinner state
  String? userId; // User ID for logging
  String? originalText; // Original text input by the user
  Timer? _debounce; // Timer for debounce control
  int? queryId; // Query ID for Firebase (if needed)

  // --- INITIALIZE USER ID ---
  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid ?? 'anonymous';
  }

  // --- INPUT VALIDATION for translator---
  bool _isValidInput(String input) {
    final cleaned = input.trim();

    final isOnlySymbols = RegExp(
      r'^[^A-Za-z\u1200-\u137F]+$',
    ).hasMatch(cleaned);
    final isOnlyNumbers = RegExp(r'^\d+$').hasMatch(cleaned);

    return cleaned.isNotEmpty && !isOnlySymbols && !isOnlyNumbers;
  }

  // --- DEBOUNCED TRANSLATION CALL ---
  void _onTextChanged(String input) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 200), () async {
      setState(() {
        translatedText = null;
        language = null;
        error = null;
        isLoading = true;
      });

      // Check if the input is valid before making the API call
      if (!_isValidInput(input)) {
        setState(() {
          isLoading = false;
        });
        return;
      }
      try {
        // Call the translation service
        final result = await _translatorService.translateText(input);
        setState(() {
          translatedText = result.translatedText;
          language = result.language;
          error = result.error;
          isLoading = false;
        });
      } catch (e) {
        // Handle any exceptions that may occur during the API call
        setState(() {
          log("Translation Exception: $e from search bar");
          setState(() {
            error = "Translation request Failed";
          });
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- SEARCH INPUT FIELD ---
        TextField(
          controller: _controller,
          onChanged: _onTextChanged,
          textInputAction: TextInputAction.search,
          // When user presses enter or search button on keyboard it will call this function
          // and pass the current value of the text field to it
          onSubmitted: (value) async {
            queryId = null; // Reset queryId for new submission
            // Only run if the input is not empty and user is logged in
            try {
              if (value.trim().isNotEmpty &&
                  userId != 'anonymous' &&
                  error == null) {
                log(
                  "New Original Text: $value |"
                  "Translated Text: $translatedText |"
                  "Language: $language |"
                  "User ID: $userId",
                );
                log("Submitting query from search bar...");
                // Call the preprocessing service to send the input to the backend
                // final queryId = await _preprocessingService
                //     .sendInputToPreprocessor(
                //       originalText: value,
                //       translatedText: translatedText ?? '',
                //       language: language ?? '',
                //       userId: userId!,
                //     );
                log(
                  "$queryId saved successfully and id recieved from preprocessing service",
                );

                widget.onValidSearch!(); // Send signal up to parent
              } else if (userId == 'anonymous' || error != null) {
                String errorMessage =
                    "Submission blocked: Missing data or user not logged in.";
                log("$errorMessage | from search bar");

                widget.onError?.call(
                  errorMessage,
                ); // Notify parent about the error
              }
            } catch (e) {
              String errorMessage = "An error occurred during search.";
              log("Error submitting query: $e");
              widget.onError?.call(
                errorMessage,
              ); // Notify parent about the error
            }
          },
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(color: Colors.grey[600], fontSize: 17),
            prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
            suffixIcon: IconButton(
              icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
              onPressed: () {
                _controller.clear();
                setState(() {
                  translatedText = null;
                  language = null;
                  error = null;
                  isLoading = false;
                });
              },
            ),
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // --- LOADING SPINNER ---
        if (isLoading)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Color.fromARGB(255, 225, 204, 15),
              ),
            ),
          )
        // --- TRANSLATED TEXT ---
        else if (error == null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              translatedText ?? '',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          )
        // --- ERROR TEXT ---
        else if (error != null)
          Row(
            children: [
              const Icon(Icons.error, color: Colors.red, size: 16),
              const SizedBox(width: 4),
              Text(
                error ?? '',
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            ],
          ),
      ],
    );
  }
}
