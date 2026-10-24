import '../domain/session/quiz_session.dart';
import 'ports/clock.dart';

/// Issue d'une tentative de réponse (REQ-032/033).
enum AnswerOutcome {
  /// Réponse enregistrée.
  accepted,

  /// Réponse arrivée en retard (double appui, question déjà traitée) : ignorée.
  ignoredStale,
}

/// CMP-APP-03 — applique une réponse ou une expiration à la session.
final class AnswerQuestion {
  const AnswerQuestion({required Clock clock}) : _clock = clock;

  final Clock _clock;

  AnswerOutcome call(
    QuizSession session, {
    required int questionIndex,
    required String option,
  }) {
    if (session.index != questionIndex) {
      return AnswerOutcome.ignoredStale;
    }
    session.answer(
      questionIndex: questionIndex,
      option: option,
      nowMs: _clock.nowMs(),
    );
    return AnswerOutcome.accepted;
  }

  /// Retourne vrai si la question courante a expiré (REQ-035, REQ-037).
  bool expireIfDue(QuizSession session) => session.expireIfDue(_clock.nowMs());
}
