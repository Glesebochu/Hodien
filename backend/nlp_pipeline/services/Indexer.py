import math
from collections import defaultdict

class Indexer:
    def __init__(self):
        self.index = defaultdict(lambda: {
            "content_ids": set(),
            "term_freqs": defaultdict(int),
            "metadata": []
        })
        self.document_count = 0
        self.doc_freq = defaultdict(int)  # For IDF

    def build_index(self, tokens: dict, contents: list):
        """
        tokens: Dict[content_id, List[str]]
        contents: List[Content]
        """
        self.document_count = len(contents)

        # Step 1: Build inverted index and term frequencies
        for content in contents:
            content_id = content.id
            content_tokens = tokens[content_id]
            seen_tokens = set()

            for token in content_tokens:
                entry = self.index[token]
                entry["content_ids"].add(content_id)
                entry["term_freqs"][content_id] += 1
                if token not in seen_tokens:
                    self.doc_freq[token] += 1
                    seen_tokens.add(token)
            
            # Optional: store metadata (can be a reference or full object)
            for token in seen_tokens:
                self.index[token]["metadata"].append({
                    "id": content_id,
                    "humor_type": content.humor_type,
                    "tone": content.tone,
                    "media_type": content.media_type
                })

        # Step 2: Compute optional TF-IDF weights
        for token, entry in self.index.items():
            idf = math.log(self.document_count / (1 + self.doc_freq[token]))
            entry["tf_idf"] = {}
            for content_id in entry["term_freqs"]:
                tf = entry["term_freqs"][content_id]
                entry["tf_idf"][content_id] = tf * idf
