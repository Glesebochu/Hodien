import 'dart:developer'; // For logging
import 'package:translator/translator.dart'; // Google translator package

// Class to hold the translation result or error
class TranslationResult {
  final String? translatedText; // Translated output text
  final String? language; // Detected language of the original input
  final String? error; // Error message, if any

  TranslationResult({this.translatedText, this.language, this.error});
}

// Main Translator class
class Translator {
  final GoogleTranslator _translator =
      GoogleTranslator(); // Initialize translator instance

  // Core method: Translates input text into English
  Future<TranslationResult> translateText(String inputText) async {
    try {
      // Detect the language of the input text (also gives initial English translation)
      final detected = await _translator.translate(inputText, to: 'en');
      final detectedLang =
          detected.sourceLanguage.code; // Safely get detected language code
      log("[INFO] Detected Language: $detectedLang");

      // If the detected language is English, skip translation and return original text
      if (detectedLang == "auto") {
        return TranslationResult(
          translatedText: inputText,
          language: detectedLang,
        );
      }
      // If the detected language is not Amharic, return an error
      // if (detectedLang != "am" || detectedLang != "auto") {
      //   log("[ERROR] Input language is $detectedLang.");
      //   return TranslationResult(
      //     error: "Input language is unsupported.",
      //     language: detectedLang,
      //   );
      // }
      // Try translating the text (allow 1 retry if it fails)
      for (int attempt = 0; attempt < 2; attempt++) {
        try {
          final translation = await _translator.translate(
            inputText,
            to: 'en',
          ); // Attempt translation
          log("[SUCCESS] Translation from translator service.");

          // Return the successful translation and detected language
          return TranslationResult(
            translatedText: translation.text,
            language: detectedLang,
          );
        } catch (e) {
          log(
            "[RETRY ${attempt + 1}] Translation failed: $e from translator service",
          ); // Log the failure attempt

          if (attempt == 1) {
            rethrow; // If final retry also fails, throw error to outer catch
          }

          await Future.delayed(
            Duration(milliseconds: 500),
          ); // Wait 0.5 seconds before retrying
        }
      }
    } catch (e) {
      // If anything unexpected happens, log it and return an error
      log("[FAILURE] Unexpected translation error: $e");
      return TranslationResult(error: "Translation Failed");
    }

    // This line should almost never be reached (fallback safety)
    return TranslationResult(error: "Unknown Error from translator service");
  }
}
