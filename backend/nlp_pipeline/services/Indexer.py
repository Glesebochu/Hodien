import math
import csv
import json
from collections import defaultdict
from backend.shared_utils.services.DataPreprocessor import DataPreprocessor
from multiprocessing import Pool, cpu_count

# Initialize Firestore
import firebase_admin
from firebase_admin import credentials, firestore

class Indexer:
    def __init__(self):
        self.index = defaultdict(Indexer.default_index_entry)
        self.term_freq = defaultdict(Indexer.default_term_freq_entry)  # term -> doc_id -> freq
        self.doc_count = 0  # Total documents
        self.term_doc_count = defaultdict(int)  # term -> number of docs containing it
        self.content_index = defaultdict(list)  # Change from int to list

        # Firestore client initialization moved to a separate method
        self.db = None

    @staticmethod
    def default_index_entry():
        return {
            "content_ids": set(),
            "term_freqs": defaultdict(int),
            "metadata": []
        }

    @staticmethod
    def default_term_freq_entry():
        return defaultdict(int)

    def initialize_firestore(self):
        """Initialize the Firestore client."""
        cred = credentials.Certificate("backend/nlp_pipeline/config/hodien-f5535-firebase-adminsdk-fbsvc-dd2b2fc2a9.json")
        firebase_admin.initialize_app(cred)
        self.db = firestore.client()

    def process_record(self, record):
        data_pp = DataPreprocessor()
        doc_id = record['id']
        tokens = data_pp.tokenize(record['text'])
        normalized_tokens = data_pp.normalize(tokens)
        stop_word_free_tokens = data_pp.remove_stop_words(normalized_tokens)
        terms = data_pp.stem_tokens(stop_word_free_tokens)
        
        print(f"Processing ${doc_id}")

        term_data = []
        for term in terms:
            term_data.append((term, doc_id))
        return term_data, record

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

        # Parallel processing
        with Pool(cpu_count()) as pool:
            results = pool.map(self.process_record, records)

        for term_data, record in results:
            doc_id = record['id']
            for term, doc_id in term_data:
                self.term_freq[term][doc_id] += 1
                self.term_doc_count[term] += 1 if self.term_freq[term][doc_id] == 1 else 0

        # Firestore operations (ensure this is done outside multiprocessing)
        if self.db is None:
            self.initialize_firestore()

        # 3. Calculate TF-IDF weights
        for term in self.term_freq:
            idf = math.log(self.doc_count / (self.term_doc_count[term] + 1))  # Avoid division by zero
            for doc_id in self.term_freq[term]:
                tf = self.term_freq[term][doc_id]
                weight = round(tf * idf,4)
                # Find record for metadata
                record = next(r for r in records if r['id'] == doc_id)
                self.content_index[term].append({
                    'id': doc_id,
                    'humor_type': record['humor_type'],
                    'emoji_presence': record['emoji_presence'],
                    'humor_type_score': record['humor_type_score'],
                    'weight': weight
                })

        # 4. Write index to a JSON file
        with open('backend/nlp_pipeline/data/content_index.json', 'w') as json_file:
            json.dump(self.content_index, json_file, indent=4)

        # 5. Push to Firestore
        self.push_to_firestore()

    def push_to_firestore(self, json_file_path: str = None):
        """Push the content index to Firestore, skipping existing terms.

        Args:
            json_file_path (str, optional): Path to a JSON file containing the content index.
        """
        # Load content index from JSON file if provided
        if json_file_path:
            with open(json_file_path, 'r') as f:
                content_index = json.load(f)
        else:
            content_index = self.content_index

        # Fetch existing terms from Firestore
        existing_terms = set()
        if self.db is None:
            self.initialize_firestore()
        index_collection = self.db.collection('content_index')
        for doc in index_collection.stream():
            existing_terms.add(doc.id)

        # Store new terms in Firestore
        for term, posts in content_index.items():
            if not term.strip() or term in existing_terms:  # Skip empty or already existing terms
                continue
            index_collection.document(term).set({'posts': posts})
            print(f"Added ${term} to Firestore")
