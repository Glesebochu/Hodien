import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer'; // For logging

class PreprocessingService {
  Future<String> sendInputToPreprocessor({
    required String originalText,
    required String translatedText,
    required String language,
    required String userId,
  }) async {
    final response = await http.post(
      Uri.parse(
        'http://127.0.0.1:8000/preprocess',
      ), // Your FastAPI backend endpoint
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'original_text': originalText,
        'translated_text': translatedText,
        'language': language,
        'user_id': userId,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('queryId')) {
        log("[SUCCESS] Query sent to controller successfully from preprocessing service");
        return data['queryId']; // Return the Query ID
      } else if (data.containsKey('error')) {
        log("[ERROR] Error from preprocessor: ${data['error']}");
        throw Exception(data['error']); // Throw backend error
      } else {
        throw Exception('Unknown server response');
      }
    } else {
      log("[ERROR] Failed to connect to the preprocessor: ${response.statusCode}");
      throw Exception('Failed to connect to preprocessing service');
    }
  }
}
