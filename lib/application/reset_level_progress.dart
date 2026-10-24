import '../domain/values/level_number.dart';
import '../domain/values/theme_id.dart';
import 'ports/state_repository.dart';

/// CMP-APP-05 — remet la progression d'un thème à `{1}` (REQ-016).
final class ResetLevelProgress {
  const ResetLevelProgress({required StateRepository state}) : _state = state;

  final StateRepository _state;

  Future<void> call(ThemeId theme) async {
    final current = await _state.load();
    final next = current.copyWith(
      progress: <ThemeId, Set<LevelNumber>>{
        ...current.progress,
        theme: <LevelNumber>{LevelNumber.one},
      },
    );
    if (next == current) {
      return;
    }
    await _state.save(next);
  }
}
