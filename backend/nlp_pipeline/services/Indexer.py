import math
import csv
from collections import defaultdict
from backend.shared_utils.services.DataPreprocessor import DataPreprocessor

# Initialize Firestore
import firebase_admin
from firebase_admin import credentials, firestore

class Indexer:
    def __init__(self):
        self.index = defaultdict(lambda: {
            "content_ids": set(),
            "term_freqs": defaultdict(int),
            "metadata": []
        })
        
        self.term_freq = defaultdict(lambda: defaultdict(int))  # term -> doc_id -> freq
        self.doc_count = 0  # Total documents
        self.term_doc_count = defaultdict(int)  # term -> number of docs containing it
        self.inverted_index = defaultdict(int)
        
        cred = credentials.Certificate("backend/nlp_pipeline/config/hodien-f5535-firebase-adminsdk-fbsvc-dd2b2fc2a9.json")
        firebase_admin.initialize_app(cred)
        self.db = firestore.client()

    def build_index(self, csv_file_path: str):
        """
        tokens: Dict[content_id, List[str]]
        contents: List[Content]
        """
        # Initialize NLP tools
        data_pp = DataPreprocessor()

        # 1. Read CSV
        records = []
        with open(csv_file_path, 'r') as f:
            reader = csv.DictReader(f)
            for row in reader:
                records.append({
                    'id': row['id'],
                    'text': row['text'],
                    'emoji_presence': row['emoji_presence'].lower() == 'true',
                    'humor_type': row['humor_type'],
                    'humor_type_score': float(row['humor_type_score'])
                })
                
        self.doc_count = len(records)

        for record in records:
            doc_id = record['id']
            # Tokenize and stem
            tokens = data_pp.tokenize(record['text'])
            
            # Normalize
            normalized_tokens = data_pp.normalize(tokens)
            
            # Remove stop words
            stop_word_free_tokens = data_pp.remove_stop_words(normalized_tokens)
            
            # Fix spelling
            spell_checked_tokens = data_pp.correct_spelling(stop_word_free_tokens)
            
            #Stem tokens
            terms = data_pp.stem_tokens(spell_checked_tokens)
            
            for term in terms:
                self.term_freq[term][doc_id] += 1
                self.term_doc_count[term] += 1 if self.term_freq[term][doc_id] == 1 else 0

        # 3. Calculate TF-IDF weights
        for term in self.term_freq:
            idf = math.log(self.doc_count / (self.term_doc_count[term] + 1))  # Avoid division by zero
            for doc_id in self.term_freq[term]:
                tf = self.term_freq[term][doc_id]
                weight = tf * idf
                # Find record for metadata
                record = next(r for r in records if r['id'] == doc_id)
                self.inverted_index[term].append({
                    'id': doc_id,
                    'humor_type': record['humor_type'],
                    'emoji_presence': record['emoji_presence'],
                    'humor_type_score': record['humor_type_score'],
                    'weight': weight
                })

        # 4. Store in Firestore
        index_collection = self.db.collection('inverted_index')
        for term, postings in self.inverted_index.items():
            index_collection.document(term).set({'postings': postings})
