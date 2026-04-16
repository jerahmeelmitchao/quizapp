import 'package:flutter/material.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/theme/theme_controller.dart';
import '../../models/quiz.dart';

class ResultPage extends StatelessWidget {
  final int score;
  final int total;
  final Quiz quiz;
  final Map<int, String> selectedAnswers;
  final ThemeController themeController;

  const ResultPage({
    super.key,
    required this.score,
    required this.total,
    required this.quiz,
    required this.selectedAnswers,
    required this.themeController,
  });

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;
    final percent = ((score / total) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Result')),
      body: AppShell(
        themeController: themeController,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 64,
                        color: palette.secondary,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        '$score / $total',
                        style: TextStyle(
                          color: palette.textDark,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$percent% Score',
                        style: TextStyle(
                          color: palette.muted,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: quiz.questions.length,
                  itemBuilder: (context, index) {
                    final q = quiz.questions[index];
                    final userAnswer = selectedAnswers[index] ?? 'No answer';
                    final correct = userAnswer == q.answer;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Icon(
                          correct ? Icons.check_circle : Icons.cancel,
                          color: correct ? Colors.green : Colors.red,
                        ),
                        title: Text(
                          q.question,
                          style: TextStyle(
                            color: palette.textDark,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        subtitle: Text(
                          'Your answer: $userAnswer\nCorrect answer: ${q.answer}',
                          style: TextStyle(color: palette.muted),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}