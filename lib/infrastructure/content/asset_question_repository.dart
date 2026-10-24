import 'dart:convert';

import '../../application/ports/question_repository.dart';
import '../../domain/entities/level_catalog.dart';
import '../../domain/entities/question.dart';
import '../../domain/errors/domain_errors.dart';
import '../../domain/values/level_number.dart';
import '../../domain/values/theme_id.dart';
import 'asset_reader.dart';

/// Accès au contenu embarqué, avec validation de schéma complète (REQ-001..008).
final class AssetQuestionRepository implements QuestionRepository {
  const AssetQuestionRepository({required AssetReader reader}) : _reader = reader;

  static const int maxQuestionsPerLevel = 200;
  static const int maxOptionsPerQuestion = 10;
  static const int maxTextLength = 500;

  final AssetReader _reader;

  static String catalogPath(ThemeId theme) =>
      'assets/questions/${theme.value}/levels.json';

  static String levelPath(ThemeId theme, LevelNumber level) =>
      'assets/questions/${theme.value}/level_${level.value}.json';

  @override
  Future<LevelCatalog> loadCatalog(ThemeId theme) async {
    final path = catalogPath(theme);
    final decoded = await _readJson(path);
    if (decoded is! Map<String, Object?>) {
      throw ContentSchemaError(path, 'un objet JSON est attendu');
    }
    final rawLevels = decoded['Levels'] ?? decoded['levels'];
    if (rawLevels is! List<Object?>) {
      throw ContentSchemaError(path, 'clé "Levels" absente ou non liste');
    }
    if (rawLevels.length > LevelNumber.maxValue) {
      throw ContentSchemaError(
        path,
        'plus de ${LevelNumber.maxValue} niveaux configurés',
      );
    }
    final levels = <LevelNumber>[];
    try {
      for (final raw in rawLevels) {
        levels.add(LevelNumber.parse(raw));
      }
    } on DomainError catch (error) {
      throw ContentSchemaError(path, error.detail);
    }
    if (levels.isEmpty) {
      throw ContentSchemaError(path, 'aucun niveau configuré');
    }
    try {
      return LevelCatalog.create(theme: theme, levels: levels);
    } on DomainError catch (error) {
      throw ContentSchemaError(path, error.detail);
    }
  }

  @override
  Future<List<Question>> loadQuestions(ThemeId theme, LevelNumber level) async {
    final path = levelPath(theme, level);
    final decoded = await _readJson(path);
    if (decoded is! List<Object?>) {
      throw ContentSchemaError(path, 'une liste JSON est attendue');
    }
    if (decoded.isEmpty) {
      throw EmptyLevelError(path);
    }
    if (decoded.length > maxQuestionsPerLevel) {
      throw ContentSchemaError(
        path,
        'plus de $maxQuestionsPerLevel questions',
      );
    }
    final questions = <Question>[];
    for (var index = 0; index < decoded.length; index++) {
      questions.add(_parseQuestion(path, decoded[index], index));
    }
    return List<Question>.unmodifiable(questions);
  }

  Question _parseQuestion(String path, Object? raw, int index) {
    if (raw is! Map<String, Object?>) {
      throw ContentSchemaError(path, 'question ${index + 1}: objet attendu');
    }
    final text = raw['question'] ?? raw['arabe'];
    final correct = raw['correct'] ?? raw['correctAnswer'];
    final options = raw['options'];
    if (text is! String || text.trim().isEmpty) {
      throw ContentSchemaError(path, 'question ${index + 1}: énoncé invalide');
    }
    if (text.length > maxTextLength) {
      throw ContentSchemaError(path, 'question ${index + 1}: énoncé trop long');
    }
    if (correct is! String || correct.trim().isEmpty) {
      throw ContentSchemaError(
        path,
        'question ${index + 1}: bonne réponse invalide',
      );
    }
    if (options is! List<Object?> || options.any((option) => option is! String)) {
      throw ContentSchemaError(
        path,
        'question ${index + 1}: "options" doit être une liste de textes',
      );
    }
    if (options.length > maxOptionsPerQuestion) {
      throw ContentSchemaError(
        path,
        'question ${index + 1}: plus de $maxOptionsPerQuestion options',
      );
    }
    try {
      return Question.create(
        text: text,
        correctAnswer: correct,
        options: options.cast<String>(),
        index: index,
      );
    } on DomainError catch (error) {
      throw ContentSchemaError(path, error.detail);
    }
  }

  Future<Object?> _readJson(String path) async {
    final String raw;
    try {
      raw = await _reader.read(path);
    } on Object catch (error) {
      throw ContentNotFoundError(path);
    }
    try {
      return jsonDecode(raw);
    } on FormatException catch (error) {
      throw ContentParseError(path, error.message);
    }
  }
}
