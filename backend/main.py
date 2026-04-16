from fastapi import FastAPI, UploadFile, File, HTTPException
from fastapi.middleware.cors import CORSMiddleware

from services.extractor import extract_text_from_upload
from services.ai_service import generate_ai_quiz

app = FastAPI(title="QuizGen API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

ALLOWED_EXTENSIONS = {"pdf", "docx", "pptx"}


def get_extension(filename: str) -> str:
    if "." not in filename:
        return ""
    return filename.rsplit(".", 1)[1].lower()


@app.get("/")
def root():
    return {"message": "QuizGen backend is running"}


@app.post("/api/generate-quiz")
async def generate_quiz(file: UploadFile = File(...)):
    print("GENERATE QUIZ HIT")
    print("FILENAME:", file.filename)

    if not file.filename:
        raise HTTPException(status_code=400, detail="No file uploaded")

    ext = get_extension(file.filename)
    print("EXTENSION:", ext)

    if ext not in ALLOWED_EXTENSIONS:
        raise HTTPException(
            status_code=400,
            detail="Unsupported file type. Use pdf, docx, or pptx only.",
        )

    try:
        print("STARTING EXTRACTION...")
        extracted_text = await extract_text_from_upload(file, ext)
        print("EXTRACTION DONE")
        print("EXTRACTED TEXT LENGTH:", len(extracted_text))
        print("EXTRACTED TEXT PREVIEW:", extracted_text[:300])
    except Exception as e:
        print("EXTRACTION ERROR:", str(e))
        raise HTTPException(
            status_code=500,
            detail=f"Text extraction failed: {str(e)}",
        )

    if not extracted_text.strip():
        raise HTTPException(
            status_code=400,
            detail="No readable text found in document",
        )

    try:
        print("STARTING AI GENERATION...")
        quiz = generate_ai_quiz(extracted_text, file.filename)
        print("AI GENERATION DONE")
    except Exception as e:
        print("AI QUIZ GENERATION ERROR:", str(e))
        raise HTTPException(
            status_code=500,
            detail=f"AI quiz generation failed: {str(e)}",
        )

    return quiz