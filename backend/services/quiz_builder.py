import re
from collections import Counter


STOPWORDS = {
    "the", "is", "are", "and", "or", "of", "to", "in", "a", "an", "for",
    "on", "with", "by", "as", "at", "from", "that", "this", "it", "be",
    "was", "were", "can", "will", "into", "their", "these", "those", "than",
    "have", "has", "had", "but", "not", "you", "your", "about", "also"
}


def build_mock_quiz(filename: str, content: str) -> dict:
    summary = build_summary(content)
    keywords = extract_keywords(content)
    questions = build_questions_from_keywords(keywords)

    title = clean_title_from_filename(filename)

    return {
        "title": f"{title} Quiz",
        "summary": summary,
        "questions": questions,
    }


def clean_title_from_filename(filename: str) -> str:
    if "." in filename:
        filename = filename.rsplit(".", 1)[0]

    filename = filename.replace("_", " ").replace("-", " ").strip()
    return filename.title() or "Generated"


def build_summary(content: str) -> str:
    text = re.sub(r"\s+", " ", content).strip()
    if len(text) <= 220:
        return text
    return text[:220].rstrip() + "..."


def extract_keywords(content: str, limit: int = 4) -> list[str]:
    words = re.findall(r"[A-Za-z][A-Za-z0-9\-]+", content.lower())
    filtered = [word for word in words if word not in STOPWORDS and len(word) > 3]
    counter = Counter(filtered)
    return [word for word, _ in counter.most_common(limit)]


def build_questions_from_keywords(keywords: list[str]) -> list[dict]:
    if not keywords:
        keywords = ["lesson", "topic", "concept", "content"]

    questions = []
    distractor_pool = [
        "Monitor", "Keyboard", "Software", "Network", "Database",
        "Printer", "Algorithm", "Memory", "System", "Application"
    ]

    for i, keyword in enumerate(keywords[:4]):
        correct = keyword.title()
        choices = [correct]

        for item in distractor_pool:
            if item.lower() != keyword.lower() and item not in choices:
                choices.append(item)
            if len(choices) == 4:
                break

        questions.append({
            "type": "multiple_choice",
            "question": "Which term is strongly related to the uploaded lesson content?",
            "choices": choices,
            "answer": correct,
            "explanation": f"'{correct}' appeared as one of the important repeated terms in the lesson.",
            "difficulty": "easy" if i < 2 else "medium",
        })

    questions.append({
        "type": "true_false",
        "question": "The quiz was generated from the uploaded lesson document.",
        "choices": ["True", "False"],
        "answer": "True",
        "explanation": "The backend extracted text from your uploaded file before creating the quiz.",
        "difficulty": "easy",
    })

    return questions