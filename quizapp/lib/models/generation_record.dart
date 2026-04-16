import 'quiz.dart';

class GenerationRecord {
  final String id;
  final String fileName;
  final DateTime createdAt;
  final Quiz quiz;
  final int? lastScore;
  final int? totalItems;

  GenerationRecord({
    required this.id,
    required this.fileName,
    required this.createdAt,
    required this.quiz,
    this.lastScore,
    this.totalItems,
  });

  factory GenerationRecord.fromJson(Map<String, dynamic> json) {
    return GenerationRecord(
      id: json['id'],
      fileName: json['file_name'],
      createdAt: DateTime.parse(json['created_at']),
      quiz: Quiz.fromJson(json['quiz']),
      lastScore: json['last_score'],
      totalItems: json['total_items'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_name': fileName,
      'created_at': createdAt.toIso8601String(),
      'quiz': quiz.toJson(),
      'last_score': lastScore,
      'total_items': totalItems,
    };
  }

  GenerationRecord copyWith({
    int? lastScore,
    int? totalItems,
  }) {
    return GenerationRecord(
      id: id,
      fileName: fileName,
      createdAt: createdAt,
      quiz: quiz,
      lastScore: lastScore ?? this.lastScore,
      totalItems: totalItems ?? this.totalItems,
    );
  }
}