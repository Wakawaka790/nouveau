import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/application/load_level_map.dart';
import 'package:quiz_game/application/ports/state_repository.dart';
import 'package:quiz_game/domain/entities/level_catalog.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';

import '../support/repository_fakes.dart';

/// TC-APP-01 — carte des niveaux (REQ-010, REQ-017).
void main() {
  final arabe = ThemeId.parse('arabe');
  final sira = ThemeId.parse('sira');
  final level1 = LevelNumber.parse(1);
  final level2 = LevelNumber.parse(2);
  final level3 = LevelNumber.parse(3);

  LoadLevelMap build({
    required List<int> catalogLevels,
    Map<ThemeId, Set<LevelNumber>> progress =
        const <ThemeId, Set<LevelNumber>>{},
    Object? error,
  }) =>
      LoadLevelMap(
        questions: FakeQuestionRepository(
          catalog: LevelCatalog.create(
            theme: arabe,
            levels: catalogLevels.map(LevelNumber.parse).toList(),
          ),
          error: error,
        ),
        state: FakeStateRepository(AppState(progress: progress)),
      );

  test('charge le catalogue et l\'état du thème demandé', () async {
    final view = await build(catalogLevels: <int>[1, 2]).call(arabe);
    expect(view.catalog.levels, <LevelNumber>[level1, level2]);
    expect(view.unlocked, <LevelNumber>{level1});
  });

  test('le niveau 1 est toujours déverrouillé (REQ-010)', () async {
    final view = await build(
      catalogLevels: <int>[1, 2, 3],
      progress: <ThemeId, Set<LevelNumber>>{
        arabe: <LevelNumber>{level2, level3},
      },
    ).call(arabe);
    expect(view.isUnlocked(level1), isTrue);
    expect(view.isUnlocked(level2), isTrue);
  });

  test('unlockedCount ne compte que les niveaux du catalogue (REQ-017)',
      () async {
    final view = await build(
      catalogLevels: <int>[1, 2],
      progress: <ThemeId, Set<LevelNumber>>{
        arabe: <LevelNumber>{level1, level2, level3},
      },
    ).call(arabe);
    expect(view.unlockedCount, 2);
  });

  test('la progression d\'un autre thème n\'est pas utilisée', () async {
    final view = await build(
      catalogLevels: <int>[1, 2, 3],
      progress: <ThemeId, Set<LevelNumber>>{
        sira: <LevelNumber>{level1, level2, level3},
      },
    ).call(arabe);
    expect(view.unlocked, <LevelNumber>{level1});
  });

  test('un catalogue vide reste affichable', () async {
    final view = await build(catalogLevels: <int>[]).call(arabe);
    expect(view.catalog.isEmpty, isTrue);
    expect(view.unlockedCount, 0);
  });

  test('propage l\'erreur de contenu (REQ-050)', () async {
    await expectLater(
      build(catalogLevels: <int>[1], error: ContentNotFoundError('arabe/levels.json'))
          .call(arabe),
      throwsA(isA<ContentError>()),
    );
  });
}
