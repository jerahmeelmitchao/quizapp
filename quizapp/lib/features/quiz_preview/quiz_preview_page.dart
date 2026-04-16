import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/theme/theme_controller.dart';
import '../../models/quiz.dart';
import '../quiz_player/quiz_player_page.dart';
import 'package:auto_size_text/auto_size_text.dart';

class QuizPreviewPage extends StatelessWidget {
  final Quiz quiz;
  final ThemeController themeController;
  final int initialTabIndex;
  final String? generationId;

  const QuizPreviewPage({
    super.key,
    required this.quiz,
    required this.themeController,
    this.generationId,
    this.initialTabIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return DefaultTabController(
      length: 3,
      initialIndex: initialTabIndex,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Generated Reviewer'),
          bottom: TabBar(
            indicatorColor: palette.primary,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            tabs: const [
              Tab(icon: Icon(Icons.menu_book_rounded), text: 'Reviewer'),
              Tab(icon: Icon(Icons.quiz_rounded), text: 'Quiz'),
              Tab(icon: Icon(Icons.style_rounded), text: 'Cards'),
            ],
          ),
        ),
        body: AppShell(
          themeController: themeController,
          child: TabBarView(
            children: [
              _ReviewerTab(quiz: quiz, themeController: themeController),
              _QuizTab(
                quiz: quiz,
                themeController: themeController,
                generationId: generationId,
              ),
              _FlashcardsTab(quiz: quiz, themeController: themeController),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewerTab extends StatelessWidget {
  final Quiz quiz;
  final ThemeController themeController;

  const _ReviewerTab({required this.quiz, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  quiz.title,
                  style: TextStyle(
                    color: palette.textDark,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  quiz.summary,
                  style: TextStyle(color: palette.muted, fontSize: 15),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Key Points',
                  style: TextStyle(
                    color: palette.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ...quiz.keyPoints.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '• $e',
                      style: TextStyle(color: palette.textDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reviewer Notes',
                  style: TextStyle(
                    color: palette.textDark,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 10),
                ...quiz.reviewerNotes.map(
                  (e) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '• $e',
                      style: TextStyle(color: palette.textDark),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _QuizTab extends StatelessWidget {
  final Quiz quiz;
  final ThemeController themeController;
  final String? generationId;

  const _QuizTab({
    required this.quiz,
    required this.themeController,
    this.generationId,
  });

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(18),
            itemCount: quiz.questions.length,
            itemBuilder: (context, index) {
              final q = quiz.questions[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: palette.secondary.withOpacity(0.15),
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    q.question,
                    style: TextStyle(
                      color: palette.textDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    '${q.type} • ${q.difficulty}',
                    style: TextStyle(color: palette.muted),
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuizPlayerPage(
                    quiz: quiz,
                    themeController: themeController,
                    generationId: generationId,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.play_arrow_rounded),
            label: const Text('Start Quiz'),
          ),
        ),
      ],
    );
  }
}

class _FlashcardsTab extends StatelessWidget {
  final Quiz quiz;
  final ThemeController themeController;

  const _FlashcardsTab({required this.quiz, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final cards = <Map<String, String>>[];

    for (int i = 0; i < quiz.keyPoints.length; i++) {
      cards.add({
        'front': quiz.keyPoints[i],
        'back': i < quiz.reviewerNotes.length
            ? quiz.reviewerNotes[i]
            : quiz.summary,
      });
    }

    if (cards.isEmpty) {
      cards.add({
        'front': 'No flashcards yet',
        'back': 'Generate a reviewer first.',
      });
    }

    return ListView.builder(
      padding: const EdgeInsets.all(18),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return _FlashCard(
          front: cards[index]['front'] ?? '',
          back: cards[index]['back'] ?? '',
          themeController: themeController,
        );
      },
    );
  }
}

class _FlashCard extends StatefulWidget {
  final String front;
  final String back;
  final ThemeController themeController;

  const _FlashCard({
    required this.front,
    required this.back,
    required this.themeController,
  });

  @override
  State<_FlashCard> createState() => _FlashCardState();
}

class _FlashCardState extends State<_FlashCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  bool get isFront => _controller.value < 0.5;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_controller.isAnimating) return;

    if (isFront) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;

    return GestureDetector(
      onTap: _flipCard,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final angle = _controller.value * 3.1415926535;
          final lift = (1 - ((_controller.value - 0.5).abs() * 2)) * 8;

          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: palette.secondary.withOpacity(0.18),
                  blurRadius: 22,
                  offset: Offset(0, 8 + lift),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 210,
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Opacity(
                      opacity: _controller.value < 0.5 ? 1 : 0,
                      child: _FlashCardFace(
                        palette: palette,
                        isFront: true,
                        icon: Icons.style_rounded,
                        label: 'Front',
                        text: widget.front,
                      ),
                    ),
                    Opacity(
                      opacity: _controller.value >= 0.5 ? 1 : 0,
                      child: Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(3.1415926535),
                        child: _FlashCardFace(
                          palette: palette,
                          isFront: false,
                          icon: Icons.flip_rounded,
                          label: 'Back',
                          text: widget.back,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _FlashCardFace extends StatelessWidget {
  final dynamic palette;
  final bool isFront;
  final IconData icon;
  final String label;
  final String text;

  const _FlashCardFace({
    required this.palette,
    required this.isFront,
    required this.icon,
    required this.label,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    final Color background = isFront
        ? Color.lerp(Colors.white, palette.backgroundAccent, 0.08) ??
              Colors.white
        : Color.lerp(Colors.white, palette.secondary, 0.10) ?? Colors.white;

    final Color topGlow = isFront
        ? palette.primary.withOpacity(0.12)
        : palette.secondary.withOpacity(0.16);

    final Color borderColor = isFront
        ? palette.primary.withOpacity(0.16)
        : palette.secondary.withOpacity(0.22);

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [background, Colors.white],
        ),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            right: 4,
            child: Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(color: topGlow, shape: BoxShape.circle),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: palette.secondary, size: 34),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: TextStyle(
                    color: palette.muted,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Center(
                    child: AutoSizeText(
                      text,
                      textAlign: TextAlign.center,
                      maxLines: 6,
                      minFontSize: 12,
                      stepGranularity: 0.5,
                      style: TextStyle(
                        color: palette.textDark,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        height: 1.35,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
