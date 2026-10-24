import 'package:flutter/material.dart';

import '../../application/ports/clock.dart';
import '../../domain/session/quiz_session.dart';
import '../app_strings.dart';
import 'option_button.dart';

/// Plateau de jeu : énoncé, options, progression et chronomètre (REQ-063).
///
/// Widget sans état et sans règle : il lit la session du domaine et notifie les
/// réponses. Le temps restant provient toujours de l'échéance absolue.
class QuizBoard extends StatelessWidget {
  const QuizBoard({
    required this.session,
    required this.clock,
    required this.onAnswer,
    super.key,
  });

  final QuizSession session;
  final Clock clock;
  final void Function(String option) onAnswer;

  @override
  Widget build(BuildContext context) {
    final question = session.currentQuestion;
    final remaining = session.remainingMs(clock.nowMs());
    final seconds = (remaining / 1000).ceil();
    final isUrgent = seconds <= 3;
    final timeRatio = session.perQuestionMs <= 0
        ? 0.0
        : (remaining / session.perQuestionMs).clamp(0.0, 1.0);
    return Column(
      children: <Widget>[
        _StatusBar(
          session: session,
          seconds: seconds,
          isUrgent: isUrgent,
          timeRatio: timeRatio,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      question.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final option in question.options)
                  OptionButton(label: option, onPressed: () => onAnswer(option)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.session,
    required this.seconds,
    required this.isUrgent,
    required this.timeRatio,
  });

  final QuizSession session;
  final int seconds;
  final bool isUrgent;
  final double timeRatio;

  @override
  Widget build(BuildContext context) {
    final questionProgress = (session.index + 1) / session.questions.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
      child: Column(
        children: <Widget>[
          Text(
            AppStrings.questionCounter
                .replaceFirst('%d', '${session.index + 1}')
                .replaceFirst('%d', '${session.questions.length}'),
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          Semantics(
            label: AppStrings.progressSemantics,
            child: LinearProgressIndicator(value: questionProgress),
          ),
          const SizedBox(height: 14),
          Row(
            children: <Widget>[
              const Icon(Icons.emoji_events_outlined, color: Colors.amber),
              const SizedBox(width: 6),
              Semantics(
                label: AppStrings.scoreSemantics,
                child: Text(
                  AppStrings.scoreLabel
                      .replaceFirst('%d', '${session.scoreSoFar}'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const Spacer(),
              Text(
                AppStrings.secondsShort.replaceFirst('%d', '$seconds'),
                style: TextStyle(
                  color: isUrgent ? Colors.redAccent : Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Semantics(
            label: AppStrings.remainingTimeSemantics,
            child: LinearProgressIndicator(
              value: timeRatio,
              color: isUrgent ? Colors.redAccent : Colors.lightGreenAccent,
              backgroundColor: Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}
