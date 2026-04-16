import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/widgets/app_shell.dart';
import '../../core/theme/theme_controller.dart';
import '../upload/upload_page.dart';
import '../recent/recent_generations_page.dart';
import '../flashcards/folder_picker_page.dart';
import '../flashcards/my_notes_page.dart';

class HomePage extends StatelessWidget {
  final ThemeController themeController;

  const HomePage({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return Scaffold(
      body: AppShell(
        themeController: themeController,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'QuizGen',
                      style: TextStyle(
                        color: palette.textLight,
                        fontSize: 38,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    IconButton(
                      tooltip: "About App",
                      icon: Icon(
                        Icons.info_outline,
                        color: palette.textLight,
                        size: 24,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                AboutPage(themeController: themeController),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Cute, simple reviewer and quiz generator for your lessons.',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 26),
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 350),
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
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(height: 12),
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: palette.secondary.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(70),
                                ),
                                child: Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 60,
                                  color: palette.secondary,
                                ),
                              ),
                              const SizedBox(height: 22),
                              Text(
                                'Turn your lesson into a smart reviewer',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: palette.textDark,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Upload a PDF, DOCX, or PPTX and generate summary, quiz, and flashcards.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: palette.muted,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 24),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => UploadPage(
                                        themeController: themeController,
                                      ),
                                    ),
                                  );
                                },
                                child: const Text('Start Generating'),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 26),
                Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: palette.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 14),
                GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    _ActionCard(
                      icon: Icons.upload_file_rounded,
                      title: 'Upload',
                      subtitle: 'Generate from lesson files',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                UploadPage(themeController: themeController),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.history_rounded,
                      title: 'Recent',
                      subtitle: 'View past generations',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RecentGenerationsPage(
                              themeController: themeController,
                            ),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.style_rounded,
                      title: 'Create Flashcards',
                      subtitle: 'Make your own study set',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FolderPickerPage(
                              themeController: themeController,
                              mode: FolderPickerMode.createFlashcards,
                            ),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      icon: Icons.menu_book_rounded,
                      title: 'Review My Notes',
                      subtitle: 'Study your flashcard sets',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MyNotesPage(themeController: themeController),
                          ),
                        );
                      },
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

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 320),
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.96 + (value * 0.04), child: child),
        );
      },
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(radius: 22, child: Icon(icon)),
                const SizedBox(height: 14),
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AboutPage extends StatelessWidget {
  final ThemeController themeController;

  const AboutPage({super.key, required this.themeController});

  Future<void> _showLaunchError(
    BuildContext context,
    String value,
    String label,
  ) async {
    await Clipboard.setData(ClipboardData(text: value));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Could not open $label. Copied to clipboard instead.'),
      ),
    );
  }

  Future<void> _openWebsite(BuildContext context, String url) async {
    final uri = Uri.parse(url);

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        await _showLaunchError(context, url, 'website');
      }
    } catch (_) {
      await _showLaunchError(context, url, 'website');
    }
  }

  Future<void> _openEmail(BuildContext context, String email) async {
    final emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {
        'subject': 'Hello from QuizGen',
      },
    );

    try {
      final opened = await launchUrl(emailUri);

      if (!opened) {
        await _showLaunchError(context, email, 'email');
      }
    } catch (_) {
      await _showLaunchError(context, email, 'email');
    }
  }

  Future<void> _openFacebook(BuildContext context) async {
    const fbAppUrl =
        'fb://facewebmodal/f?href=https://www.facebook.com/jerahmeel.mitchao';
    const fbWebUrl = 'https://www.facebook.com/jerahmeel.mitchao';

    try {
      final appUri = Uri.parse(fbAppUrl);
      final webUri = Uri.parse(fbWebUrl);

      final openedApp = await launchUrl(
        appUri,
        mode: LaunchMode.externalApplication,
      );

      if (openedApp) return;

      final openedWeb = await launchUrl(
        webUri,
        mode: LaunchMode.externalApplication,
      );

      if (!openedWeb) {
        await _showLaunchError(context, fbWebUrl, 'Facebook');
      }
    } catch (_) {
      await _showLaunchError(
        context,
        'https://www.facebook.com/jerahmeel.mitchao',
        'Facebook',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final palette = themeController.palette;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        title: const Text(
          'Settings & About',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 16,
                    color: Color(0x11000000),
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: palette.secondary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      size: 42,
                      color: palette.secondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'QuizGen',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'A simple reviewer and quiz generator app for studying lessons, notes, and flashcards.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Developer',
              children: const [
                _AboutTile(
                  icon: Icons.person_outline,
                  title: 'Developer Name',
                  subtitle: 'JERAHMEEL B. MITCHAO',
                ),
                _AboutTile(
                  icon: Icons.school_outlined,
                  title: 'Role',
                  subtitle: 'BSIT Student / App Developer',
                ),
                _AboutTile(
                  icon: Icons.code_outlined,
                  title: 'Built With',
                  subtitle: 'Flutter',
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'App Information',
              children: const [
                _AboutTile(
                  icon: Icons.info_outline,
                  title: 'App Name',
                  subtitle: 'QuizGen',
                ),
                _AboutTile(
                  icon: Icons.new_releases_outlined,
                  title: 'Version',
                  subtitle: '1.0.0',
                ),
                _AboutTile(
                  icon: Icons.category_outlined,
                  title: 'Category',
                  subtitle: 'Education',
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionCard(
              title: 'Links',
              children: [
                _AboutTile(
                  icon: Icons.email_outlined,
                  title: 'Email',
                  subtitle: 'mitchaojerahmeel100203@gmail.com',
                  trailingIcon: Icons.open_in_new_rounded,
                  onTap: () {
                    _openEmail(
                      context,
                      'mitchaojerahmeel100203@gmail.com',
                    );
                  },
                ),
                _AboutTile(
                  icon: Icons.language_rounded,
                  title: 'Portfolio / Website',
                  subtitle: 'mitchaojerahmeel.netlify.app',
                  trailingIcon: Icons.open_in_new_rounded,
                  onTap: () {
                    _openWebsite(
                      context,
                      'https://mitchaojerahmeel.netlify.app/',
                    );
                  },
                ),
                _AboutTile(
                  icon: Icons.facebook_rounded,
                  title: 'Facebook',
                  subtitle: 'Jerahmeel B. Mitchao',
                  trailingIcon: Icons.open_in_new_rounded,
                  onTap: () {
                    _openFacebook(context);
                  },
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                children: [
                  Text(
                    'Thank you for using QuizGen',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This app was made to help students study smarter using flashcards, notes, and generated quizzes.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            color: Color(0x0D000000),
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const _AboutTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailingIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: Icon(icon, color: Colors.black87),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 14,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 13),
      ),
      trailing: trailingIcon != null
          ? Icon(trailingIcon, size: 18, color: Colors.grey.shade700)
          : null,
      onTap: onTap,
    );
  }
}