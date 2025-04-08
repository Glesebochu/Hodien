class Translator:
    def detect_language(self, text: str) -> str:
        """
        Detect the language of the input text.
        Example return values: "am" (Amharic), "en" (English)
        """
        # Placeholder: integrate language detection logic here
        detected_language = "am"  # stub return for example
        return detected_language

    def translate_to_english(self, text: str) -> str:
        """
        Translates the given text to English only if it's in Amharic.
        """
        if self.detect_language(text) == "am":
            return self.perform_translation(text)
        else:
            return text

    def translate_and_detect(self, text: str) -> dict:
        """
        Detects the language and returns both the language code and translated text.
        """
        lang = self.detect_language(text)
        translated = self.perform_translation(text) if lang == "am" else text

        return {
            "language": lang,
            "translated_text": translated
        }

    # --- Placeholder method ---
    def perform_translation(self, text: str) -> str:
        # Integrate actual translation API or logic here
        return "[translated]"  # stub response
