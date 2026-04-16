class Question {
  final String type;
  final String question;
  final List<String> choices;
  final String answer;
  final String explanation;
  final String difficulty;
  final String sourceSection;

  Question({
    required this.type,
    required this.question,
    required this.choices,
    required this.answer,
    required this.explanation,
    required this.difficulty,
    required this.sourceSection,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      type: json['type'] ?? '',
      question: json['question'] ?? '',
      choices: List<String>.from(json['choices'] ?? []),
      answer: json['answer'] ?? '',
      explanation: json['explanation'] ?? '',
      difficulty: json['difficulty'] ?? 'easy',
      sourceSection: json['source_section'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'question': question,
      'choices': choices,
      'answer': answer,
      'explanation': explanation,
      'difficulty': difficulty,
      'source_section': sourceSection,
    };
  }
}