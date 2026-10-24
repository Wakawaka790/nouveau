import '../../domain/values/level_number.dart';
import '../../domain/values/theme_id.dart';

/// État persistant complet du logiciel (REQ-040).
final class AppState {
  const AppState({
    this.score = 0,
    this.progress = const <ThemeId, Set<LevelNumber>>{},
  });

  final int score;
  final Map<ThemeId, Set<LevelNumber>> progress;

  /// Niveaux déverrouillés d'un thème ; le niveau 1 l'est toujours (REQ-010).
  Set<LevelNumber> unlockedFor(ThemeId theme) {
    final stored = progress[theme] ?? const <LevelNumber>{};
    return <LevelNumber>{...stored, LevelNumber.one};
  }

  AppState copyWith({
    int? score,
    Map<ThemeId, Set<LevelNumber>>? progress,
  }) =>
      AppState(
        score: score ?? this.score,
        progress: progress ?? this.progress,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other is! AppState || other.score != score) {
      return false;
    }
    if (other.progress.length != progress.length) {
      return false;
    }
    for (final entry in progress.entries) {
      final otherLevels = other.progress[entry.key];
      if (otherLevels == null || otherLevels.length != entry.value.length) {
        return false;
      }
      if (!otherLevels.containsAll(entry.value)) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(score, progress.length);
}

/// Dépôt de l'état persistant (IF-06).
abstract interface class StateRepository {
  /// Ne lève jamais : un état corrompu est remplacé par l'état par défaut et
  /// journalisé (REQ-041).
  Future<AppState> load();

  /// Lève [StateStoreError] en cas d'échec d'écriture (REQ-044).
  Future<void> save(AppState state);
}
