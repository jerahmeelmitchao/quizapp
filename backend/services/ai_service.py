import os
import json
import re
from textwrap import shorten

from dotenv import load_dotenv
from openai import OpenAI

load_dotenv()

OPENROUTER_API_KEY = os.getenv("OPENROUTER_API_KEY")
OPENROUTER_MODEL = os.getenv("OPENROUTER_MODEL", "openai/gpt-oss-120b:free")

if not OPENROUTER_API_KEY:
    raise RuntimeError("OPENROUTER_API_KEY is missing in environment variables")

client = OpenAI(
    api_key=OPENROUTER_API_KEY,
    base_url="https://openrouter.ai/api/v1",
)

print("OPENROUTER KEY FOUND:", bool(OPENROUTER_API_KEY))
print("OPENROUTER MODEL:", OPENROUTER_MODEL)


def clean_extracted_text(text: str) -> str:
    text = text.replace("\x00", " ")
    text = re.sub(r"\r\n|\r", "\n", text)
    text = re.sub(r"[ \t]+", " ", text)
    text = re.sub(r"\n{3,}", "\n\n", text)
    return text.strip()


def trim_for_model(text: str, max_chars: int = 7000) -> str:
    text = clean_extracted_text(text)
    if len(text) <= max_chars:
        return text
    return shorten(text, width=max_chars, placeholder="\n\n[Content truncated for length]")


def generate_ai_quiz(content: str, filename: str):
    cleaned = trim_for_model(content)

    prompt = f"""
You are an expert teacher, reviewer creator, instructional designer, and assessment writer.

Your job is to analyze the uploaded lesson and create a high-quality reviewer and quiz.
Use ONLY the uploaded lesson content.
Do not invent facts, examples, or answers not supported by the lesson.
Return ONLY valid JSON.
Do not wrap JSON in markdown.
Do not include any explanation outside the JSON.

Return this exact JSON structure:

{{
  "title": "...",
  "summary": "...",
  "key_points": ["..."],
  "reviewer_notes": ["..."],
  "questions": [
    {{
      "type": "multiple_choice",
      "question": "...",
      "choices": ["...", "...", "...", "..."],
      "answer": "...",
      "explanation": "...",
      "difficulty": "easy",
      "source_section": "..."
    }}
  ]
}}

Core task:
1. Read the lesson carefully.
2. Identify the main sections, subtopics, concepts, definitions, processes, comparisons, examples, and facts.
3. Judge how rich the lesson is:
   - If the lesson is short or shallow, generate fewer but meaningful questions.
   - If the lesson is detailed and content-rich, generate more questions.
4. Base the number of quiz items on how many important ideas are actually present in the lesson.
5. Give more questions to sections with more important or detailed content, and fewer questions to minor sections.

Requirements for the reviewer:
- Create a clear and accurate lesson title.
- Write a short summary in 2 to 4 sentences.
- Extract 5 to 12 key points.
- Create 5 to 12 reviewer notes that are concise, exam-focused, and easy to memorize.
- Make reviewer notes useful for studying, not just copied phrases.

Requirements for the quiz:
- Generate between 8 and 30 high-quality questions depending on topic richness.
- The number of questions must be based on:
  - lesson length
  - number of important concepts
  - amount of explanation in the lesson
  - number of sections/subtopics
  - depth of definitions, processes, and examples
- Use a balanced and natural mix of:
  - multiple_choice
  - true_false
  - identification
  - short_answer
- Do not force question types when they do not fit the lesson.
- Prefer quality over quantity.
- Avoid repetitive, trivial, overly obvious, or duplicate questions.
- Cover the most important concepts first.
- Focus on understanding, not just word matching.
- Include questions from different sections of the lesson when possible.
- Use classroom-quality wording.

Question-writing rules:
- Each question must include:
  - type
  - question
  - choices
  - answer
  - explanation
  - difficulty
  - source_section
- For multiple_choice, provide exactly 4 choices.
- For true_false, choices must be ["True", "False"].
- For identification and short_answer, choices must be [].
- Make distractors plausible for multiple choice.
- Do not make all questions easy.
- Use an appropriate mix of:
  - easy
  - medium
  - hard
- Prefer questions about:
  - definitions
  - functions/purposes
  - comparisons/differences
  - steps/processes
  - cause and effect
  - applications/examples
- Avoid questions that are answerable without reading the lesson.

Quality checks before finalizing:
- Make sure every answer is supported by the lesson.
- Make sure explanations are specific and helpful.
- Make sure the quiz reflects the richness of the lesson.
- Make sure the questions are not all about the same small part of the lesson.
- Make sure source_section clearly points to the topic or part of the lesson the item came from.

Document name:
{filename}

Lesson:
\"\"\"
{cleaned}
\"\"\"
"""

    response = client.chat.completions.create(
        model=OPENROUTER_MODEL,
        messages=[
            {
                "role": "system",
                "content": (
                    "You are a professional quiz and reviewer generator. "
                    "Return only raw JSON that exactly matches the requested structure."
                )
            },
            {
                "role": "user",
                "content": prompt
            }
        ],
        temperature=0.2,
    )

    text = response.choices[0].message.content or ""
    print("RAW OPENROUTER RESPONSE:")
    print(text)

    try:
        return json.loads(text)
    except json.JSONDecodeError:
        match = re.search(r"\{.*\}", text, re.DOTALL)
        if not match:
            raise Exception("OpenRouter did not return valid JSON")
        return json.loads(match.group())