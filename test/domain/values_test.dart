import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/domain/entities/level_catalog.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';

void main() {
  group('ThemeId (REQ-006)', () {
    test('accepte un identifiant conforme et le normalise', () {
      expect(ThemeId.parse('  Arabe ').value, 'arabe');
      expect(ThemeId.parse('quiz-2_a').value, 'quiz-2_a');
    });

    test('refuse un identifiant non conforme', () {
      for (final raw in <String>['', '  ', 'a b', 'a/b', '../etc', 'é',
          'abcdefghijabcdefghijabcdefghijabc']) {
        expect(
          () => ThemeId.parse(raw),
          throwsA(isA<InvalidThemeIdError>()),
          reason: 'entrée: "$raw"',
        );
      }
    });
  });

  group('LevelNumber (REQ-003)', () {
    test('accepte les bornes 1 et 99', () {
      expect(LevelNumber.parse(1).value, 1);
      expect(LevelNumber.parse('99').value, 99);
    });

    test('refuse les valeurs hors bornes et non numériques', () {
      for (final raw in <Object?>[0, 100, -1, '1.5', 'abc', null, 1.0]) {
        expect(
          () => LevelNumber.parse(raw),
          throwsA(isA<InvalidLevelNumberError>()),
          reason: 'entrée: $raw',
        );
      }
    });
  });

  group('LevelCatalog (REQ-003)', () {
    final theme = ThemeId.parse('arabe');

    test('trie les niveaux et accepte un catalogue valide', () {
      final catalog = LevelCatalog.create(
        theme: theme,
        levels: <LevelNumber>[
          LevelNumber.parse(3),
          LevelNumber.parse(1),
          LevelNumber.parse(2),
        ],
      );
      expect(catalog.levels.map((level) => level.value), <int>[1, 2, 3]);
    });

    test('refuse un doublon', () {
      expect(
        () => LevelCatalog.create(
          theme: theme,
          levels: <LevelNumber>[LevelNumber.parse(1), LevelNumber.parse(1)],
        ),
        throwsA(isA<InvalidCatalogError>()),
      );
    });

    test('refuse un catalogue ne commençant pas par 1', () {
      expect(
        () => LevelCatalog.create(
          theme: theme,
          levels: <LevelNumber>[LevelNumber.parse(2)],
        ),
        throwsA(isA<InvalidCatalogError>()),
      );
    });

    test('next() renvoie le niveau configuré suivant ou null', () {
      final catalog = LevelCatalog.create(
        theme: theme,
        levels: <LevelNumber>[LevelNumber.parse(1), LevelNumber.parse(3)],
      );
      expect(catalog.next(LevelNumber.parse(1))?.value, 3);
      expect(catalog.next(LevelNumber.parse(3)), isNull);
      expect(catalog.next(LevelNumber.parse(2)), isNull);
    });
  });
}
