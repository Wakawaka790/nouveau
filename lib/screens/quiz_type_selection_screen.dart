import 'package:flutter/material.dart';
import 'package:quiz_game7/models/quiz_category.dart';
import 'package:quiz_game7/screens/level_map_screen.dart';
import 'package:quiz_game7/screens/scores_screen.dart';
import 'package:quiz_game7/widgets/animated_background.dart';

class QuizTypeSelectionScreen extends StatelessWidget {
  const QuizTypeSelectionScreen({super.key});

  void _openScores(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const ScoresScreen()),
    );
  }

  void _openCategory(BuildContext context, QuizCategory category) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => LevelMapScreen(quizType: category.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz éducatif'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Voir les scores',
            onPressed: () => _openScores(context),
            icon: const Icon(Icons.emoji_events_outlined),
          ),
        ],
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 700 ? 4 : 2;
              return Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                    child: Text(
                      'Choisissez un thème',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Text(
                      'Apprenez en jouant, à votre rythme.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                  ),
                  Expanded(
                    child: GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: quizCategories.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: columns == 2 ? 0.9 : 0.95,
                      ),
                      itemBuilder: (context, index) {
                        final category = quizCategories[index];
                        return Card(
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              // Fond : l'image du thème (assets/images/).
                              Image.asset(
                                category.imagePath,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    const ColoredBox(
                                  color: Color(0xFF493A8C),
                                ),
                              ),
                              // Voile dégradé pour garder le texte lisible.
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: <Color>[
                                      Color(0x1A000000),
                                      Color(0xCC0B1020),
                                    ],
                                  ),
                                ),
                              ),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _openCategory(context, category),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: <Widget>[
                                        Icon(category.icon,
                                            size: 36, color: Colors.white),
                                        const SizedBox(height: 6),
                                        Text(
                                          category.label,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          category.description,
                                          textAlign: TextAlign.center,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
