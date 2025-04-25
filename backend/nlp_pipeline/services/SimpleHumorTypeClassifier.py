import pandas as pd
import re

class SimpleHumorTypeClassifier:
    def __init__(self, input_file, output_file="backend/nlp_pipeline/data/classified_jokes.csv"):
        self.input_file = input_file
        self.output_file = output_file
        self.humor_keywords = {
            "Physical/Slapstick": [
                "fall", "trip", "slip", "smack", "crash", "bump", "hit", "kick", "punch",
                "collapse", "bounce", "stumble", "explode", "break",
                "faceplant", "headbutt", "butt", "nose", "foot in mouth", "pants fell down",
                "banana peel", "BOOM", "bang", "thud", "whoosh", "splat", "crack", "bonk", "crunch",
                "cartwheel into a wall", "ran into a door", "waved arms like crazy", 
                "danced like a chicken", "like in a cartoon", "slapped silly", 
                "in slow motion", "wild flailing", "acted like a ragdoll",
                "pie in the face", "gets electrocuted", "slips on ice"
            ],
            "Wordplay/Puns": [
                "pun", "play on words", "double meaning", "homophone", "dad joke",
                "because it was too tired", "that's how I roll", "tune a piano", "tuna fish",
                "lettuce celebrate", "egg-cited", "nacho average", "skele-fun", "brew-tiful",
                "meowgical", "barktastic", "grill-iant", "purrfect", "cerealously",
                "knight", "night", "soul", "sole", "witch", "which", "deer", "dear", "eye", "I",
                "silent letters", "grammatically incorrect", "Oxford comma", "spell it out", "acronym",
                "impossible to put down", "he's all right now", "I lost interest",
                "what do you call", "why did", "because", "get it", "i'll see myself out",
                "wordplay", "puns", "punchline"
            ],
            "Situational Humor": [
                "awkward", "ironic", "irony", "absurd", "surreal", "ridiculous",
                "unexpected", "can't make this up", "true story", "real life", "actual event",
                "observational", "relatable", "social fail", "embarrassing", "cringe",
                "weird situation", "odd scenario", "random", "strange encounter", "unusual event",
                "walked into", "then it got worse", "classic mix-up", "wrong place, wrong time",
                "inappropriate timing", "situational", "out of context", "just my luck", 
                "of course that happened", "naturally", "typical", "every time I...",
                "just happened", "of course", "guess what", "random encounter", 
                "you won't believe", "so this happened",
                "weird", "anecdote", "this one time"
            ],
            "Critical Humor": [
                "sarcasm", "sarcastic", "satire", "satirical", "mock", "mocking", "parody",
                "dark humor", "gallows humor", "morbid", "bleak", "grim", "taboo",
                "self-deprecating", "making fun of myself", "roast", "burn", "cynical", "ironic",
                "edgy", "brutal", "savage", "too soon", "wow, okay", "that's dark",
                "nothing matters", "roasted", "called out", "cancelled", "society", "politics",
                "corporate", "capitalism", "boomers", "millennials", "gen z", "my toxic trait",
                "it's giving", "says a lot about", "this aged well", "clown behavior",
                "late stage capitalism", "the audacity", "totally fine, not crying", "everything's fine",
                "no thoughts, just vibes", "so relatable it hurts", "laughing through the pain"
            ]
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
        return self.humor_type_mapping[best_fit], round(confidence, 3)

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
