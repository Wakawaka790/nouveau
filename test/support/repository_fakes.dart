import 'package:quiz_game/application/ports/question_repository.dart';
import 'package:quiz_game/application/ports/state_repository.dart';
import 'package:quiz_game/domain/entities/level_catalog.dart';
import 'package:quiz_game/domain/entities/question.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';

/// Dépôt de questions en mémoire (double de test de `QuestionRepository`).
///
/// Permet de provoquer un `ContentError` sans toucher aux assets : c'est la
/// seule façon de tester les chemins d'échec du cas d'usage (REQ-050).
final class FakeQuestionRepository implements QuestionRepository {
  FakeQuestionRepository({
    this.catalog,
    this.questions = const <Question>[],
    this.error,
  });

  LevelCatalog? catalog;
  List<Question> questions;
  Object? error;

  final List<String> catalogCalls = <String>[];
  final List<String> questionCalls = <String>[];

  @override
  Future<LevelCatalog> loadCatalog(ThemeId theme) async {
    catalogCalls.add(theme.value);
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    final current = catalog;
    if (current == null) {
      throw StateError('catalogue non configuré dans le test');
    }
    return current;
  }

  @override
  Future<List<Question>> loadQuestions(ThemeId theme, LevelNumber level) async {
    questionCalls.add('${theme.value}/${level.value}');
    final failure = error;
    if (failure != null) {
      throw failure;
    }
    return questions;
  }
}

/// Dépôt d'état en mémoire (double de test de `StateRepository`).
///
/// Enregistre chaque écriture : les tests vérifient ainsi qu'aucune écriture
/// inutile n'est faite (REQ-016, REQ-023) et qu'une panne est bien propagée.
final class FakeStateRepository implements StateRepository {
  FakeStateRepository([this.state = const AppState()]);

  AppState state;
  Object? saveError;
  final List<AppState> saved = <AppState>[];

  int get saveCount => saved.length;

  @override
  Future<AppState> load() async => state;

  @override
  Future<void> save(AppState next) async {
    final failure = saveError;
    if (failure != null) {
      throw failure;
    }
    state = next;
    saved.add(next);
  }
}
