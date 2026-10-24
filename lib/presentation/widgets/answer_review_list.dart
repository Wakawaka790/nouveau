import 'package:flutter/material.dart';

import '../../domain/entities/question.dart';
import '../app_strings.dart';

/// Composants de relecture de la session : une ligne par question, avec la
/// réponse donnée et, en cas d'erreur, la bonne réponse (REQ-064).
class AnswerReviewList extends StatelessWidget {
  const AnswerReviewList({
    required this.questions,
    required this.answers,
    super.key,
  });

  final List<Question> questions;
  final List<String?> answers;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      itemCount: questions.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) => AnswerReviewTile(
        question: questions[index],
        answer: index < answers.length ? answers[index] : null,
      ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const AnswerReviewTile({required this.question, required this.answer});

  final Question question;
  final String? answer;

  @override
  Widget build(BuildContext context) {
    final isCorrect = question.isCorrect(answer);
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
                    question.text,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    AppStrings.yourAnswer
                        .replaceFirst('%s', answer ?? AppStrings.noAnswer),
                  ),
                  if (!isCorrect)
                    Text(
                      AppStrings.correctAnswer
                          .replaceFirst('%s', question.correctAnswer),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
