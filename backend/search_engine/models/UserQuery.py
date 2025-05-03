import logging
import datetime
import uuid
from google.cloud import firestore
from datetime import datetime, timezone
# import firebase_admin
# from firebase_admin import credentials
# from firebase_admin import firestore


# === Logging Setup ===
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s",
)

# # === Firestore Initialization ===
# if not firebase_admin._apps:
#     cred = credentials.Certificate("backend/search_engine/config/hodien-f5535-searchengine-adminsdk.json")
#     firebase_admin.initialize_app(cred)

# db = firestore.client()

# === UserQuery Class ===
class UserQuery:
    def __init__(self, db):
        self.db = db


    def create(self, 
           original_text: str,
           translated_text: str,
           language: str,
           user_id: str,
           tokens: list,
           corrected_tokens: list,
           stemmed_tokens: list,
           expanded_tokens: list,
           term_weights: dict,
           id: str = None) -> str:
        """
        Creates a new user query document in Firestore.
        Always returns the query ID.
        """
        try:
            query_id = id or str(uuid.uuid4())
            doc_ref = self.db.collection('user_queries').document(query_id)

            data = {
                "id": query_id,
                "original_text": original_text,
                "translated_text": translated_text,
                "language": language,
                "user_ids": [user_id],  # Note: user_ids is a list now
                "created_at": datetime.now(timezone.utc).isoformat(),                
                "tokens": tokens,
                "corrected_tokens": corrected_tokens,
                "stemmed_tokens": stemmed_tokens,
                "expanded_tokens": expanded_tokens,
                "term_weights": term_weights,
            }

            doc_ref.set(data)
            logging.info(f"[Create] Query with ID: {query_id} created successfully.")
            return query_id

        except Exception as e:
            logging.error(f"[Create Error] {str(e)}")
            raise e

    def delete(self, query_id: str) -> bool:
        """
        Deletes a query document by its ID.
        """
        try:
            doc_ref = self.db.collection('user_queries').document(query_id)
            doc_snapshot = doc_ref.get()

            if doc_snapshot.exists:
                doc_ref.delete()
                logging.info(f"[Delete] Query with ID: {query_id} deleted successfully.")
                return True
            else:
                logging.warning(f"[Delete] Query with ID: {query_id} not found.")
                return False
        except Exception as e:
            logging.error(f"[Delete Error] {str(e)}")
            return False

# if __name__ == "__main__":
#     # Example usage
#     user_query = UserQuery()  # ✅ First instantiate the object

#     query_id = user_query.create(
#         original_text="The quick brown fox jumps over the lazy dog.",
#         translated_text="The quick brown fox jumps over the lazy dog.",
#         language="en",
#         user_id="user_123",  # Example user ID
#         tokens=["quick", "brown", "fox", "jumps", "lazy", "dog"],
#         corrected_tokens=["quick", "brown", "fox", "jump", "lazy", "dog"],
#         stemmed_tokens=["quick", "brown", "fox", "jump", "lazi", "dog"],
#         expanded_tokens=["quick", "fast", "swift", "brown", "fox", "canine", "jump", "leap", "hop", "lazy", "dog", "pooch"],
#         term_weights={"quick": 0.15, "brown": 0.12, "fox": 0.13, "jump": 0.11, "lazy": 0.1, "dog": 0.1}
#     )

