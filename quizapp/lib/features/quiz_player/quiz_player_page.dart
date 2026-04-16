import 'package:flutter/material.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/theme/theme_controller.dart';
import '../../models/quiz.dart';
import '../result/result_page.dart';
import '../../models/question.dart';
import '../../services/local_storage_service.dart';

class QuizPlayerPage extends StatefulWidget {
  final Quiz quiz;
  final ThemeController themeController;
  final String? generationId;

  const QuizPlayerPage({
    super.key,
    required this.quiz,
    required this.themeController,
    this.generationId,
  });

  @override
  State<QuizPlayerPage> createState() => _QuizPlayerPageState();
}

class _QuizPlayerPageState extends State<QuizPlayerPage> {
  int currentIndex = 0;
  final Map<int, String> selectedAnswers = {};
  final TextEditingController answerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCurrentAnswer();
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  bool _isChoiceType(String type) {
    return type == 'multiple_choice' || type == 'true_false';
  }

  bool _isOpenEndedType(String type) {
    return type == 'identification' || type == 'short_answer';
  }

  double _questionFontSize(String text) {
    final length = text.length;

    if (length < 60) return 30;
    if (length < 100) return 26;
    if (length < 150) return 22;
    if (length < 220) return 19;
    return 17;
  }

  void _loadCurrentAnswer() {
    final saved = selectedAnswers[currentIndex] ?? '';
    answerController.text = saved;
  }

  bool _canProceed(Question q) {
    if (_isChoiceType(q.type)) {
      return selectedAnswers[currentIndex] != null &&
          selectedAnswers[currentIndex]!.trim().isNotEmpty;
    }

    if (_isOpenEndedType(q.type)) {
      return answerController.text.trim().isNotEmpty;
    }

    return false;
  }

  Future<void> _goNext() async {
    final q = widget.quiz.questions[currentIndex];

    if (_isOpenEndedType(q.type)) {
      selectedAnswers[currentIndex] = answerController.text.trim();
    }

    if (currentIndex < widget.quiz.questions.length - 1) {
      setState(() {
        currentIndex++;
        _loadCurrentAnswer();
      });
    } else {
      int score = 0;

      for (int i = 0; i < widget.quiz.questions.length; i++) {
        final userAnswer = (selectedAnswers[i] ?? '').trim().toLowerCase();
        final correctAnswer =
            widget.quiz.questions[i].answer.trim().toLowerCase();

        if (userAnswer == correctAnswer) {
          score++;
        }
      }

      if (widget.generationId != null) {
        await LocalStorageService.updateGenerationScore(
          id: widget.generationId!,
          score: score,
          totalItems: widget.quiz.questions.length,
        );
      }

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ResultPage(
            score: score,
            total: widget.quiz.questions.length,
            quiz: widget.quiz,
            selectedAnswers: selectedAnswers,
            themeController: widget.themeController,
          ),
        ),
      );
    }
  }

  void _goPrevious() {
    if (currentIndex == 0) return;

    final q = widget.quiz.questions[currentIndex];
    if (_isOpenEndedType(q.type)) {
      selectedAnswers[currentIndex] = answerController.text.trim();
    }

    setState(() {
      currentIndex--;
      _loadCurrentAnswer();
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;
    final q = widget.quiz.questions[currentIndex];
    final isChoiceType = _isChoiceType(q.type);
    final isOpenEndedType = _isOpenEndedType(q.type);

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Time')),
      body: AppShell(
        themeController: widget.themeController,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const SizedBox(height: 6),
                Text(
                  'Question ${currentIndex + 1} of ${widget.quiz.questions.length}',
                  style: const TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              child: Column(
                                children: [
                                  Text(
                                    q.question,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: palette.textDark,
                                      fontSize: _questionFontSize(q.question),
                                      fontWeight: FontWeight.w900,
                                      height: 1.25,
                                    ),
                                  ),
                                  const SizedBox(height: 24),
                                  if (isChoiceType) ...[
                                    ...q.choices.map((choice) {
                                      final selected =
                                          selectedAnswers[currentIndex] == choice;

                                      return Container(
                                        width: double.infinity,
                                        margin:
                                            const EdgeInsets.only(bottom: 14),
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: selected
                                                ? palette.primary
                                                : Colors.white,
                                            foregroundColor: palette.textDark,
                                            side: BorderSide(
                                              color: palette.border,
                                            ),
                                            elevation: 0,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 18,
                                              horizontal: 16,
                                            ),
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              selectedAnswers[currentIndex] =
                                                  choice;
                                            });
                                          },
                                          child: Text(
                                            choice,
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: palette.textDark,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                  ],
                                  if (isOpenEndedType) ...[
                                    TextField(
                                      controller: answerController,
                                      maxLines: 4,
                                      onChanged: (_) => setState(() {}),
                                      decoration: InputDecoration(
                                        hintText: q.type == 'identification'
                                            ? 'Type your answer here'
                                            : 'Write your short answer here',
                                        filled: true,
                                        fillColor: Colors.white,
                                        contentPadding:
                                            const EdgeInsets.all(16),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide(
                                            color: palette.border,
                                          ),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide(
                                            color: palette.border,
                                          ),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(18),
                                          borderSide: BorderSide(
                                            color: palette.secondary,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: currentIndex == 0 ? null : _goPrevious,
                        child: const Text('Previous'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _canProceed(q) ? _goNext : null,
                        child: Text(
                          currentIndex == widget.quiz.questions.length - 1
                              ? 'Submit'
                              : 'Next',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}