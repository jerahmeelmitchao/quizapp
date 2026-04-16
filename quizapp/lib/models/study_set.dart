import 'question.dart';

class Flashcard {
  final String front;
  final String back;

  Flashcard({required this.front, required this.back});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      front: json['front'],
      back: json['back'],
    );
  }

  Map<String, dynamic> toJson() => {
        'front': front,
        'back': back,
      };
}

class StudySet {
  final String id;
  final String title;
  final DateTime createdAt;
  final String folderId;

  final List<String> reviewerNotes;
  final List<Flashcard> flashcards;
  final List<Question> questions;

  StudySet({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.reviewerNotes,
    required this.flashcards,
    required this.questions,
    required this.folderId,
  });

  factory StudySet.fromJson(Map<String, dynamic> json) {
    return StudySet(
      id: json['id'],
      title: json['title'],
      createdAt: DateTime.parse(json['created_at']),

      // ✅ FIXED HERE
      folderId: json['folder_id'] ?? '',

      reviewerNotes: List<String>.from(json['reviewer_notes'] ?? []),
      flashcards: (json['flashcards'] as List? ?? [])
          .map((e) => Flashcard.fromJson(e))
          .toList(),
      questions: (json['questions'] as List? ?? [])
          .map((e) => Question.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'created_at': createdAt.toIso8601String(),

        // ✅ FIXED HERE
        'folder_id': folderId,

        'reviewer_notes': reviewerNotes,
        'flashcards': flashcards.map((e) => e.toJson()).toList(),
        'questions': questions.map((e) => e.toJson()).toList(),
      };
}