import 'package:flutter/material.dart';

import '../../domain/entities/quiz_theme.dart';
import '../app_dependencies.dart';
import '../app_strings.dart';
import '../widgets/cycling_background.dart';
import 'level_map_screen.dart';
import 'scores_screen.dart';

/// Écran 1 — choix du thème (REQ-061).
class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({required this.deps, super.key});

  static const Map<String, IconData> _icons = <String, IconData>{
    'arabe': Icons.translate,
    'sira': Icons.book_outlined,
    'coran': Icons.menu_book,
    'histoire': Icons.account_balance,
    'sahaba': Icons.people_alt,
    'hijra': Icons.route,
    'terme': Icons.lightbulb_outline,
    'general': Icons.quiz,
  };

  final AppDependencies deps;

  void _openScores(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => ScoresScreen(deps: deps)),
    );
  }

  void _openTheme(BuildContext context, QuizTheme theme) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LevelMapScreen(deps: deps, theme: theme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.appTitle),
          actions: <Widget>[
            IconButton(
              tooltip: AppStrings.scoresTooltip,
              onPressed: () => _openScores(context),
              icon: const Icon(Icons.emoji_events_outlined),
            ),
          ],
        ),
        body: AppBackground(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 4 : 2;
              return Column(
                children: <Widget>[
                  const _Header(),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: quizThemes.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: columns == 2 ? 0.9 : 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final theme = quizThemes[index];
                        return _ThemeCard(
                          theme: theme,
                          icon: _icons[theme.id.value] ?? Icons.quiz,
                          onTap: () => _openTheme(context, theme),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      );
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
        child: Column(
          children: <Widget>[
            Text(
              AppStrings.themeSelectionTitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              AppStrings.themeSelectionSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        ),
      );
}

class _ThemeCard extends StatelessWidget {
  const _ThemeCard({
    required this.theme,
    required this.icon,
    required this.onTap,
  });

  final QuizTheme theme;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        color: Colors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(icon, size: 42, color: const Color(0xFF493A8C)),
                const SizedBox(height: 8),
                Text(
                  theme.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  theme.description,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );
}
