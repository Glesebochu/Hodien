from ..services.ContentFilterer import ContentFilterer
# from ..services.HumorDetector import HumorDetector
# from ..services.HumorTypeClassifier import HumorTypeClassifier
from ..services.SimpleHumorTypeClassifier import SimpleHumorTypeClassifier
import pandas as pd

# * Normalization
# content_filterer = ContentFilterer()
# file = "backend/nlp_pipeline/data/shortjokes.csv"
# content_filterer.normalize(file)

# * Humor Detection
# detector = HumorDetector()
# detector.train()

# detector.predict("This just in.")

# * Simple Humor Type Classification
file2 = "backend/nlp_pipeline/data/normalized_jokes.csv"
classifier = SimpleHumorTypeClassifier(input_file=file2)
output_path = classifier.run()
print(f"Classified humor saved to: {output_path}")

# * Humor type classification
# classifier = HumorTypeClassifier()
# classifier.train()

# classifier.predict("did you hear about the guy who blew his entire lottery winnings on a limousine? he had nothing left to chauffeur it.")