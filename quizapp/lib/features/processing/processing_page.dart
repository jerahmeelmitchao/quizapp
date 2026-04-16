import 'package:flutter/material.dart';
import '../../core/widgets/app_shell.dart';
import '../../core/theme/theme_controller.dart';

class ProcessingPage extends StatefulWidget {
  final ThemeController themeController;

  const ProcessingPage({super.key, required this.themeController});

  @override
  State<ProcessingPage> createState() => _ProcessingPageState();
}

class _ProcessingPageState extends State<ProcessingPage> {
  final List<String> steps = const [
    'Uploading lesson',
    'Reading document',
    'Analyzing content',
    'Generating reviewer',
    'Creating questions',
  ];

  int currentStep = 0;

  @override
  void initState() {
    super.initState();
    _animateSteps();
  }

  Future<void> _animateSteps() async {
    for (int i = 0; i < steps.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 750));
      if (!mounted) return;
      setState(() {
        currentStep = i + 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;

    return Scaffold(
      body: AppShell(
        themeController: widget.themeController,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 70,
                      color: palette.secondary,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Generating your reviewer',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.textDark,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Please wait while your lesson is being processed.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: palette.muted,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 22),
                    CircularProgressIndicator(color: palette.secondary),
                    const SizedBox(height: 24),
                    ...List.generate(steps.length, (index) {
                      final active = index == currentStep;
                      final done = index < currentStep;

                      return ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          done
                              ? Icons.check_circle
                              : active
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_off,
                          color: done || active ? palette.secondary : palette.muted,
                        ),
                        title: Text(
                          steps[index],
                          style: TextStyle(
                            color: palette.textDark,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}