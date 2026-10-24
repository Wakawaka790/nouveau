import '../domain/entities/question.dart';
import '../domain/session/quiz_session.dart';
import '../domain/values/level_number.dart';
import '../domain/values/theme_id.dart';
import 'ports/clock.dart';
import 'ports/question_repository.dart';
import 'ports/random_source.dart';

/// CMP-APP-02 — charge un niveau, mélange les options, crée la session.
final class StartQuizSession {
  const StartQuizSession({
    required QuestionRepository questions,
    required RandomSource random,
    required Clock clock,
    Duration perQuestion = const Duration(seconds: 10),
  })  : _questions = questions,
        _random = random,
        _clock = clock,
        _perQuestion = perQuestion;

  final QuestionRepository _questions;
  final RandomSource _random;
  final Clock _clock;
  final Duration _perQuestion;

  Future<QuizSession> call({
    required ThemeId theme,
    required LevelNumber level,
  }) async {
    final loaded = await _questions.loadQuestions(theme, level);
    final shuffled = loaded.map(_shuffleOptions).toList(growable: false);
    return QuizSession.start(
      questions: shuffled,
      perQuestion: _perQuestion,
      nowMs: _clock.nowMs(),
    );
  }

  /// Mélange de Fisher-Yates, déterministe pour une graine donnée (REQ-007).
  Question _shuffleOptions(Question question) {
    final options = <String>[...question.options];
    for (var i = options.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final swapped = options[i];
      options[i] = options[j];
      options[j] = swapped;
    }
    return question.withOptions(options);
  }
}
