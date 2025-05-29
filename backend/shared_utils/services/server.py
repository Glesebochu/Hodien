from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from backend.shared_utils.services.DataPreprocessor import DataPreprocessor
from fastapi.responses import JSONResponse
import logging


# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(levelname)s - %(message)s"
)


app = FastAPI()

app.add_middleware( CORSMiddleware, allow_origins=["*"], allow_credentials=True, allow_methods=["*"], allow_headers=["*"])
@app.post("/preprocess")
async def preprocess_query(request: Request):
    try:
        data = await request.json()
        original_text = data.get("original_text", "").strip()
        translated_text = data.get("translated_text", "").strip()
        language = data.get("language", "").strip()
        user_id = data.get("user_id", "").strip()

        if not original_text or not user_id:
            return JSONResponse(content={"error": "Missing required fields"}, status_code=400)

        preprocessor = DataPreprocessor()
        query_id = preprocessor.process_query(
            original_text=original_text,
            translated_text=translated_text,
            language=language,
            user_id=user_id,
        )

        return {"queryId": query_id}
    except Exception as e:
        logging.error(f"[Preprocessing Error] {str(e)}")
        return JSONResponse(
            content={"error": str(e)},
            status_code=500
        )
