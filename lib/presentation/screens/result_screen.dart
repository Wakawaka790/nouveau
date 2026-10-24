import 'package:flutter/material.dart';

import '../../application/finish_quiz_session.dart';
import '../../domain/entities/question.dart';
import '../../domain/entities/quiz_theme.dart';
import '../../domain/rules/unlock_policy.dart';
import '../app_strings.dart';
import '../widgets/answer_review_list.dart';
import '../widgets/cycling_background.dart';

/// Écran 4 — résultat de la session (REQ-064).
class ResultScreen extends StatelessWidget {
  const ResultScreen({
    required this.theme,
    required this.level,
    required this.questions,
    required this.answers,
    required this.result,
    super.key,
  });

  final QuizTheme theme;
  final int level;
  final List<Question> questions;
  final List<String?> answers;
  final FinishResult result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.resultTitle)),
      body: AppBackground(
        child: Column(
          children: <Widget>[
            _ScoreHeader(
              theme: theme,
              level: level,
              result: result,
            ),
            Expanded(
              child: AnswerReviewList(questions: questions, answers: answers),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
              child: FilledButton.icon(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.map_outlined),
                label: const Text(AppStrings.backToLevels),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// En-tête : score, sous-titre, bannière de déverrouillage, avertissement de
/// persistance (REQ-064, REQ-021). Extrait de `ResultScreen` pour respecter
/// RC-04 (fonctions courtes) sans changer le rendu.
class _ScoreHeader extends StatelessWidget {
  const _ScoreHeader({
    required this.theme,
    required this.level,
    required this.result,
  });

  final QuizTheme theme;
  final int level;
  final FinishResult result;

  @override
  Widget build(BuildContext context) {
    final unlock = result.unlock;
    final isPerfect = result.total > 0 && result.score == result.total;
    return Padding(
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
            AppStrings.resultScore
                .replaceFirst('%d', '${result.score}')
                .replaceFirst('%d', '${result.total}'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            AppStrings.resultSubtitle
                .replaceFirst('%s', theme.label)
                .replaceFirst('%d', '$level'),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          if (unlock is NewlyUnlocked) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              AppStrings.levelUnlockedBanner
                  .replaceFirst('%d', '${unlock.level.value}'),
              style: const TextStyle(
                color: Colors.lightGreenAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
          if (!result.persisted) ...<Widget>[
            const SizedBox(height: 8),
            const Text(
              AppStrings.persistenceWarning,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.orangeAccent),
            ),
          ],
        ],
      ),
    );
  }
}
