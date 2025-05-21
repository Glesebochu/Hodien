import nltk
from nltk.corpus import wordnet as wn

nltk.download('wordnet')

# Define suffixes to exclude derived forms
excluded_suffixes = ('ing', 'ed', 'ly', 'ness', 'ment', 'tion', 's', 'es', 'er', 'est', 'ous', 'ful', 'less', 'able')

# Acceptable POS: noun, verb, adjective, satellite adjective
pos_tags = ['n', 'v', 'a', 's']

base_words = set()

for pos in pos_tags:
    for synset in wn.all_synsets(pos):
        for lemma in synset.lemmas():
            word = lemma.name().lower()
            if not word.isalpha() or len(word) < 3:
                continue
            if word.endswith(excluded_suffixes):
                continue
            base_words.add(word)

with open("base_words_custom.txt", "w") as f:
    for word in sorted(base_words):
        f.write(word + "\n")