import '../../domain/entities/level_catalog.dart';
import '../../domain/entities/question.dart';
import '../../domain/values/level_number.dart';
import '../../domain/values/theme_id.dart';

/// Accès au contenu (données d'application, IF-05).
abstract interface class QuestionRepository {
  /// Lève une [ContentError] si le catalogue est absent ou invalide.
  Future<LevelCatalog> loadCatalog(ThemeId theme);

  /// Lève une [ContentError] si le niveau est absent, vide ou invalide.
  Future<List<Question>> loadQuestions(ThemeId theme, LevelNumber level);
}
