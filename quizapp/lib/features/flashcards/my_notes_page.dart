import 'package:flutter/material.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/widgets/app_shell.dart';
import '../../models/study_folder.dart';
import '../../services/study_folder_service.dart';
import '../../services/study_set_service.dart';
import 'folder_sets_page.dart';

class MyNotesPage extends StatefulWidget {
  final ThemeController themeController;

  const MyNotesPage({super.key, required this.themeController});

  @override
  State<MyNotesPage> createState() => _MyNotesPageState();
}

class _MyNotesPageState extends State<MyNotesPage> {
  List<StudyFolder> folders = [];
  Map<String, int> folderCardCounts = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final allFolders = await StudyFolderService.getAll();
    final allSets = await StudySetService.getAll();

    final counts = <String, int>{};
    for (final folder in allFolders) {
      final setCount = allSets.where((s) => s.folderId == folder.id).length;
      final cardCount = allSets
          .where((s) => s.folderId == folder.id)
          .fold<int>(0, (sum, s) => sum + s.flashcards.length);
      counts[folder.id] = cardCount;
    }

    if (!mounted) return;
    setState(() {
      folders = allFolders;
      folderCardCounts = counts;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;

    return Scaffold(
      appBar: AppBar(title: const Text('Review My Notes')),
      body: AppShell(
        themeController: widget.themeController,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : folders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.folder_open_rounded,
                            size: 64,
                            color: palette.textLight.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No folders yet.',
                            style: TextStyle(
                              color: palette.textLight,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Create flashcards first using\nQuick Actions → Create Flashcards.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: palette.textLight.withOpacity(0.5),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${folders.length} folder${folders.length == 1 ? '' : 's'}',
                          style: TextStyle(
                            color: palette.textLight.withOpacity(0.7),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Expanded(
                          child: ListView.builder(
                            itemCount: folders.length,
                            itemBuilder: (_, i) {
                              final folder = folders[i];
                              final cardCount =
                                  folderCardCounts[folder.id] ?? 0;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: Card(
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(28),
                                    onTap: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => FolderSetsPage(
                                            themeController:
                                                widget.themeController,
                                            folder: folder,
                                          ),
                                        ),
                                      );
                                      _load();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(18),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 52,
                                            height: 52,
                                            decoration: BoxDecoration(
                                              color: palette.secondary
                                                  .withOpacity(0.12),
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                            ),
                                            child: Icon(
                                              Icons.folder_rounded,
                                              color: palette.secondary,
                                              size: 28,
                                            ),
                                          ),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  folder.name,
                                                  style: TextStyle(
                                                    color: palette.textDark,
                                                    fontSize: 17,
                                                    fontWeight: FontWeight.w800,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  '$cardCount card${cardCount == 1 ? '' : 's'}',
                                                  style: TextStyle(
                                                    color: palette.muted,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right_rounded,
                                            color: palette.muted,
                                          ),
                                        ],
                                      ),
                                    ),
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
