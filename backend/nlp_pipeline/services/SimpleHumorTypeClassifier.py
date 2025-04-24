import pandas as pd
import re

class SimpleHumorTypeClassifier:
    def __init__(self, input_file, output_file="backend/nlp_pipeline/data/classified_jokes.csv"):
        self.input_file = input_file
        self.output_file = output_file
        self.humor_keywords = {
            "Physical/Slapstick": ["walk into a bar", "hit me", "fell", "slipped", "punched", "kick", "ran into"],
            "Wordplay/Puns": ["pun", "play on words", "what do you call", "why did", "because", "get it", "i'll see myself out", "wordplay", "puns", "punchline"],
            "Situational Humor": ["awkward", "weird", "unexpected", "ironic", "surreal", "anecdote", "this one time", "observational"],
            "Critical Humor": ["politics", "satire", "sarcasm", "dark", "gallows", "self-deprecating", "parody", "offensive", "insult"]
        }
        self.humor_type_mapping = {label: idx + 1 for idx, label in enumerate(self.humor_keywords.keys())}
        self.data = None

    def load_data(self):
        self.data = pd.read_csv(self.input_file)

    def classify_humor(self, text):
        text_lower = text.lower()
        scores = {}
        for category, patterns in self.humor_keywords.items():
            score = sum(1 for p in patterns if p in text_lower)
            scores[category] = score

        best_fit = max(scores, key=scores.get)
        total = sum(scores.values())
        confidence = scores[best_fit] / total if total > 0 else 0.2
        return self.humor_type_mapping[best_fit], round(confidence, 2)

    def process_data(self):
        humor_types = []
        humor_scores = []

        for joke in self.data["text"]:
            humor_type, score = self.classify_humor(str(joke))
            humor_types.append(humor_type)
            humor_scores.append(score)

        self.data["humor_type"] = humor_types
        self.data["humor_type_score"] = humor_scores

    def save_data(self):
        self.data.to_csv(self.output_file, index=False)

    def run(self):
        self.load_data()
        self.process_data()
        self.save_data()
        return self.output_file

# Example usage
if __name__ == "__main__":
    classifier = SimpleHumorTypeClassifier(input_file="humor.csv")
    output_path = classifier.run()
    print(f"Classified humor saved to: {output_path}")
