from fastapi import FastAPI, Request
from googletrans import Translator
import logging
import re
import time

# --- FastAPI App Setup ---
app = FastAPI()
translator = Translator()

# --- Logging Setup ---
logging.basicConfig(
    filename="translation.log",
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)

# --- Translation Endpoint ---
@app.post("/translate")
async def translate_text(request: Request):
    data = await request.json()
    text = data.get("text", "").strip()

    logger.info(f"[INPUT] Raw user input: '{text}'")

    # --- Input Validation ---
    if not text:
        logger.info("[SKIPPED] Empty or whitespace-only input.")
        return {"language": None, "translated_text": ""}

    if re.fullmatch(r"[^\w\s]+", text):
        logger.info("[SKIPPED] Symbols only.")
        return {"language": None, "translated_text": ""}

    if text.isnumeric():
        logger.info("[SKIPPED] Numbers-only input.")
        return {"language": None, "translated_text": ""}

    try:
        # Detect Language
        detected_lang = translator.detect(text).lang
        logger.info(f"[INFO] Detected language: {detected_lang}")

        if detected_lang != "am":
            logger.info(f"[SKIPPED] Non-Amharic input. Language: {detected_lang}")
            return {"language": detected_lang, "translated_text": text}

        # --- Translation with one time Retry if the first attempt fails---
        for attempt in range(2):
            try:
                translated = translator.translate(text, src="am", dest="en")
                logger.info(f"[SUCCESS] Translated to: '{translated.text}'")
                return {
                    "language": "am",
                    "translated_text": translated.text
                }
            except Exception as e:
                logger.warning(f"[RETRY {attempt + 1}] Translation failed: {e}")
                if attempt == 0:
                    time.sleep(0.5)  # short wait
                else:
                    raise e

    except Exception as e:
        logger.error(f"[FAILURE] Translation error: {str(e)}")
        return {"language": None, "translated_text": ""}
