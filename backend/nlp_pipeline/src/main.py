from ..services.ContentFilterer import ContentFilterer

content_filterer = ContentFilterer()

file = "backend/nlp_pipeline/data/shortjokes.csv"

content_filterer.normalize(file)