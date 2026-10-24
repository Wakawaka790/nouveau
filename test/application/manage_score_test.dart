import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/application/manage_score.dart';
import 'package:quiz_game/application/ports/state_repository.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';

import '../support/repository_fakes.dart';

/// TC-APP-06 — lecture et remise à zéro du score total (REQ-020, REQ-023).
void main() {
  final arabe = ThemeId.parse('arabe');
  final level2 = LevelNumber.parse(2);

  test('ReadTotalScore renvoie 0 par défaut (REQ-020)', () async {
    final score = await ReadTotalScore(state: FakeStateRepository()).call();
    expect(score, 0);
  });

  test('ReadTotalScore renvoie le score enregistré', () async {
    final score = await ReadTotalScore(
      state: FakeStateRepository(const AppState(score: 42)),
    ).call();
    expect(score, 42);
  });

  test('ReadTotalScore borne un score négatif à 0 (REQ-020)', () async {
    final score = await ReadTotalScore(
      state: FakeStateRepository(const AppState(score: -3)),
    ).call();
    expect(score, 0);
  });

  test('ResetTotalScore remet le score à 0 et garde la progression (REQ-023)',
      () async {
    final repository = FakeStateRepository(
      AppState(
        score: 30,
        progress: <ThemeId, Set<LevelNumber>>{
          arabe: <LevelNumber>{LevelNumber.one, level2},
        },
      ),
    );
    await ResetTotalScore(state: repository).call();
    expect(repository.state.score, 0);
    expect(repository.state.progress[arabe], <LevelNumber>{LevelNumber.one, level2});
    expect(repository.saveCount, 1);
  });

  test('ResetTotalScore n\'écrit rien si le score vaut déjà 0', () async {
    final repository = FakeStateRepository();
    await ResetTotalScore(state: repository).call();
    expect(repository.saveCount, 0);
  });

  test('ResetTotalScore propage l\'échec d\'écriture (REQ-044)', () async {
    final repository = FakeStateRepository(const AppState(score: 5))
      ..saveError = const StateWriteError('stockage indisponible');
    await expectLater(
      ResetTotalScore(state: repository).call(),
      throwsA(isA<StateWriteError>()),
    );
  });
}
