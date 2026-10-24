import '../values/theme_id.dart';

/// Thème proposé à l'utilisateur (donnée de référence du logiciel).
///
/// L'icône est choisie par la présentation : le domaine ignore Flutter.
final class QuizTheme {
  const QuizTheme({
    required this.id,
    required this.label,
    required this.description,
  });

  final ThemeId id;
  final String label;
  final String description;
}

/// Liste des thèmes livrés. L'identifiant sert de nom de dossier d'assets.
///
/// La liste est **non modifiable** (RC-09) : une donnée de référence ne doit
/// pas pouvoir être altérée à l'exécution (REQ-002).
final List<QuizTheme> quizThemes = List<QuizTheme>.unmodifiable(<QuizTheme>[
  QuizTheme(id: ThemeId.parse('arabe'), label: 'Arabe', description: 'Vocabulaire et langue arabe'),
  QuizTheme(id: ThemeId.parse('sira'), label: 'Sira', description: 'La vie du Prophète'),
  QuizTheme(id: ThemeId.parse('coran'), label: 'Coran', description: 'Connaissances autour du Coran'),
  QuizTheme(id: ThemeId.parse('histoire'), label: 'Histoire', description: 'Repères historiques'),
  QuizTheme(id: ThemeId.parse('sahaba'), label: 'Sahaba', description: 'Les compagnons'),
  QuizTheme(id: ThemeId.parse('hijra'), label: 'Hijra', description: 'Le récit de l’Hégire'),
  QuizTheme(id: ThemeId.parse('terme'), label: 'Termes', description: 'Mots et notions à connaître'),
  QuizTheme(id: ThemeId.parse('general'), label: 'Général', description: 'Questions variées'),
]);

/// Résolution d'un identifiant, ou `null` s'il n'est pas livré.
QuizTheme? themeForId(ThemeId id) {
  for (final theme in quizThemes) {
    if (theme.id == id) {
      return theme;
    }
  }
  return null;
}
