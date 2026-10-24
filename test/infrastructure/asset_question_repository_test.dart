import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';
import 'package:quiz_game/infrastructure/content/asset_question_repository.dart';

import '../support/fakes.dart';

void main() {
  final arabe = ThemeId.parse('arabe');
  final level1 = LevelNumber.parse(1);

  AssetQuestionRepository repositoryWith(Map<String, String> files) =>
      AssetQuestionRepository(reader: FakeAssetReader(files));

  String catalog(String levels) => '{"Levels": $levels}';
  const String catalogPath = 'assets/questions/arabe/levels.json';
  const String levelPath = 'assets/questions/arabe/level_1.json';

  group('Catalogue (REQ-001 à REQ-003)', () {
    test('charge et trie un catalogue valide', () async {
      final repo = repositoryWith(<String, String>{
        catalogPath: catalog('[3,1,2]'),
      });
      final loaded = await repo.loadCatalog(arabe);
      expect(loaded.levels.map((level) => level.value), <int>[1, 2, 3]);
      expect(loaded.theme, arabe);
    });

    test('accepte la clé "levels" en minuscules', () async {
      final repo = repositoryWith(<String, String>{
        catalogPath: '{"levels":[1]}',
      });
      final loaded = await repo.loadCatalog(arabe);
      expect(loaded.length, 1);
    });

    test('refuse un fichier absent', () async {
      await expectLater(
        repositoryWith(<String, String>{}).loadCatalog(arabe),
        throwsA(isA<ContentNotFoundError>()),
      );
    });

    test('refuse un JSON illisible', () async {
      final repo = repositoryWith(<String, String>{catalogPath: '{oops'});
      await expectLater(
        repo.loadCatalog(arabe),
        throwsA(isA<ContentParseError>()),
      );
    });

    test('refuse une clé absente ou de type incorrect', () async {
      for (final content in <String>['{}', '{"Levels":"1,2"}', '[]']) {
        final repo = repositoryWith(<String, String>{catalogPath: content});
        await expectLater(
          repo.loadCatalog(arabe),
          throwsA(isA<ContentSchemaError>()),
          reason: 'contenu: $content',
        );
      }
    });

    test('refuse un doublon et un catalogue sans niveau 1', () async {
      for (final content in <String>[
        catalog('[1,1,2]'),
        catalog('[2,3]'),
        catalog('[0,1]'),
      ]) {
        final repo = repositoryWith(<String, String>{catalogPath: content});
        await expectLater(
          repo.loadCatalog(arabe),
          throwsA(isA<ContentSchemaError>()),
          reason: 'contenu: $content',
        );
      }
    });
  });

  group('Questions (REQ-004 à REQ-008)', () {
    test('charge un niveau valide et accepte les alias de clés', () async {
      final repo = repositoryWith(<String, String>{
        levelPath: '[{"arabe":"Q","correctAnswer":"B","options":["A","B"]}]',
      });
      final questions = await repo.loadQuestions(arabe, level1);
      expect(questions, hasLength(1));
      expect(questions.first.text, 'Q');
      expect(questions.first.correctAnswer, 'B');
    });

    test('refuse un niveau vide', () async {
      final repo = repositoryWith(<String, String>{levelPath: '[]'});
      await expectLater(
        repo.loadQuestions(arabe, level1),
        throwsA(isA<EmptyLevelError>()),
      );
    });

    test('refuse un fichier non liste', () async {
      final repo = repositoryWith(<String, String>{levelPath: '{"q":1}'});
      await expectLater(
        repo.loadQuestions(arabe, level1),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('refuse un élément non objet et indique l\'index', () async {
      final repo = repositoryWith(<String, String>{levelPath: '["texte"]'});
      try {
        await repo.loadQuestions(arabe, level1);
        fail('une erreur était attendue');
      } on ContentSchemaError catch (error) {
        expect(error.detail, contains('question 1'));
      }
    });

    test('propage l\'index de la question invalide', () async {
      final repo = repositoryWith(<String, String>{
        levelPath: '[{"question":"Q","correct":"B","options":["A","B"]},'
            '{"question":"Q2","correct":"Z","options":["A","B"]}]',
      });
      try {
        await repo.loadQuestions(arabe, level1);
        fail('une erreur était attendue');
      } on ContentSchemaError catch (error) {
        expect(error.detail, contains('question 2'));
      }
    });

    test('refuse des options non textuelles', () async {
      final repo = repositoryWith(<String, String>{
        levelPath: '[{"question":"Q","correct":"B","options":["A",2]}]',
      });
      await expectLater(
        repo.loadQuestions(arabe, level1),
        throwsA(isA<ContentSchemaError>()),
      );
    });

    test('le chemin dépend du thème et du niveau (aucune injection de chemin)', () async {
      final reader = FakeAssetReader(<String, String>{levelPath: '[]'});
      final repo = AssetQuestionRepository(reader: reader);
      await expectLater(
        repo.loadQuestions(arabe, level1),
        throwsA(isA<EmptyLevelError>()),
      );
      expect(reader.reads, <String>[levelPath]);
    });
  });
}
