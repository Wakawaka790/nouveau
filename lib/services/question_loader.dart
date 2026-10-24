import 'dart:convert';

import 'package:flutter/foundation.dart' show FlutterError;
import 'package:flutter/services.dart';
import 'package:quiz_game7/models/question.dart';

class QuizContentException implements Exception {
  const QuizContentException(this.message);

  final String message;

  @override
  String toString() => message;
}

class QuestionLoader {
  static String _normalizedQuizType(String quizType) {
    final normalizedType = quizType.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(normalizedType)) {
      throw ArgumentError.value(quizType, 'quizType', 'identifiant invalide');
    }
    return normalizedType;
  }

  static Future<dynamic> _loadJson(String path) async {
    late final String data;
    try {
      data = await rootBundle.loadString(path);
    } on FlutterError {
      throw QuizContentException(
        'Le fichier « $path » est introuvable. Vérifie les fichiers de questions et pubspec.yaml.',
      );
    }

    try {
      return jsonDecode(data);
    } on FormatException catch (error) {
      throw QuizContentException('JSON invalide dans « $path » : ${error.message}');
    }
  }

  static Future<List<int>> loadAvailableLevels(String quizType) async {
    final type = _normalizedQuizType(quizType);
    final path = 'assets/questions/$type/levels.json';
    final decoded = await _loadJson(path);
    if (decoded is! Map<String, dynamic>) {
      throw QuizContentException('« $path » doit contenir un objet JSON.');
    }

    final rawLevels = decoded['Levels'] ?? decoded['levels'];
    if (rawLevels is! List) {
      throw QuizContentException('Le fichier « $path » doit contenir une liste « Levels ».');
    }

    final levels = <int>[];
    for (final value in rawLevels) {
      final parsed = value is int
          ? value
          : value is String
              ? int.tryParse(value)
              : null;
      if (parsed == null || parsed < 1) {
        throw QuizContentException('« $path » contient un numéro de niveau invalide.');
      }
      if (levels.contains(parsed)) {
        throw QuizContentException('« $path » contient le niveau $parsed en double.');
      }
      levels.add(parsed);
    }

    levels.sort();
    if (levels.isNotEmpty && levels.first != 1) {
      throw QuizContentException('Le premier niveau de « $path » doit être le niveau 1.');
    }
    return levels;
  }

  static Future<List<Question>> loadQuestions(String quizType, int niveau) async {
    if (niveau < 1) {
      throw ArgumentError.value(niveau, 'niveau', 'doit être positif');
    }
    final type = _normalizedQuizType(quizType);
    final path = 'assets/questions/$type/level_$niveau.json';
    final decoded = await _loadJson(path);
    if (decoded is! List) {
      throw QuizContentException('« $path » doit contenir une liste JSON de questions.');
    }

    final questions = <Question>[];
    for (var index = 0; index < decoded.length; index++) {
      final value = decoded[index];
      if (value is! Map) {
        throw QuizContentException('La question ${index + 1} de « $path » doit être un objet.');
      }
      try {
        questions.add(Question.fromJson(Map<String, dynamic>.from(value)));
      } on FormatException catch (error) {
        throw QuizContentException('Question ${index + 1} de « $path » : ${error.message}');
      }
    }

    if (questions.isEmpty) {
      throw QuizContentException('Aucune question n’est définie dans « $path ».');
    }
    return questions;
  }
}
