from typing import List, Literal
from pydantic import BaseModel, Field


Difficulty = Literal["easy", "medium", "hard"]
QuestionType = Literal[
    "multiple_choice",
    "true_false",
    "identification",
    "short_answer",
    "fill_in_the_blank",
]


class Question(BaseModel):
    type: QuestionType = Field(description="Type of question.")
    question: str = Field(description="The actual quiz question.")
    choices: List[str] = Field(
        default_factory=list,
        description="Choices for multiple choice or true/false questions. Empty for open-ended questions.",
    )
    answer: str = Field(description="Correct answer.")
    explanation: str = Field(description="Short explanation of why the answer is correct.")
    difficulty: Difficulty = Field(description="Question difficulty.")
    source_section: str = Field(description="Which part of the lesson this came from.")


class QuizResponse(BaseModel):
    title: str = Field(description="Short title based on the lesson.")
    summary: str = Field(description="Short lesson summary.")
    key_points: List[str] = Field(description="Important key points from the lesson.")
    reviewer_notes: List[str] = Field(description="Condensed reviewer notes for study.")
    questions: List[Question] = Field(description="Generated quiz questions.")