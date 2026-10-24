import '../entities/question.dart';
import '../errors/domain_errors.dart';

/// États possibles d'une session (REQ-036) — union scellée exhaustive.
sealed class SessionStatus {
  const SessionStatus();
}

final class SessionAnswering extends SessionStatus {
  const SessionAnswering({required this.index, required this.deadlineMs});

  final int index;

  /// Échéance absolue de la question courante, en millisecondes (REQ-034).
  final int deadlineMs;
}

final class SessionFinished extends SessionStatus {
  const SessionFinished();
}

/// Machine à états de la session de quiz.
///
/// Invariants :
///  1. `answers.length == questions.length` à tout instant ;
///  2. `index == questions.length` si et seulement si la session est terminée ;
///  3. une réponse enregistrée n'est jamais modifiée (REQ-033) ;
///  4. l'échéance est absolue et croissante d'une question à l'autre (REQ-034).
final class QuizSession {
  QuizSession._({
    required List<Question> questions,
    required List<String?> answers,
    required this.perQuestionMs,
    required SessionStatus status,
  })  : questions = List<Question>.unmodifiable(questions),
        _answers = answers,
        _status = status;

  factory QuizSession.start({
    required List<Question> questions,
    required Duration perQuestion,
    required int nowMs,
  }) {
    if (questions.isEmpty) {
      throw const InvalidSessionError('aucune question');
    }
    if (perQuestion.inMilliseconds <= 0) {
      throw InvalidDurationError(perQuestion.inMilliseconds);
    }
    return QuizSession._(
      questions: questions,
      answers: List<String?>.filled(questions.length, null, growable: false),
      perQuestionMs: perQuestion.inMilliseconds,
      status: SessionAnswering(
        index: 0,
        deadlineMs: nowMs + perQuestion.inMilliseconds,
      ),
    );
  }

  final List<Question> questions;
  final int perQuestionMs;
  final List<String?> _answers;
  SessionStatus _status;

  SessionStatus get status => _status;
  bool get isFinished => _status is SessionFinished;

  /// Index de la question courante, ou `questions.length` si terminée.
  int get index => switch (_status) {
        SessionAnswering(:final index) => index,
        SessionFinished() => questions.length,
      };

  List<String?> get answers => List<String?>.unmodifiable(_answers);

  Question get currentQuestion {
    final current = _status;
    if (current is! SessionAnswering) {
      throw const InvalidSessionError('session terminée');
    }
    return questions[current.index];
  }

  /// Nombre de questions déjà traitées (répondues ou expirées).
  int get answeredCount => _answers.where((answer) => answer != null).length;

  /// Score courant, recalculé par le domaine (aucun calcul dans l'IHM).
  int get scoreSoFar {
    var score = 0;
    for (var i = 0; i < questions.length; i++) {
      if (questions[i].isCorrect(_answers[i])) {
        score++;
      }
    }
    return score;
  }

  /// Temps restant borné à `[0, perQuestionMs]` (REQ-034).
  int remainingMs(int nowMs) {
    final current = _status;
    if (current is! SessionAnswering) {
      return 0;
    }
    final remaining = current.deadlineMs - nowMs;
    if (remaining <= 0) {
      return 0;
    }
    return remaining > perQuestionMs ? perQuestionMs : remaining;
  }

  /// Enregistre une réponse pour la question [questionIndex] (REQ-032/033).
  ///
  /// [questionIndex] est l'indice que l'interface croit courant : une réponse
  /// arrivée en retard (double appui) est ignorée sans effet.
  /// Lève [InvalidAnswerError] si l'option n'appartient pas à la question.
  void answer({
    required int questionIndex,
    required String option,
    required int nowMs,
  }) {
    final current = _status;
    if (current is! SessionAnswering || current.index != questionIndex) {
      return;
    }
    if (!questions[current.index].accepts(option)) {
      throw InvalidAnswerError(option);
    }
    _record(current.index, option, nowMs);
  }

  /// Fait expirer la question courante si l'échéance est atteinte (REQ-035).
  ///
  /// Retourne vrai si une expiration a eu lieu.
  bool expireIfDue(int nowMs) {
    final current = _status;
    if (current is! SessionAnswering || nowMs < current.deadlineMs) {
      return false;
    }
    _record(current.index, null, nowMs);
    return true;
  }

  void _record(int questionIndex, String? value, int nowMs) {
    if (_answers[questionIndex] != null) {
      return;
    }
    _answers[questionIndex] = value;
    if (questionIndex == questions.length - 1) {
      _status = const SessionFinished();
      return;
    }
    _status = SessionAnswering(
      index: questionIndex + 1,
      deadlineMs: nowMs + perQuestionMs,
    );
  }
}
