import logging
import re
from collections import Counter
from nltk.corpus import stopwords
import traceback
from spellchecker import SpellChecker
from nltk.stem import PorterStemmer
from nltk.corpus import wordnet

# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
class DataPreprocessor:
    def __init__(self):
        # Simple stop word list for illustration
        self.stop_words = set(stopwords.words("english"))
        self.result=""
        
    # This function does the entire preprocessing pipeline
    def preprocess(self, text: str) -> dict:
        try:
            logging.info("Preprocessing started on: " + text)

            tokens = self.tokenize(text)
            normalized = self.normalize(tokens)
            filtered = self.remove_stop_words(normalized)
            corrected = self.correct_spelling(filtered)
            stemmed = self.stem_tokens(corrected)
            expanded = self.expand_synonyms(corrected)
            weights = self.weigh_term(expanded)

            result= {
                "tokens": tokens,
                "normalized_tokens": normalized,
                "filtered_tokens": filtered,
                "corrected_tokens": corrected,
                "stemmed_tokens": stemmed,
                "expanded_tokens": expanded,
                "term_weights": weights,
            }
            
            log_output = "Processed Results:\n"
            for key, value in result.items():
                log_output += f"{key}: {value}\n\n"
            logging.info(log_output)
            return result

        except Exception as e:
            tb = traceback.extract_tb(e.__traceback__)
            failed_function = tb[-1].name  # This gives the name of the function that threw the error
            logging.error(f"[DataPreprocessor.{failed_function}] Error: {str(e)}")
            return {"error": str(e)}

    # --- Individual Processing Functions ---

    def tokenize(self, text: str):
        return text.split()

    def normalize(self, tokens):
        return [re.sub(r'[^\w\s]', '', token.lower().strip()) for token in tokens]

    def remove_stop_words(self, tokens):
        return [token for token in tokens if token not in self.stop_words]

    def correct_spelling(self, tokens):
        spell = SpellChecker()
        corrected = [spell.correction(token) for token in tokens]
        return corrected

    def stem_tokens(self, tokens):
        # Filter out None values
        valid_tokens = [token for token in tokens if token is not None]
        stemmer = PorterStemmer()
        stemmed = [stemmer.stem(token) for token in valid_tokens]
        return stemmed        
    def expand_synonyms(self, tokens):
        expanded = []
        for token in tokens:
            synonyms = set()
            for syn in wordnet.synsets(token):
                for lemma in syn.lemmas():
                    synonyms.add(lemma.name().lower().replace('_', ' '))
            # Keep the order of input tokens
            expanded.append(token)
            expanded.extend(sorted(synonyms))  # Sort within word, optional
        return expanded

    def weigh_term(self, tokens):
        counts = Counter(tokens)
        total = sum(counts.values())
        return {token: round(count / total, 3) for token, count in counts.items()}
if __name__ == "__main__":
    # Example usage
    preprocessor = DataPreprocessor("The quick brown fox jumps over the lazy dogb.")
