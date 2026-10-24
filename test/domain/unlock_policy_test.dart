import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/domain/entities/level_catalog.dart';
import 'package:quiz_game/domain/rules/unlock_policy.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';

void main() {
  final catalog = LevelCatalog.create(
    theme: ThemeId.parse('arabe'),
    levels: <LevelNumber>[
      for (final value in <int>[1, 2, 3, 5]) LevelNumber.parse(value),
    ],
  );

  UnlockOutcome decide(int completed, Set<int> unlocked) => UnlockPolicy.decide(
        catalog: catalog,
        completed: LevelNumber.parse(completed),
        unlocked: unlocked.map(LevelNumber.parse).toSet(),
      );

  group('UnlockPolicy (REQ-012 à REQ-014)', () {
    test('débloque le niveau configuré suivant (pas le suivant arithmétique)', () {
      final outcome = decide(3, <int>{1, 2, 3});
      expect(outcome, isA<NewlyUnlocked>());
      expect((outcome as NewlyUnlocked).level.value, 5);
    });

    test('annonce alreadyUnlocked sans effet si déjà déverrouillé (ANO-09)', () {
      final outcome = decide(1, <int>{1, 2});
      expect(outcome, isA<AlreadyUnlocked>());
      expect((outcome as AlreadyUnlocked).level.value, 2);
    });

    test('noNextLevel sur le dernier niveau du catalogue', () {
      expect(decide(5, <int>{1, 2, 3, 5}), isA<NoNextLevel>());
    });

    test('notEligible si le niveau terminé n\'est pas déverrouillé', () {
      final outcome = decide(3, <int>{1});
      expect(outcome, isA<NotEligible>());
      expect((outcome as NotEligible).reason, 'LEVEL-NOT-UNLOCKED');
    });

    test('notEligible si le niveau n\'est pas au catalogue', () {
      final outcome = decide(4, <int>{1, 2, 3, 4});
      expect(outcome, isA<NotEligible>());
      expect((outcome as NotEligible).reason, 'LEVEL-NOT-IN-CATALOG');
    });
  });
}
