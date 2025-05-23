import logging
import re
from collections import Counter
import traceback
from spellchecker import SpellChecker
from nltk.corpus import wordnet
from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
import firebase_admin
from firebase_admin import credentials
from firebase_admin import firestore
from backend.search_engine.models.UserQuery import UserQuery as UserQuery
from google.cloud.firestore_v1.base_query import FieldFilter
from fastapi.middleware.cors import CORSMiddleware
from .CustomStemmer import CustomPorterStemmer as CustomStemmer
from nltk.corpus import words




# # Logging setup
# logging.basicConfig(
#     level=logging.INFO,
#     format="%(asctime)s - %(levelname)s - %(message)s"
# )
# app = FastAPI()
# # Firebase Admin SDK Initialization (must be before firestore.client())
# if not firebase_admin._apps:
#     cred = credentials.Certificate("backend/search_engine/config/hodien-f5535-searchengine-adminsdk.json")
#     firebase_admin.initialize_app(cred)

# db = firestore.client()

# === DataPreprocessor Class 
class DataPreprocessor:
    def __init__(self):
        # Stop words are loaded once for efficiency
        with open('stopwords_en.txt') as f:
            self.stop_words = set(word.strip().lower() for word in f)

    # This function does the entire preprocessing pipeline
    def preprocess(self, text: str) -> dict:
        try:
            logging.info("Preprocessing started on: " + text)

            tokens = self.tokenize(text)
            corrected = self.correct_spelling(tokens)
            filtered = self.remove_stop_words(corrected)
            normalized = self.normalize(filtered)
            stemmed = self.stem_tokens(normalized)
            expanded = self.expand_synonyms(stemmed)
            weights = self.weigh_term(expanded)

            result = {
                "tokens": tokens,   
                "corrected_tokens": corrected,
                "filtered_tokens": filtered,
                "normalized_tokens": normalized,
                "stemmed_tokens": stemmed,
                "expanded_tokens": expanded,
                "term_weights": weights,
            }
            log_output = "Processed Results:\n"
            for key, value in result.items():
                log_output += f"{key}: {value}\n\n"
            logging.info(log_output)
            return result

        except Exception as e:
            tb = traceback.extract_tb(e.__traceback__)
            failed_function = tb[-1].name  # This gives the name of the function that threw the error
            logging.error(f"[DataPreprocessor.{failed_function}] Error: {str(e)}")
            raise e

    # A function that creates a UserQuery object after preprocessing the text
    def process_query(self, original_text: str, translated_text: str, language: str, user_id: str) -> str: 
        """ Preprocesses the original text, creates a UserQuery if not exists, otherwise reuses existing. 
        Always returns the Query ID. Links new user IDs if needed. Uses stemmed_tokens for checking query existence. """ 
        try: 
            # Step 1: Preprocess to get stemmed tokens 
            logging.info(f"[Preprocessing] Starting preprocessing for: '{original_text}'") 
            text_to_preprocess = translated_text if translated_text else original_text 
            preprocessing_result = self.preprocess(text_to_preprocess) 
            stemmed_tokens = preprocessing_result.get("stemmed_tokens", [])

            # Step 2: Check if query already exists by stemmed_tokens
            query_ref = db.collection('user_queries').where(
                filter=FieldFilter('stemmed_tokens', '==', stemmed_tokens)
            ).limit(1)
            results = query_ref.stream()

            for doc in results:
                existing_query = doc.to_dict()
                query_id = existing_query.get("id")
                logging.info(f"[Found Existing Query] ID: {query_id}")

                user_ids = existing_query.get("user_ids", [])

                if user_id in user_ids:
                    logging.info(f"[User Linked] User {user_id} already linked to query {query_id}.")
                    return query_id  # ✅ Already linked
                else:
                    user_ids.append(user_id)
                    db.collection('user_queries').document(query_id).update({
                        "user_ids": user_ids
                    })
                    logging.info(f"[User Linked] User {user_id} linked to existing query {query_id}.")
                    return query_id  # ✅ Now linked

            # Step 3: Save new query if no match found
            logging.info(f"[No Existing Query Found] Saving new query: '{original_text}'")
            new_user_query = UserQuery(db)
            new_query_id = new_user_query.create(
                original_text=original_text,
                translated_text=translated_text,
                language=language,
                user_id=user_id,
                tokens=preprocessing_result.get("tokens", []),
                corrected_tokens=preprocessing_result.get("corrected_tokens", []),
                stemmed_tokens=stemmed_tokens,
                expanded_tokens=preprocessing_result.get("expanded_tokens", []),
                term_weights=preprocessing_result.get("term_weights", {}),
            )

            logging.info(f"[New Query Saved] ID: {new_query_id}")
            return new_query_id

        except Exception as e:
            logging.error(f"[process_query Error] {str(e)}")
            raise e

    # --- Individual Processing Functions ---

    def tokenize(self, text: str):
        return text.split()

    def normalize(self, tokens):
        """
        Converts tokens to lowercase, strips whitespace, and removes punctuation.
        Skips tokens that are None, empty, or not strings.
        """
        if not isinstance(tokens, list):
            return tokens

        normalized = []
        for token in tokens:
            if isinstance(token, str):
                # Lowercase, strip spaces, remove non-word characters (punctuation)
                clean = re.sub(r'[^\w\s]', '', token.lower().strip())
                if clean:
                    normalized.append(clean)
        return normalized if normalized else tokens

    def remove_stop_words(self, tokens):
        tokens = [token.lower() if isinstance(token, str) else token for token in tokens]
        return [token for token in tokens if token not in self.stop_words]

    def correct_spelling(self, tokens):
        spell = SpellChecker()
        if not tokens:
            return tokens  # Return tokens if input is empty or None

        corrected = []
        for token in tokens:
            correction = spell.correction(token)
            corrected.append(correction if correction else token)  # Use original token if no correction is found

        return corrected
    
    def stem_tokens(self, tokens):
        if not tokens:
            return tokens

        try:
            valid_tokens = [token for token in tokens if token is not None]
            stemmer = CustomStemmer()
            stemmed = [stemmer.stem(token) for token in valid_tokens]
            return stemmed if stemmed else tokens

        except Exception as e:
            logging.error(f"[stem_tokens] Stemming error: {str(e)}")
            raise RuntimeError(f"Stemming failed at stem_tokens: {str(e)}")

    def expand_synonyms(self, tokens):
        if not isinstance(tokens, list):
            return tokens

        tokens = [t for t in tokens if isinstance(t, str) and t]  # Clean original tokens
        expanded = set(tokens)  # Use set to avoid duplicates

        for token in tokens:
            try:
                synonyms = set()
                for syn in wordnet.synsets(token):
                    for lemma in syn.lemmas():
                        synonym = lemma.name().lower().replace('_', ' ')
                        synonyms.add(synonym)

                new_synonyms = synonyms - expanded  # Only add new ones
                expanded.update(new_synonyms)

            except Exception as e:
                logging.warning(f"Synonym expansion error for token '{token}': {e}")
                continue

        return sorted(expanded)

    def weigh_term(self, tokens):
        if not tokens:
            return tokens

        counts = Counter(tokens)
        total = sum(counts.values())

        result = {token: round(count / total, 3) for token, count in counts.items()}
        return result if result else tokens
    
# app.add_middleware( CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
# @app.post("/preprocess")
# async def preprocess_query(request: Request):
#     try:
#         data = await request.json()
#         original_text = data.get("original_text", "").strip()
#         translated_text = data.get("translated_text", "").strip()
#         language = data.get("language", "").strip()
#         user_id = data.get("user_id", "").strip()

#         if not original_text or not user_id:
#             return JSONResponse(content={"error": "Missing required fields"}, status_code=400)

#         preprocessor = DataPreprocessor()
#         query_id = preprocessor.process_query(
#             original_text=original_text,
#             translated_text=translated_text,
#             language=language,
#             user_id=user_id,
#         )

#         return {"queryId": query_id}
#     except Exception as e:
#         logging.error(f"[Preprocessing Error] {str(e)}")
#         return JSONResponse(
#             content={"error": str(e)},
#             status_code=500
#         )


# if __name__ == "__main__":
#     preprocessor = DataPreprocessor()
#     preprocessor.process_query(
#         original_text="Why did the scarecrow become a comedian? He's outstanding they'll!",
#         translated_text="",
#         language="en",
#         user_id="user123"
#     )