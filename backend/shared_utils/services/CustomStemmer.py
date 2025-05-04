class CustomPorterStemmer:
    """
    A custom-built, simplified version of the Porter Stemmer algorithm.
    Handles basic suffix stripping based on word form (vowel/consonant patterns).
    """

    def __init__(self):
        # Define vowels for quick lookup
        self.vowels = "aeiou"

    def is_consonant(self, word: str, i: int) -> bool:
        """
        Returns True if the character at position i is a consonant.
        Special handling for 'y' based on position and preceding character.
        """
        if word[i] in self.vowels:
            return False
        if word[i] == 'y':
            if i == 0:
                return True
            else:
                return not self.is_consonant(word, i-1)
        return True

    def measure(self, word: str) -> int:
        """
        Calculates the measure (m) of the word.
        Measure = number of vowel-consonant (VC) sequences.
        Example: 'trouble' -> 1, 'troubleness' -> 2
        """
        m = 0
        i = 0
        length = len(word)

        while i < length:
            if not self.is_consonant(word, i):
                break
            i += 1
        i += 1

        while i < length:
            while i < length and self.is_consonant(word, i):
                i += 1
            i += 1
            m += 1
            while i < length and not self.is_consonant(word, i):
                i += 1
            i += 1

        return m

    def contains_vowel(self, word: str) -> bool:
        """
        Checks if the word contains at least one vowel.
        """
        for i in range(len(word)):
            if not self.is_consonant(word, i):
                return True
        return False

    def ends_with_double_consonant(self, word: str) -> bool:
        """
        Checks if the word ends with two identical consonants.
        Example: 'hopping' -> 'pp'
        """
        if len(word) >= 2 and word[-1] == word[-2]:
            if self.is_consonant(word, len(word)-1):
                return True
        return False

    def cvc(self, word: str) -> bool:
        """
        Checks for CVC (consonant-vowel-consonant) pattern at the end.
        Helps decide when to add/remove 'e' during stemming.
        """
        if len(word) < 3:
            return False
        if (self.is_consonant(word, -3) and 
            not self.is_consonant(word, -2) and 
            self.is_consonant(word, -1)):
            last = word[-1]
            if last not in "wxy":  # CVC exception letters
                return True
        return False

    def step1a(self, word: str) -> str:
        """
        Handles plural and simple suffix replacements:
        - 'sses' -> 'ss'
        - 'ies' -> 'i'
        - 's' -> ''
        """
        if word.endswith("sses"):
            return word[:-2]
        elif word.endswith("ies"):
            return word[:-2]
        elif word.endswith("s") and not word.endswith("ss"):
            return word[:-1]
        else:
            return word

    def step1b(self, word: str) -> str:
        """
        Handles -ed and -ing endings:
        - If 'ed' or 'ing' and contains vowel before it, remove it.
        Then further modify if certain conditions are met.
        """
        if word.endswith("eed"):
            if self.measure(word[:-3]) > 0:
                return word[:-1]
        elif word.endswith("ed"):
            stem = word[:-2]
            if self.contains_vowel(stem):
                word = stem
                word = self.step1b_helper(word)
        elif word.endswith("ing"):
            stem = word[:-3]
            if self.contains_vowel(stem):
                word = stem
                word = self.step1b_helper(word)
        return word

    def step1b_helper(self, word: str) -> str:
        """
        Helper after removing -ed or -ing:
        - If word ends with 'at', 'bl', or 'iz' → add 'e'
        - If ends with double consonant → remove last letter
        - If short word (m==1 and cvc) → add 'e'
        """
        if word.endswith(("at", "bl", "iz")):
            return word + "e"
        elif self.ends_with_double_consonant(word):
            if word[-1] not in "lsz":
                return word[:-1]
        elif self.measure(word) == 1 and self.cvc(word):
            return word + "e"
        return word

    def step1c(self, word: str) -> str:
        """
        Turns terminal 'y' into 'i' if there's a vowel earlier.
        Example: 'happy' -> 'happi'
        """
        if word.endswith("y"):
            stem = word[:-1]
            if self.contains_vowel(stem):
                return stem + "i"
        return word

    def stem(self, word: str) -> str:
        """
        Main stemming method.
        Applies Step 1a → Step 1b → Step 1c sequentially.
        """
        word = word.lower()

        if len(word) <= 2:
            return word

        word = self.step1a(word)
        word = self.step1b(word)
        word = self.step1c(word)

        return word
