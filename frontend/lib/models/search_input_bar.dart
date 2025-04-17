import 'dart:async'; // For Timer (debounce)
import 'package:flutter/material.dart';
import '../services/translator_service.dart'; // Importing the service that handles backend translation

class SearchInputBar extends StatefulWidget {
  const SearchInputBar({super.key});

  @override
  State<SearchInputBar> createState() => _SearchInputBarState();
}

class _SearchInputBarState extends State<SearchInputBar> {
  final TextEditingController _controller = TextEditingController();
  final TranslatorService _translatorService = TranslatorService();

  String? translatedText; // Final translation result
  String? error; // Any error message (connection, failure, etc.)
  bool isLoading = false; // Tracks loading spinner state
  Timer? _debounce; // Timer for debounce control

  // --- INPUT VALIDATION ---
  // bool _isValidInput(String input) {
  //   final cleaned = input.trim();
  //   final isSymbolsOnly = RegExp(r'^[^\w\s]+$').hasMatch(cleaned);
  //   final isNumbersOnly = RegExp(r'^\d+$').hasMatch(cleaned);
  //   return cleaned.isNotEmpty && !isSymbolsOnly && !isNumbersOnly;
  // }
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

    _debounce = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        translatedText = null;
        error = null;
        isLoading = true;
      });

      if (!_isValidInput(input)) {
        setState(() {
          isLoading = false;
        });
        return;
      }

      final result = await _translatorService.translate(input);

      setState(() {
        translatedText = result.translatedText;
        error = result.error;
        isLoading = false;
      });
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
        else if (translatedText != null && error == null)
          Padding(
            padding: const EdgeInsets.only(left: 8.0),
            child: Text(
              translatedText!,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          )
        // --- ERROR TEXT ---
        else if (error != null)
          Text(error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
      ],
    );
  }
}
