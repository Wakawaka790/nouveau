import '../entities/question.dart';

/// Résultat du calcul de score d'une session (REQ-021, REQ-024).
final class ScoreComputation {
  const ScoreComputation({
    required this.score,
    required this.total,
    required this.hasLengthMismatch,
  });

  final int score;
  final int total;

  /// Vrai si les listes de questions et de réponses n'ont pas la même
  /// longueur : anomalie de séquencement à journaliser (ANO-13), et non à
  /// masquer par une troncature silencieuse.
  final bool hasLengthMismatch;

  double get accuracy => total == 0 ? 0 : score / total;
}

abstract final class ScoringRules {
  /// 1 point par réponse strictement égale à la bonne réponse.
  static ScoreComputation compute(
    List<Question> questions,
    List<String?> answers,
  ) {
    final comparable = questions.length < answers.length
        ? questions.length
        : answers.length;
    var score = 0;
    for (var i = 0; i < comparable; i++) {
      if (questions[i].isCorrect(answers[i])) {
        score++;
      }
    }
    return ScoreComputation(
      score: score,
      total: questions.length,
      hasLengthMismatch: questions.length != answers.length,
    );
  }
}
