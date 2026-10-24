import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/domain/entities/quiz_theme.dart';
import 'package:quiz_game/domain/values/theme_id.dart';

void main() {
  group('QuizTheme (REQ-001, REQ-002)', () {
    test('livre exactement les 8 thèmes attendus', () {
      expect(quizThemes, hasLength(8));
      expect(
        quizThemes.map((QuizTheme theme) => theme.id.value).toSet(),
        <String>{
          'arabe',
          'sira',
          'coran',
          'histoire',
          'sahaba',
          'hijra',
          'terme',
          'general',
        },
      );
    });

    test('aucun libellé ni description vide', () {
      for (final QuizTheme theme in quizThemes) {
        expect(theme.label.trim(), isNotEmpty, reason: theme.id.value);
        expect(theme.description.trim(), isNotEmpty, reason: theme.id.value);
      }
    });

    test('la liste de référence est non modifiable (RC-09)', () {
      expect(
        // Toute saisie existante convient : l'ajout doit échouer quoi qu'il
        // arrive, c'est la nature de la liste qui est testée.
        () => quizThemes.add(quizThemes.first),
        throwsUnsupportedError,
      );
    });

    test('themeForId résout un identifiant livré', () {
      final QuizTheme? theme = themeForId(ThemeId.parse('coran'));
      expect(theme, isNotNull);
      expect(theme!.label, 'Coran');
    });

    test('themeForId renvoie null pour un identifiant non livré', () {
      expect(themeForId(ThemeId.parse('inconnu')), isNull);
    });
  });
}
