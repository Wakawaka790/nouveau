import 'package:flutter/material.dart';

import '../../application/ports/clock.dart';
import '../../domain/session/quiz_session.dart';
import 'error_view.dart';
import 'loading_view.dart';
import 'quiz_board.dart';

/// Corps de l'écran de quiz : chargement, échec, ou plateau de jeu (REQ-060).
///
/// Extrait de `QuizScreen` pour que l'écran reste court (RC-03, RC-04) et pour
/// que chaque état soit rendu par un composant unique et testable.
class QuizBody extends StatelessWidget {
  const QuizBody({
    required this.isLoading,
    required this.errorCode,
    required this.session,
    required this.clock,
    required this.onAnswer,
    required this.onRetry,
    super.key,
  });

  final bool isLoading;
  final String? errorCode;
  final QuizSession? session;
  final Clock clock;
  final void Function(String option) onAnswer;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const LoadingView();
    }
    final code = errorCode;
    if (code != null) {
      return ErrorView(code: code, onRetry: onRetry);
    }
    final current = session;
    if (current == null) {
      return const SizedBox.shrink();
    }
    // La session peut se terminer entre le setState et le rebuild : on ne lit
    // jamais `currentQuestion` dans cet état (évite une exception).
    if (current.isFinished) {
      return const LoadingView();
    }
    return QuizBoard(session: current, clock: clock, onAnswer: onAnswer);
  }
}
