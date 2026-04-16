import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../../core/widgets/app_shell.dart';
import '../../core/theme/theme_controller.dart';
import '../../models/quiz.dart';
import '../../services/api_service.dart';
import '../processing/processing_page.dart';
import '../quiz_preview/quiz_preview_page.dart';
import '../../services/local_storage_service.dart';

class UploadPage extends StatefulWidget {
  final ThemeController themeController;

  const UploadPage({super.key, required this.themeController});

  @override
  State<UploadPage> createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage> {
  File? selectedFile;
  bool isLoading = false;
  String? errorMessage;

  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx', 'pptx'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        errorMessage = null;
      });
    }
  }
  

  Future<void> generateQuiz() async {
    if (selectedFile == null) {
      setState(() {
        errorMessage = 'Please select a file first.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProcessingPage(themeController: widget.themeController),
      ),
    );

    try {
      final Quiz quiz = await ApiService.generateQuiz(selectedFile!);

      final fileName = selectedFile!.path.split(Platform.pathSeparator).last;
      await LocalStorageService.saveGeneration(
        fileName: fileName,
        quiz: quiz,
      );

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => QuizPreviewPage(
            quiz: quiz,
            themeController: widget.themeController,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);

      setState(() {
        errorMessage = e.toString();
      });
    } finally {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = widget.themeController.palette;
    final fileName = selectedFile != null
        ? selectedFile!.path.split(Platform.pathSeparator).last
        : 'No file selected';

    return Scaffold(
      appBar: AppBar(title: const Text('Upload Lesson')),
      body: AppShell(
        themeController: widget.themeController,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 430),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(height: 8),
                      Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: palette.primary.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(70),
                        ),
                        child: Icon(
                          Icons.cloud_upload_rounded,
                          size: 56,
                          color: palette.primary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Upload your lesson file',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Supported formats: PDF, Word, and PowerPoint.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: palette.muted,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 22),
                      OutlinedButton.icon(
                        onPressed: isLoading ? null : pickFile,
                        icon: const Icon(Icons.attach_file_rounded),
                        label: const Text('Choose File'),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F8FC),
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: palette.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                Icons.description_rounded,
                                color: palette.primary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                fileName,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: palette.textDark,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 22),
                      ElevatedButton.icon(
                        onPressed: isLoading ? null : generateQuiz,
                        icon: const Icon(Icons.auto_awesome_rounded),
                        label: const Text('Generate Quiz'),
                      ),
                      const SizedBox(height: 10),
                      if (errorMessage != null)
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}