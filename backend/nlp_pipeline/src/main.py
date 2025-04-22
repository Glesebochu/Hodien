from ..services.ContentFilterer import ContentFilterer
from ..services.HumorDetector import HumorDetector

# * Normalization
# content_filterer = ContentFilterer()
# file = "backend/nlp_pipeline/data/shortjokes.csv"
# content_filterer.normalize(file)

# * Humor Detection
HumorDetector.train()
classifier = HumorDetector()

classifier.predict("This just in.")


# * Humor type classification