# from ..services.ContentFilterer import ContentFilterer
# from ..services.HumorDetector import HumorDetector
# from ..services.HumorTypeClassifier import HumorTypeClassifier
# from ..services.SimpleHumorTypeClassifier import SimpleHumorTypeClassifier
# from backend.shared_utils.services.DataPreprocessor import DataPreprocessor
from ..services.Indexer import Indexer
# import pandas as pd

# * Normalization
# content_filterer = ContentFilterer()
# file = "backend/nlp_pipeline/data/shortjokes.csv"
# content_filterer.normalize(file)

# * Humor Detection
# detector = HumorDetector()
# detector.train()

# detector.predict("This just in.")

# * Simple Humor Type Classification
# file2 = "backend/nlp_pipeline/data/normalized_jokes.csv"
# classifier = SimpleHumorTypeClassifier(input_file=file2)
# output_path = classifier.run()
# print(f"Classified humor saved to: {output_path}")

if __name__ == '__main__':
    # * Indexing
    indexer = Indexer()
    # indexer.push_content_to_firestore("backend/nlp_pipeline/data/classified_jokes.csv")
    # indexer.build_index("backend/nlp_pipeline/data/classified_jokes.csv")
    indexer.push_index_to_firestore("backend/nlp_pipeline/data/content_index.json")
    