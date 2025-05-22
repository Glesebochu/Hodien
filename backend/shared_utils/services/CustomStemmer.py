
import logging
from .suffix_rules import suffix_map_step2, suffix_map_step3, suffix_list_step4

# Setup terminal-based logging
logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(levelname)s - %(message)s")

class CustomPorterStemmer:
    def __init__(self):
        self.vowels = "aeiou"
        with open("base_words.txt", "r", encoding="utf-8") as f:
            self.valid_words = set(word.strip().lower() for word in f.readlines())

    def is_valid(self, word: str) -> bool:
        return word in self.valid_words

    def is_consonant(self, word: str, i: int) -> bool:
        char = word[i].lower()
        if char in self.vowels:
            return False
        if char == 'y':
            return i == 0 or not self.is_consonant(word, i - 1)
        return True

    def measure(self, word: str) -> int:
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
        return any(not self.is_consonant(word, i) for i in range(len(word)))

    def ends_with_double_consonant(self, word: str) -> bool:
        return len(word) >= 2 and word[-1] == word[-2] and self.is_consonant(word, len(word) - 1)

    def cvc(self, word: str) -> bool:
        if len(word) < 3:
            return False
        return (self.is_consonant(word, -3)
                and not self.is_consonant(word, -2)
                and self.is_consonant(word, -1)
                and word[-1] not in "wxy")

    def step1a(self, word: str) -> str:
        logging.info(f"Step 1a Input: {word}")
        if self.is_valid(word): return word
        if word.endswith("sses"): result = word[:-2]
        elif word.endswith("ies"): result = word[:-2]
        elif word.endswith("s") and not word.endswith("ss"): result = word[:-1]
        else: result = word
        return result if self.is_valid(result) else word

    def step1b(self, word: str) -> str:
        logging.info(f"Step 1b Input: {word}")
        if self.is_valid(word): return word
        if word.endswith("eed"):
            return word[:-1] if self.measure(word[:-3]) > 0 and self.is_valid(word[:-1]) else word
        elif word.endswith("ed"):
            stem = word[:-2]
            if self.contains_vowel(stem): return self.step1b_helper(stem)
        elif word.endswith("ing"):
            stem = word[:-3]
            if self.contains_vowel(stem): return self.step1b_helper(stem)
        return word

    def step1b_helper(self, word: str) -> str:
        logging.info(f"step1b_helper Input: {word}")
        if self.is_valid(word): return word
        if word.endswith(("at", "bl", "iz")):
            result = word + "e"
        elif self.ends_with_double_consonant(word) and word[-1] not in "lsz":
            result = word[:-1]
        elif self.measure(word) == 1 and self.cvc(word):
            result = word + "e"
        else:
            result = word
        return result if self.is_valid(result) else word

    def step1c(self, word: str) -> str:
        logging.info(f"Step 1c Input: {word}")
        if self.is_valid(word): return word
        if word.endswith("y"):
            stem = word[:-1]
            if self.contains_vowel(stem):
                result = stem + "i"
                return result if self.is_valid(result) else word
        return word

    def step2(self, word: str) -> str:
        logging.info(f"Step 2 Input: {word}")
        if self.is_valid(word): return word
        for suffix, replacement in suffix_map_step2.items():
            if word.endswith(suffix):
                stem = word[: -len(suffix)]
                if self.measure(stem) > 0:
                    result = stem + replacement
                    return result if self.is_valid(result) else word
        return word

    def step3(self, word: str) -> str:
        logging.info(f"Step 3 Input: {word}")
        if self.is_valid(word): return word
        for suffix, replacement in suffix_map_step3.items():
            if word.endswith(suffix):
                stem = word[: -len(suffix)]
                if self.measure(stem) > 0:
                    result = stem + replacement
                    return result if self.is_valid(result) else word
        return word

    def step4(self, word: str) -> str:
        logging.info(f"Step 4 Input: {word}")
        if self.is_valid(word): return word
        for suffix in suffix_list_step4:
            if word.endswith(suffix):
                stem = word[: -len(suffix)]
                if self.measure(stem) >= 1 and len(stem) > 4:
                    return stem if self.is_valid(stem) else word
        return word

    def step5(self, word: str) -> str:
        logging.info(f"Step 5 Input: {word}")
        if self.is_valid(word): return word
        if word.endswith("e"):
            stem = word[:-1]
            if self.measure(stem) > 1 or (self.measure(stem) == 1 and not self.cvc(stem)):
                if self.is_valid(stem):
                    return stem
        if word.endswith("ll") and self.measure(word) > 1:
            reduced = word[:-1]
            if self.is_valid(reduced):
                return reduced
        return word

    def repair(self, word: str) -> str:
        logging.info(f"Repair Input: {word}")
        # Simple heuristic: add 'e' if the word is one letter short of a known base
        if not self.is_valid(word) and self.is_valid(word + "e"):
            return word + "e"
        return word

    def stem(self, word: str) -> str:
        logging.info(f"\n🌱 Starting stemming for: {word}")
        word = word.lower()

        if len(word) <= 2:
            logging.warning("Word too short to stem.")
            return word

        for step in [self.step1a, self.step1b, self.step1c, self.step2, self.step3, self.step4, self.step5]:
            if self.is_valid(word): break
            word = step(word)

        word = self.repair(word)
        logging.info(f"🎯 Final Stemmed Result: {word}\n")
        return word

if __name__ == "__main__":
    stemmer = CustomPorterStemmer()
    test_words = ["dancing", "surprised", "elegance", "comedian"]
    for word in test_words:
        print(stemmer.stem(word))
