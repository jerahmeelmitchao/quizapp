import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';
import '../../models/study_set.dart';

class FlashcardQuizPage extends StatefulWidget {
  final ThemeController themeController;
  final StudySet studySet;

  const FlashcardQuizPage({
    super.key,
    required this.themeController,
    required this.studySet,
  });

  @override
  State<FlashcardQuizPage> createState() => _FlashcardQuizPageState();
}

class _FlashcardQuizPageState extends State<FlashcardQuizPage> {
  late List<_QuizItem> questions;
  int currentIndex = 0;
  String? selectedAnswer;
  bool? isCorrect;
  int score = 0;
  bool finished = false;

  @override
  void initState() {
    super.initState();
    _buildQuiz();
  }

  void _buildQuiz() {
    final cards = widget.studySet.flashcards;
    final rng = Random();
    final allBacks = cards.map((c) => c.back).toList();

    questions = cards.map((card) {
      // Build wrong choices from other cards' backs
      final wrongPool = allBacks.where((b) => b != card.back).toList()
        ..shuffle(rng);
      final wrongChoices = wrongPool.take(3).toList();

      final choices = [card.back, ...wrongChoices]..shuffle(rng);

      return _QuizItem(
        question: card.front,
        correctAnswer: card.back,
        choices: choices,
      );
    }).toList()
      ..shuffle(rng);
  }

  void _selectAnswer(String answer) {
    if (isCorrect != null) return; // already answered
    final correct = answer == questions[currentIndex].correctAnswer;
    setState(() {
      selectedAnswer = answer;
      isCorrect = correct;
      if (correct) score++;
    });
  }

  void _next() {
    if (currentIndex < questions.length - 1) {
      setState(() {
        currentIndex++;
        selectedAnswer = null;
        isCorrect = null;
      });
    } else {
      setState(() => finished = true);
    }
  }

  void _restart() {
    setState(() {
      _buildQuiz();
      currentIndex = 0;
      selectedAnswer = null;
      isCorrect = null;
      score = 0;
      finished = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;

    if (finished) {
      return _ResultScreen(
        score: score,
        total: questions.length,
        palette: palette,
        onRestart: _restart,
        onExit: () => Navigator.pop(context),
      );
    }

    final q = questions[currentIndex];
    final hasSingleCard = widget.studySet.flashcards.length < 2;

    if (hasSingleCard) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: AppShell(
          themeController: widget.themeController,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(30),
              child: Text(
                'You need at least 2 flashcards in this set to generate a multiple-choice quiz.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: palette.textLight,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz: ${widget.studySet.title}'),
      ),
      body: AppShell(
        themeController: widget.themeController,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              // Progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${currentIndex + 1} of ${questions.length}',
                    style: TextStyle(
                      color: palette.textLight,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Score: $score',
                    style: TextStyle(
                      color: palette.primary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / questions.length,
                  backgroundColor: palette.textLight.withOpacity(0.15),
                  color: palette.primary,
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 20),

              // Question card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      q.question,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textDark,
                        fontSize: _questionFontSize(q.question),
                        fontWeight: FontWeight.w900,
                        height: 1.3,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Choices
              Expanded(
                child: ListView.builder(
                  itemCount: q.choices.length,
                  itemBuilder: (_, i) {
                    final choice = q.choices[i];
                    final isSelected = selectedAnswer == choice;
                    final isAnswer = choice == q.correctAnswer;
                    final answered = isCorrect != null;

                    Color bgColor = Colors.white;
                    Color borderColor = palette.border;
                    Color textColor = palette.textDark;

                    if (answered) {
                      if (isAnswer) {
                        bgColor = Colors.green.shade50;
                        borderColor = Colors.green;
                        textColor = Colors.green.shade800;
                      } else if (isSelected && !isAnswer) {
                        bgColor = Colors.red.shade50;
                        borderColor = Colors.red;
                        textColor = Colors.red.shade800;
                      }
                    } else if (isSelected) {
                      bgColor = palette.primary.withOpacity(0.12);
                      borderColor = palette.primary;
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: answered ? null : () => _selectAnswer(choice),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 16,
                          ),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor, width: 1.5),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  choice,
                                  style: TextStyle(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                              if (answered && isAnswer)
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.green,
                                ),
                              if (answered && isSelected && !isAnswer)
                                const Icon(
                                  Icons.cancel_rounded,
                                  color: Colors.red,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Explanation / next
              if (isCorrect != null) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(14),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    color: isCorrect!
                        ? Colors.green.shade50
                        : Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isCorrect! ? Colors.green : Colors.orange,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isCorrect!
                            ? Icons.check_circle_rounded
                            : Icons.info_rounded,
                        color: isCorrect! ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isCorrect!
                              ? 'Correct!'
                              : 'Answer: ${q.correctAnswer}',
                          style: TextStyle(
                            color: isCorrect!
                                ? Colors.green.shade800
                                : Colors.orange.shade800,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _next,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: Text(
                    currentIndex == questions.length - 1
                        ? 'See Results'
                        : 'Next Question',
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  double _questionFontSize(String text) {
    if (text.length < 60) return 22;
    if (text.length < 120) return 19;
    return 16;
  }
}

class _QuizItem {
  final String question;
  final String correctAnswer;
  final List<String> choices;

  _QuizItem({
    required this.question,
    required this.correctAnswer,
    required this.choices,
  });
}

class _ResultScreen extends StatelessWidget {
  final int score;
  final int total;
  final dynamic palette;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const _ResultScreen({
    required this.score,
    required this.total,
    required this.palette,
    required this.onRestart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final percent = ((score / total) * 100).round();
    final emoji = percent >= 80
        ? '🎉'
        : percent >= 60
            ? '👍'
            : '📚';

    return Scaffold(
      body: Container(
        color: palette.background,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 72)),
                const SizedBox(height: 20),
                Text(
                  '$score / $total',
                  style: TextStyle(
                    color: palette.textLight,
                    fontSize: 48,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$percent% Score',
                  style: TextStyle(
                    color: palette.primary,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  percent >= 80
                      ? 'Excellent work!'
                      : percent >= 60
                          ? 'Good job! Keep studying!'
                          : 'Keep practicing, you\'ll get there!',
                  style: TextStyle(
                    color: palette.textLight.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 40),
                ElevatedButton.icon(
                  onPressed: onRestart,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onExit,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 54),
                    foregroundColor: palette.textLight,
                    side: BorderSide(
                      color: palette.textLight.withOpacity(0.3),
                    ),
                  ),
                  child: const Text('Back to Flashcards'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
