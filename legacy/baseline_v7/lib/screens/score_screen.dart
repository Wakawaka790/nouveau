import 'package:flutter/material.dart';
import 'package:quiz_game7/models/question.dart';
import 'package:quiz_game7/models/quiz_category.dart';
import 'package:quiz_game7/services/quiz_scoring.dart';
import 'package:quiz_game7/widgets/animated_background.dart';

class ScoreScreen extends StatelessWidget {
  const ScoreScreen({
    super.key,
    required this.quizType,
    required this.niveau,
    required this.questions,
    required this.answers,
    this.unlockedNextLevel,
    this.persistenceError,
  });

  final String quizType;
  final int niveau;
  final List<Question> questions;
  final List<String?> answers;
  final int? unlockedNextLevel;
  final String? persistenceError;

  @override
  Widget build(BuildContext context) {
    final score = calculateQuizScore(questions, answers);
    final category = quizCategoryForId(quizType)?.label ?? quizType;
    final isPerfect = score == questions.length && questions.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Résultat du quiz')),
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: Column(
                  children: <Widget>[
                    Icon(
                      isPerfect ? Icons.celebration : Icons.emoji_events,
                      color: Colors.amber,
                      size: 54,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$score / ${questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$category — niveau $niveau',
                      style: const TextStyle(color: Colors.white70, fontSize: 16),
                    ),
                    if (unlockedNextLevel != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        'Niveau $unlockedNextLevel débloqué !',
                        style: const TextStyle(
                          color: Colors.lightGreenAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                    if (persistenceError != null) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        persistenceError!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.orangeAccent),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  itemCount: questions.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final question = questions[index];
                    final answer = index < answers.length ? answers[index] : null;
                    final displayAnswer = answer ?? 'Aucune réponse';
                    final isCorrect = answer == question.correctAnswer;
                    return Card( 
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              isCorrect ? Icons.check_circle : Icons.cancel,
                              color: isCorrect ? Colors.green : Colors.redAccent,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    question.question,
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('Votre réponse : $displayAnswer'),
                                  if (!isCorrect)
                                    Text('Bonne réponse : ${question.correctAnswer}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
                child: FilledButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.map_outlined),
                  label: const Text('Retour aux niveaux'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 
