import 'dart:async'; // For Timer (debounce)
import 'package:flutter/material.dart';
import '../services/translator_service.dart';
import '../services/preprocessing_service.dart';
import 'dart:developer'; // For using the log() function instead of print
import 'package:firebase_auth/firebase_auth.dart'; // For Firebase authentication
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;
import '../services/query_profile_matcher.dart'; // For QueryProfileMatcher

class SearchInputBar extends StatefulWidget {
  // Callbacks for empty and valid search
  final VoidCallback? onSearchStart;
  final void Function(List<Map<String, dynamic>> results)? onSearchResults;
  final void Function(String error)? onError;

  const SearchInputBar({
    super.key,
    this.onSearchStart,
    this.onSearchResults,
    this.onError,
  });

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

// --- STATE CLASS FOR SEARCH INPUT BAR ---
class _SearchInputBarState extends State<SearchInputBar> {
  final TextEditingController _controller = TextEditingController();
  final Translator _translatorService = Translator();
  final PreprocessingService _preprocessingService = PreprocessingService();

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

  bool isValidQuery(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return false;

    // Check for valid characters: Latin, Amharic, digits, or emojis
    final hasAlpha = RegExp(r'[a-zA-Z\u1200-\u137F]').hasMatch(trimmed);
    final hasDigit = RegExp(r'\d').hasMatch(trimmed);
    final hasEmoji = RegExp(
      r'[\u{1F600}-\u{1F64F}]',
      unicode: true,
    ).hasMatch(trimmed);

    final isLongNoSpaces = trimmed.length > 20 && !trimmed.contains(' ');
    final isRepetitive = trimmed.split('').toSet().length == 1;
    final isLikelyPureGibberish = isLongNoSpaces && !hasAlpha && !hasEmoji;

    return (hasAlpha || hasEmoji || hasDigit) &&
        !isRepetitive &&
        !isLikelyPureGibberish;
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- SEARCH INPUT FIELD ---
          TextField(
            controller: _controller,
            onChanged: _onTextChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) async {
              queryId = null; // Reset previous queryId
              try {
                if (value.trim().isNotEmpty &&
                    userId != 'anonymous' &&
                    error == null &&
                    isValidQuery(value)) {
                  widget.onSearchStart
                      ?.call(); // Start loading before queryMatcher

                  log("Sending to preprocessing service: $value");

                  final queryIdResult = await _preprocessingService
                      .sendInputToPreprocessor(
                        originalText: value,
                        translatedText: translatedText ?? '',
                        language: language ?? '',
                        userId: userId!,
                      );

                  log("Query ID returned: $queryIdResult");

                  final matcher = QueryProfileMatcher();
                  final results = await matcher.matchQueryAndProfile(
                    userId: userId!,
                    queryId: queryIdResult,
                  );

                  if (results.isNotEmpty && results.first['error'] != true) {
                    // Success — Send signal up to parent
                    widget.onSearchResults?.call(results);
                  } else {
                    widget.onError?.call(results.first['text']);
                  }
                } else {
                  String errorMessage;
                  if (userId == 'anonymous') {
                    errorMessage = "Please log in to search.";
                  } else if (error != null) {
                    errorMessage = "Search input error: $error";
                  } else {
                    errorMessage =
                        "Please enter a valid query — not just symbols or gibberish.";
                  }

                  widget.onError?.call(errorMessage);
                  log("Search error: $errorMessage");
                }
              } catch (e) {
                final errorMessage = "Something went wrong during search.";
                widget.onError?.call(errorMessage);
                log("Search submit exception: $e");
              }
            },
            decoration: InputDecoration(
              hintText: 'Hey',
              hintStyle: TextStyle(
                color: const Color.fromARGB(255, 147, 147, 147),
                fontSize: 17.5,
                fontWeight: FontWeight.w500,
              ),
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 16, right: 8),
                child: Icon(Icons.search, color: Colors.grey, size: 20.5),
              ),
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: 10),
                child: IconButton(
                  icon: const Icon(
                    Icons.cancel,
                    color: Color.fromARGB(255, 212, 201, 83),
                    size: 20.5,
                  ),
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  hoverColor: Colors.transparent,
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
              ),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 13.5,
              ),
            ),
          ),
          const SizedBox(height: 8),
          if (isLoading)
            const Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: shadcn.CircularProgressIndicator(),
              ),
            )
          else if (error == null)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: shadcn.Text(
                translatedText ?? '',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            )
          else if (error != null)
            Row(
              children: [
                const Icon(Icons.error, color: Colors.red, size: 16),
                const SizedBox(width: 4),
                shadcn.Text(
                  error ?? '',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
