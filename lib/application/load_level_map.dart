import '../domain/entities/level_catalog.dart';
import '../domain/values/level_number.dart';
import '../domain/values/theme_id.dart';
import 'ports/question_repository.dart';
import 'ports/state_repository.dart';

/// Vue de la carte des niveaux, prête à afficher (REQ-017).
final class LevelMapView {
  const LevelMapView({required this.catalog, required this.unlocked});

  final LevelCatalog catalog;
  final Set<LevelNumber> unlocked;

  bool isUnlocked(LevelNumber level) => unlocked.contains(level);

  /// Nombre de niveaux débloqués **réellement présents** dans le catalogue.
  int get unlockedCount =>
      catalog.levels.where(unlocked.contains).length;
}

/// CMP-APP-01 — charge le catalogue et l'état, sans logique d'affichage.
final class LoadLevelMap {
  const LoadLevelMap({
    required QuestionRepository questions,
    required StateRepository state,
  })  : _questions = questions,
        _state = state;

  final QuestionRepository _questions;
  final StateRepository _state;

  Future<LevelMapView> call(ThemeId theme) async {
    final catalog = await _questions.loadCatalog(theme);
    final state = await _state.load();
    return LevelMapView(catalog: catalog, unlocked: state.unlockedFor(theme));
  }
}
