import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/application/finish_quiz_session.dart';
import 'package:quiz_game/application/ports/state_repository.dart';
import 'package:quiz_game/domain/entities/level_catalog.dart';
import 'package:quiz_game/domain/entities/question.dart';
import 'package:quiz_game/domain/rules/unlock_policy.dart';
import 'package:quiz_game/domain/session/quiz_session.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';
import 'package:quiz_game/infrastructure/storage/prefs_state_repository.dart';

import '../support/fakes.dart';

/// Banc d'essai du cas d'usage de fin de session.
final class _Harness {
  _Harness(this.useCase, this.store, this.logger);

  final FinishQuizSession useCase;
  final InMemoryStore store;
  final RecordingLogger logger;
}

void main() {
  final arabe = ThemeId.parse('arabe');
  final level1 = LevelNumber.parse(1);
  final level2 = LevelNumber.parse(2);
  final catalog = LevelCatalog.create(
    theme: arabe,
    levels: <LevelNumber>[level1, level2],
  );

  QuizSession sessionWith({required int count, required int correctAnswers}) {
    final session = QuizSession.start(
      questions: <Question>[
        for (var i = 0; i < count; i++) question('Q$i'),
      ],
      perQuestion: const Duration(seconds: 10),
      nowMs: 0,
    );
    for (var i = 0; i < count; i++) {
      session.answer(
        questionIndex: i,
        option: i < correctAnswers ? 'B' : 'A',
        nowMs: 0,
      );
    }
    return session;
  }

  Future<_Harness> build({AppState? initialState, bool failWrite = false}) async {
    final store = InMemoryStore();
    final logger = RecordingLogger();
    final repo = PrefsStateRepository(store: store, logger: logger);
    if (initialState != null) {
      await repo.save(initialState);
    }
    store
      ..writeCount = 0
      ..failOnWrite = failWrite;
    return _Harness(
      FinishQuizSession(state: repo, logger: logger),
      store,
      logger,
    );
  }

  group('Fin de session (REQ-021, REQ-022)', () {
    test('cumule le score et débloque le niveau suivant en une écriture', () async {
      final harness = await build(initialState: const AppState(score: 10));

      final result = await harness.useCase(
        session: sessionWith(count: 3, correctAnswers: 2),
        theme: arabe,
        level: level1,
        catalog: catalog,
      );

      expect(result.score, 2);
      expect(result.total, 3);
      expect(result.accuracy, closeTo(0.667, 0.001));
      expect(result.unlock, isA<NewlyUnlocked>());
      expect(result.persisted, isTrue);
      expect(harness.store.writeCount, 1, reason: 'une seule écriture (REQ-022)');
    });

    test('score nul conservé, niveau 1 terminé débloque quand même le 2', () async {
      final harness = await build();
      final result = await harness.useCase(
        session: sessionWith(count: 2, correctAnswers: 0),
        theme: arabe,
        level: level1,
        catalog: catalog,
      );
      expect(result.score, 0);
      expect(result.unlock, isA<NewlyUnlocked>(), reason: 'RG-03/H3 : pas de seuil');
      expect(result.persisted, isTrue);
    });

    test('ne persiste rien et signale l\'échec si l\'écriture échoue (REQ-044)', () async {
      final harness = await build(failWrite: true);
      final result = await harness.useCase(
        session: sessionWith(count: 2, correctAnswers: 2),
        theme: arabe,
        level: level1,
        catalog: catalog,
      );
      expect(result.persisted, isFalse);
      expect(result.failureCode, 'STATE-WRITE');
      expect(harness.logger.hasCode('STATE-WRITE'), isTrue);
    });

    test('n\'écrit pas si l\'état est inchangé (REQ-043)', () async {
      final harness = await build(
        initialState: AppState(
          score: 0,
          progress: <ThemeId, Set<LevelNumber>>{
            arabe: <LevelNumber>{level1, level2},
          },
        ),
      );

      final result = await harness.useCase(
        session: sessionWith(count: 2, correctAnswers: 0),
        theme: arabe,
        level: level1,
        catalog: catalog,
      );

      expect(result.score, 0);
      expect(result.unlock, isA<AlreadyUnlocked>());
      expect(harness.store.writeCount, 0, reason: 'aucune écriture inutile');
    });

    test('noNextLevel sur le dernier niveau : seule la progression du score change', () async {
      final harness = await build(
        initialState: AppState(
          progress: <ThemeId, Set<LevelNumber>>{
            arabe: <LevelNumber>{level1, level2},
          },
        ),
      );

      final result = await harness.useCase(
        session: sessionWith(count: 2, correctAnswers: 2),
        theme: arabe,
        level: level2,
        catalog: catalog,
      );

      expect(result.unlock, isA<NoNextLevel>());
      expect(result.persisted, isTrue);
      expect(harness.store.writeCount, 1);
    });

    test('notEligible si le niveau n\'était pas déverrouillé', () async {
      final harness = await build();
      final result = await harness.useCase(
        session: sessionWith(count: 2, correctAnswers: 2),
        theme: arabe,
        level: level2,
        catalog: catalog,
      );
      expect(result.unlock, isA<NotEligible>());
    });
  });
}
