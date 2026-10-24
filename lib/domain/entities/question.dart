import '../errors/domain_errors.dart';

/// Question à choix unique, immuable, porteuse des invariants REQ-005.
final class Question {
  Question._({
    required this.text,
    required this.correctAnswer,
    required List<String> options,
  }) : options = List<String>.unmodifiable(options);

  /// Construit une question valide ou lève [InvalidQuestionError].
  ///
  /// [index] sert uniquement au diagnostic (numérotation à partir de 0, rendue
  /// à partir de 1 dans le message d'erreur).
  factory Question.create({
    required String text,
    required String correctAnswer,
    required List<String> options,
    int index = 0,
  }) {
    final trimmedText = text.trim();
    final trimmedAnswer = correctAnswer.trim();
    final trimmedOptions = options.map((option) => option.trim()).toList(growable: false);

    if (trimmedText.isEmpty) {
      throw InvalidQuestionError(index, 'énoncé vide');
    }
    if (trimmedAnswer.isEmpty) {
      throw InvalidQuestionError(index, 'bonne réponse vide');
    }
    if (trimmedOptions.length < 2) {
      throw InvalidQuestionError(index, 'il faut au moins deux options');
    }
    if (trimmedOptions.any((option) => option.isEmpty)) {
      throw InvalidQuestionError(index, 'option vide');
    }
    if (trimmedOptions.toSet().length != trimmedOptions.length) {
      throw InvalidQuestionError(index, 'option dupliquée');
    }
    if (!trimmedOptions.contains(trimmedAnswer)) {
      throw InvalidQuestionError(index, 'bonne réponse absente des options');
    }

    return Question._(
      text: trimmedText,
      correctAnswer: trimmedAnswer,
      options: trimmedOptions,
    );
  }

  final String text;
  final String correctAnswer;
  final List<String> options;

  /// Vrai si [answer] est exactement la bonne réponse (REQ-021).
  bool isCorrect(String? answer) => answer == correctAnswer;

  /// Vrai si [answer] fait partie des options proposées (REQ-032).
  bool accepts(String answer) => options.contains(answer);

  /// Nouvelle instance avec un autre ordre d'options (REQ-007).
  Question withOptions(List<String> reordered) => Question.create(
        text: text,
        correctAnswer: correctAnswer,
        options: reordered,
      );
}
