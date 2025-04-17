from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from googletrans import Translator
import logging
import re
import time

# --- FastAPI App Setup ---
app = FastAPI()
translator = Translator()

# Add cors support to the app
app.add_middleware( CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])

# --- Logging Setup ---
logging.basicConfig(
    filename="translation.log",  # Log file location
    level=logging.INFO,          # Log level
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger("translation_logger")  

# --- Translation Endpoint ---
@app.post("/translate")
async def translate_text(request: Request):
    data = await request.json()
    text = data.get("text", "").strip()

    logger.info(f"[INPUT] Raw user input: '{text}'")

    # # --- Input Validation ---
    # if not text:
    #     logger.info("[SKIPPED] Empty or whitespace-only input.")
    #     return {"language": None, "translated_text": ""}

    # if re.fullmatch(r"[^\w\s]+", text):
    #     logger.info("[SKIPPED] Symbols only.")
    #     return {"language": None, "translated_text": ""}

    # if text.isnumeric():
    #     logger.info("[SKIPPED] Numbers-only input.")
    #     return {"language": None, "translated_text": ""}
    
    # Translation logic where we append the translated text onto the json object and the error message if any 
    try:
        # Check the language of the input text
        detected_lang = translator.detect(text).lang
        logger.info(f"[INFO] Detected language: {detected_lang}")

        if detected_lang != "am":
            logger.info(f"[SKIPPED] Non-Amharic input. Language: {detected_lang}")
            # Return the detected language and the original text
            return {"language": detected_lang, "translated_text": text}

        # Try translation with 1 retry
        for attempt in range(2):
            try:
                translated = translator.translate(text, src="am", dest="en")
                logger.info(f"[SUCCESS] Translated to: '{translated.text}'")
                # Return the translated text and the detected language
                return {
                    "language": "am",
                    "translated_text": translated.text
                }
            except Exception as e:
                logger.warning(f"[RETRY {attempt + 1}] Translation failed: {e}")
                if attempt == 0:
                    time.sleep(0.5)
                else:
                    raise e

    except Exception as e:
        logger.error(f"[FAILURE] Translation error: {str(e)}")
        # Return the error message and null
        return {"language": None, "translated_text": "", "error" : str(e)
                }