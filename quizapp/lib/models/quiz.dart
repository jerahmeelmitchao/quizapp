import 'question.dart';

class Quiz {
  final String title;
  final String summary;
  final List<String> keyPoints;
  final List<String> reviewerNotes;
  final List<Question> questions;

  Quiz({
    required this.title,
    required this.summary,
    required this.keyPoints,
    required this.reviewerNotes,
    required this.questions,
  });

  factory Quiz.fromJson(Map<String, dynamic> json) {
    return Quiz(
      title: json['title'] ?? 'Generated Quiz',
      summary: json['summary'] ?? '',
      keyPoints: List<String>.from(json['key_points'] ?? []),
      reviewerNotes: List<String>.from(json['reviewer_notes'] ?? []),
      questions: (json['questions'] as List<dynamic>? ?? [])
          .map((e) => Question.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'summary': summary,
      'key_points': keyPoints,
      'reviewer_notes': reviewerNotes,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}