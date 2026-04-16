import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';
import '../../models/study_set.dart';
import 'flashcard_quiz_page.dart';

class FlashcardReviewPage extends StatefulWidget {
  final ThemeController themeController;
  final StudySet studySet;

  const FlashcardReviewPage({
    super.key,
    required this.themeController,
    required this.studySet,
  });

  @override
  State<FlashcardReviewPage> createState() => _FlashcardReviewPageState();
}

class _FlashcardReviewPageState extends State<FlashcardReviewPage> {
  int currentIndex = 0;
  bool isFlipped = false;

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;
    final cards = widget.studySet.flashcards;

    if (cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.studySet.title)),
        body: AppShell(
          themeController: widget.themeController,
          child: Center(
            child: Text(
              'No flashcards in this set.',
              style: TextStyle(color: palette.textLight),
            ),
          ),
        ),
      );
    }

    final card = cards[currentIndex];

    return Scaffold(
      appBar: AppBar(title: Text(widget.studySet.title)),
      body: AppShell(
        themeController: widget.themeController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Progress indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${currentIndex + 1} / ${cards.length}',
                    style: TextStyle(
                      color: palette.textLight,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: (currentIndex + 1) / cards.length,
                  backgroundColor: palette.textLight.withOpacity(0.15),
                  color: palette.primary,
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 24),

              // Flip card
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => isFlipped = !isFlipped),
                  child: _FlipCard(
                    front: card.front,
                    back: card.back,
                    isFlipped: isFlipped,
                    palette: palette,
                  ),
                ),
              ),

              const SizedBox(height: 10),
              Text(
                'Tap card to flip',
                style: TextStyle(
                  color: palette.textLight.withOpacity(0.5),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              // Navigation
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: currentIndex == 0
                          ? null
                          : () => setState(() {
                                currentIndex--;
                                isFlipped = false;
                              }),
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('Prev'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: currentIndex == cards.length - 1
                        ? OutlinedButton.icon(
                            onPressed: () => setState(() {
                              currentIndex = 0;
                              isFlipped = false;
                            }),
                            icon: const Icon(Icons.refresh_rounded),
                            label: const Text('Restart'),
                          )
                        : ElevatedButton.icon(
                            onPressed: () => setState(() {
                              currentIndex++;
                              isFlipped = false;
                            }),
                            icon: const Icon(Icons.arrow_forward_rounded),
                            label: const Text('Next'),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Start Quiz button
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FlashcardQuizPage(
                        themeController: widget.themeController,
                        studySet: widget.studySet,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                ),
                icon: const Icon(Icons.quiz_rounded),
                label: const Text('Start Quiz'),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

class _FlipCard extends StatefulWidget {
  final String front;
  final String back;
  final bool isFlipped;
  final dynamic palette;

  const _FlipCard({
    required this.front,
    required this.back,
    required this.isFlipped,
    required this.palette,
  });

  @override
  State<_FlipCard> createState() => _FlipCardState();
}

class _FlipCardState extends State<_FlipCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _anim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void didUpdateWidget(_FlipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipped != oldWidget.isFlipped) {
      if (widget.isFlipped) {
        _ctrl.forward();
      } else {
        _ctrl.reverse();
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.palette;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) {
        final angle = _anim.value * math.pi;
        final isBack = _anim.value > 0.5;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: isBack
              ? Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.rotationY(math.pi),
                  child: _CardFace(
                    text: widget.back,
                    label: 'ANSWER',
                    icon: Icons.lightbulb_rounded,
                    bgColor: Color.lerp(Colors.white, palette.secondary, 0.08)!,
                    accentColor: palette.secondary,
                    palette: palette,
                  ),
                )
              : _CardFace(
                  text: widget.front,
                  label: 'QUESTION',
                  icon: Icons.help_outline_rounded,
                  bgColor: Colors.white,
                  accentColor: palette.primary,
                  palette: palette,
                ),
        );
      },
    );
  }
}

class _CardFace extends StatelessWidget {
  final String text;
  final String label;
  final IconData icon;
  final Color bgColor;
  final Color accentColor;
  final dynamic palette;

  const _CardFace({
    required this.text,
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.accentColor,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: accentColor.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: accentColor, size: 38),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w800,
              fontSize: 13,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.textDark,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
