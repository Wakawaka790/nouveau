import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/application/ports/state_repository.dart';
import 'package:quiz_game/application/reset_level_progress.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';

import '../support/repository_fakes.dart';

/// TC-APP-05 — remise à zéro de la progression d'un thème (REQ-016).
void main() {
  final arabe = ThemeId.parse('arabe');
  final sira = ThemeId.parse('sira');
  final level1 = LevelNumber.parse(1);
  final level2 = LevelNumber.parse(2);
  final level3 = LevelNumber.parse(3);

  test('ramène la progression du thème à {1}', () async {
    final repository = FakeStateRepository(
      AppState(
        score: 12,
        progress: <ThemeId, Set<LevelNumber>>{
          arabe: <LevelNumber>{level1, level2, level3},
        },
      ),
    );
    await ResetLevelProgress(state: repository).call(arabe);
    expect(repository.state.progress[arabe], <LevelNumber>{level1});
    expect(repository.saveCount, 1);
  });

  test('conserve le score total (REQ-023)', () async {
    final repository = FakeStateRepository(
      AppState(
        score: 7,
        progress: <ThemeId, Set<LevelNumber>>{
          arabe: <LevelNumber>{level1, level2},
        },
      ),
    );
    await ResetLevelProgress(state: repository).call(arabe);
    expect(repository.state.score, 7);
  });

  test('ne touche pas aux autres thèmes', () async {
    final repository = FakeStateRepository(
      AppState(
        progress: <ThemeId, Set<LevelNumber>>{
          arabe: <LevelNumber>{level1, level2},
          sira: <LevelNumber>{level1, level2, level3},
        },
      ),
    );
    await ResetLevelProgress(state: repository).call(arabe);
    expect(repository.state.progress[sira], <LevelNumber>{level1, level2, level3});
  });

  test('n\'écrit rien si la progression vaut déjà {1} (REQ-044)', () async {
    final repository = FakeStateRepository(
      AppState(
        progress: <ThemeId, Set<LevelNumber>>{
          arabe: <LevelNumber>{level1},
        },
      ),
    );
    await ResetLevelProgress(state: repository).call(arabe);
    expect(repository.saveCount, 0);
  });

  test('propage l\'échec d\'écriture (REQ-044)', () async {
    final repository = FakeStateRepository(
      AppState(
        progress: <ThemeId, Set<LevelNumber>>{
          arabe: <LevelNumber>{level1, level2},
        },
      ),
    )..saveError = const StateWriteError('disque plein');
    await expectLater(
      ResetLevelProgress(state: repository).call(arabe),
      throwsA(isA<StateWriteError>()),
    );
  });
}
