import '../domain/entities/level_catalog.dart';
import '../domain/rules/scoring_rules.dart';
import '../domain/rules/unlock_policy.dart';
import '../domain/session/quiz_session.dart';
import '../domain/values/level_number.dart';
import '../domain/values/theme_id.dart';
import 'ports/logger.dart';
import 'ports/state_repository.dart';

/// Résultat d'une fin de session (REQ-038).
final class FinishResult {
  const FinishResult({
    required this.score,
    required this.total,
    required this.unlock,
    required this.persisted,
    this.failureCode,
  });

  final int score;
  final int total;
  final UnlockOutcome unlock;
  final bool persisted;
  final String? failureCode;

  double get accuracy => total == 0 ? 0 : score / total;
}

/// CMP-APP-04 — clôture transactionnelle : score + progression en **une** écriture.
final class FinishQuizSession {
  const FinishQuizSession({
    required StateRepository state,
    required Logger logger,
  })  : _state = state,
        _logger = logger;

  final StateRepository _state;
  final Logger _logger;

  Future<FinishResult> call({
    required QuizSession session,
    required ThemeId theme,
    required LevelNumber level,
    required LevelCatalog catalog,
  }) async {
    final computation = ScoringRules.compute(session.questions, session.answers);
    if (computation.hasLengthMismatch) {
      _logger.log(
        LogLevel.error,
        'SCORE-LENGTH-MISMATCH',
        'questions=${session.questions.length} answers=${session.answers.length}',
      );
    }

    final current = await _state.load();
    final unlocked = current.unlockedFor(theme);
    final outcome = UnlockPolicy.decide(
      catalog: catalog,
      completed: level,
      unlocked: unlocked,
    );

    final updatedLevels = <LevelNumber>{...unlocked};
    if (outcome is NewlyUnlocked) {
      updatedLevels.add(outcome.level);
    }
    final nextState = current.copyWith(
      score: current.score + computation.score,
      progress: <ThemeId, Set<LevelNumber>>{
        ...current.progress,
        theme: updatedLevels,
      },
    );

    var persisted = true;
    String? failureCode;
    if (nextState != current) {
      try {
        await _state.save(nextState);
      } on StateStoreError catch (error) {
        persisted = false;
        failureCode = error.code;
        _logger.log(LogLevel.error, error.code, error.detail);
      }
    }

    return FinishResult(
      score: computation.score,
      total: computation.total,
      unlock: outcome,
      persisted: persisted,
      failureCode: failureCode,
    );
  }
}
