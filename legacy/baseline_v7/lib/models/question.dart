import 'dart:math';

class Question {
  Question({
    required String question,
    required String correctAnswer,
    required List<String> options,
  })  : question = question.trim(),
        correctAnswer = correctAnswer.trim(),
        options = List<String>.unmodifiable(
          options.map((option) => option.trim()),
        ) {
    if (this.question.isEmpty) {
      throw ArgumentError.value(question, 'question', 'ne peut pas être vide');
    }
    if (this.correctAnswer.isEmpty) {
      throw ArgumentError.value(
        correctAnswer,
        'correctAnswer',
        'ne peut pas être vide',
      );
    }
    if (this.options.length < 2) {
      throw ArgumentError.value(options, 'options', 'il en faut au moins deux');
    }
    if (this.options.any((option) => option.isEmpty)) {
      throw ArgumentError.value(options, 'options', 'ne peut pas contenir de réponse vide');
    }
    if (this.options.toSet().length != this.options.length) {
      throw ArgumentError.value(options, 'options', 'ne peut pas contenir de doublons');
    }
    if (!this.options.contains(this.correctAnswer)) {
      throw ArgumentError.value(
        correctAnswer,
        'correctAnswer',
        'doit être présente dans les options',
      );
    }
  }

  final String question;
  final String correctAnswer;
  final List<String> options;

  factory Question.fromJson(Map<String, dynamic> json) {
    final rawQuestion = json['question'] ?? json['arabe'];
    final rawCorrectAnswer = json['correct'] ?? json['correctAnswer'];
    final rawOptions = json['options'];

    if (rawQuestion is! String || rawQuestion.trim().isEmpty) {
      throw const FormatException('La question doit être une chaîne non vide.');
    }
    if (rawCorrectAnswer is! String || rawCorrectAnswer.trim().isEmpty) {
      throw const FormatException('La bonne réponse doit être une chaîne non vide.');
    }
    if (rawOptions is! List || rawOptions.any((option) => option is! String)) {
      throw const FormatException('Le champ « options » doit être une liste de textes.');
    }

    // Les fichiers de questions listent souvent la bonne réponse en premier :
    // on mélange l'ordre à chaque chargement pour éviter toute position fixe.
    final shuffledOptions = rawOptions.cast<String>().toList()..shuffle(Random());

    try {
      return Question(
        question: rawQuestion,
        correctAnswer: rawCorrectAnswer,
        options: shuffledOptions,
      );
    } on ArgumentError catch (error) {
      throw FormatException('Question invalide : $error');
    }
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'question': question,
        'correct': correctAnswer,
        'options': options,
      };
} 
