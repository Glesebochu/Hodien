import 'dart:convert'; // For JSON encoding/decoding
import 'dart:developer'; // For using the log() function instead of print
import 'dart:io'; // For catching SocketException
import 'package:http/http.dart' as http;

// Custom response class to unify translated output and error
class TranslationResult {
  final String? translatedText;
  final String? error;

  TranslationResult({this.translatedText, this.error});
}

class TranslatorService {
  final String _baseUrl = 'http://127.0.0.1:8000/translate'; // The server URL

  // Core translation method that accepts user input from the UI and sends it to the server
  // Returns a TranslationResult object containing either the translated text or an error message
  Future<TranslationResult> translate(String inputText) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': inputText}),
      );

      // If server returns valid response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        // Return just the translated text, no error
        return TranslationResult(translatedText: data['translated_text']);
      } else {
        // For unexpected HTTP error (non-200)
        return TranslationResult(error: "Translation Failed");
      }
    } on SocketException catch (e) {
      // Internet-related error
      log("Network Error: $e");
      return TranslationResult(error: "Internet Connection Error");
    } catch (e) {
      // All other errors
      log("Translation Exception: $e");
      return TranslationResult(error: "Unexpected Error: $e");
    }
  }
}
