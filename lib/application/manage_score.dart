import 'ports/state_repository.dart';

/// CMP-APP-06 — lecture du score total (REQ-020).
final class ReadTotalScore {
  const ReadTotalScore({required StateRepository state}) : _state = state;

  final StateRepository _state;

  Future<int> call() async {
    final state = await _state.load();
    return state.score < 0 ? 0 : state.score;
  }
}

/// CMP-APP-07 — remise à zéro du score, progression inchangée (REQ-023).
final class ResetTotalScore {
  const ResetTotalScore({required StateRepository state}) : _state = state;

  final StateRepository _state;

  Future<void> call() async {
    final current = await _state.load();
    if (current.score == 0) {
      return;
    }
    await _state.save(current.copyWith(score: 0));
  }
}
