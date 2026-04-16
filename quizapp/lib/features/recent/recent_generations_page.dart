import 'package:flutter/material.dart';

import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';
import '../../models/generation_record.dart';
import '../../services/local_storage_service.dart';
import '../quiz_preview/quiz_preview_page.dart';

class RecentGenerationsPage extends StatefulWidget {
  final ThemeController themeController;

  const RecentGenerationsPage({
    super.key,
    required this.themeController,
  });

  @override
  State<RecentGenerationsPage> createState() => _RecentGenerationsPageState();
}

class _RecentGenerationsPageState extends State<RecentGenerationsPage> {
  List<GenerationRecord> records = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRecords();
  }

  Future<void> loadRecords() async {
    final data = await LocalStorageService.getRecentGenerations();
    if (!mounted) return;
    setState(() {
      records = data;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Recent Generations')),
      body: AppShell(
        themeController: widget.themeController,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : records.isEmpty
                  ? Center(
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.history_rounded,
                                size: 56,
                                color: palette.secondary,
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'No recent generations yet',
                                style: TextStyle(
                                  color: palette.textDark,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Generate your first reviewer to see it here.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: palette.muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: records.length,
                      itemBuilder: (context, index) {
                        final item = records[index];

                        return TweenAnimationBuilder<double>(
                          duration: Duration(milliseconds: 250 + (index * 70)),
                          tween: Tween(begin: 0, end: 1),
                          builder: (context, value, child) {
                            return Opacity(
                              opacity: value,
                              child: Transform.translate(
                                offset: Offset(0, 20 * (1 - value)),
                                child: child,
                              ),
                            );
                          },
                          child: Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              leading: CircleAvatar(
                                child: Text('${index + 1}'),
                              ),
                              title: Text(
                                item.fileName,
                                style: TextStyle(
                                  color: palette.textDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              subtitle: Text(
                                '${item.quiz.title}\n${item.createdAt.toLocal()}',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: const Icon(Icons.chevron_right_rounded),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => QuizPreviewPage(
                                      quiz: item.quiz,
                                      themeController: widget.themeController,
                                      generationId: item.id,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
        ),
      ),
    );
  }
}