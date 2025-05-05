import logging
from .suffix_rules import suffix_map_step2, suffix_map_step3, suffix_list_step4

# Setup terminal-based logging
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)

class CustomPorterStemmer:
    """
    A custom-built, simplified version of the Porter Stemmer algorithm.
    Handles basic suffix stripping based on word form (vowel/consonant patterns).
    Includes terminal logging at each step.
    """

    def __init__(self):
        self.vowels = "aeiou"

    def is_consonant(self, word: str, i: int) -> bool:
        char = word[i].lower()
        if char in self.vowels:
            return False
        if char == 'y':
            if i == 0:
                return True
            else:
                return not self.is_consonant(word, i - 1)
        return True


    def measure(self, word: str) -> int:
        """
        Calculates the measure (m) of a word.
        A VC sequence is defined as a vowel followed by a consonant.
        """
        m = 0
        prev_vowel = False

        for i in range(len(word)):
            if not self.is_consonant(word, i):
                prev_vowel = True
            elif prev_vowel:
                m += 1
                prev_vowel = False

        return m


    def contains_vowel(self, word: str) -> bool:
        for i in range(len(word)):
            if not self.is_consonant(word, i):
                return True
        return False

    def ends_with_double_consonant(self, word: str) -> bool:
        if len(word) >= 2 and word[-1] == word[-2]:
            if self.is_consonant(word, len(word) - 1):
                return True
        return False

    def cvc(self, word: str) -> bool:
        if len(word) < 3:
            return False
        if (self.is_consonant(word, -3) and
            not self.is_consonant(word, -2) and
            self.is_consonant(word, -1)):
            last = word[-1]
            if last not in "wxy":
                return True
        return False

    def step1a(self, word: str) -> str:
        logging.info(f"Step 1a Input: {word}")
        try:
            if word.endswith("sses"):
                result = word[:-2]
            elif word.endswith("ies"):
                result = word[:-2]
            elif word.endswith("s") and not word.endswith("ss"):
                result = word[:-1]
            else:
                result = word
            logging.info(f"Step 1a Output: {result}")
            return result
        except Exception as e:
            logging.error(f"Step 1a Error: {e}")
            return word

    def step1b(self, word: str) -> str:
        logging.info(f"Step 1b Input: {word}")
        result = word
        try:
            if word.endswith("eed"):
                if self.measure(word[:-3]) > 0:
                    result = word[:-1]
                else:
                    result = word
            elif word.endswith("ed"):
                stem = word[:-2]
                if self.contains_vowel(stem):
                    # Don't call step1b_helper unless conditions match
                    if stem.endswith(("at", "bl", "iz")) or \
                    (self.ends_with_double_consonant(stem) and stem[-1] not in "lsz") or \
                    (self.measure(stem) == 1 and self.cvc(stem)):
                        result = self.step1b_helper(stem)
                    else:
                        result = stem
                else:
                    result = word

            elif word.endswith("ing"):
                stem = word[:-3]
                if self.contains_vowel(stem):
                    if stem.endswith(("at", "bl", "iz")) or \
                    (self.ends_with_double_consonant(stem) and stem[-1] not in "lsz") or \
                    (self.measure(stem) == 1 and self.cvc(stem)):
                        result = self.step1b_helper(stem)
                    else:
                        result = stem
                else:
                    result = word

            logging.info(f"Step 1b Output: {result}")
            return result
        except Exception as e:
            logging.error(f"Step 1b Error: {e}")
            return word

    def step1b_helper(self, word: str) -> str:
        logging.info(f"step1b_helper Input: {word}")
        try:
            if word.endswith(("at", "bl", "iz")):
                result = word + "e"
            elif self.ends_with_double_consonant(word):
                if word[-1] not in "lsz":
                    result = word[:-1]
                else:
                    result = word
            elif self.measure(word) == 1 and self.cvc(word):
                result = word + "e"
            else:
                result = word  # ✅ FIX: Don't add "e" unless a rule matches
            logging.info(f"step1b_helper Output: {result}")
            return result
        except Exception as e:
            logging.error(f"step1b_helper Error: {e}")
            return word

    def step1c(self, word: str) -> str:
        logging.info(f"Step 1c Input: {word}")
        try:
            if word.endswith("y"):
                stem = word[:-1]
                if self.contains_vowel(stem):
                    result = stem + "i"
                else:
                    result = word
            else:
                result = word
            logging.info(f"Step 1c Output: {result}")
            return result
        except Exception as e:
            logging.error(f"Step 1c Error: {e}")
            return word

    def stem(self, word: str) -> str:
        logging.info(f"\n🌱 Starting stemming for: {word}")
        word = word.lower()

        if len(word) <= 2:
            logging.warning("Word too short to stem.")
            return word

        word = self.step1a(word)
        word = self.step1b(word)
        word = self.step1c(word)

        logging.info(f"🎯 Final Stemmed Result: {word}\n")
        return word


if __name__ == "__main__":
    stemmer = CustomPorterStemmer()
    test_words = ["hissing"]
    for word in test_words:
        print(f"Original: {word} → Stemmed: {stemmer.stem(word)}")