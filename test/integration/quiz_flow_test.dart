import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/application/finish_quiz_session.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/rules/unlock_policy.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';
import 'package:quiz_game/infrastructure/storage/prefs_state_repository.dart';
import 'package:quiz_game/presentation/app_dependencies.dart';
import 'package:quiz_game/presentation/error_code.dart';

import '../support/fakes.dart';

/// TC-INT-01 à TC-INT-08 — assemblage **réel** des composants.
///
/// Seuls les périphériques sont doublés (assets, stockage, horloge, aléa) : le
/// domaine, les cas d'usage et les implémentations d'infrastructure sont ceux
/// livrés. Ces tests sont donc les seuls qui exercent le câblage complet.

/// Banc d'essai : dépendances câblées + doubles observables.
final class Harness {
  Harness(this.deps, this.store, this.logger, this.clock);

  final AppDependencies deps;
  final InMemoryStore store;
  final RecordingLogger logger;
  final FakeClock clock;
}

void main() {
  final arabe = ThemeId.parse('arabe');

  Map<String, String> content() => <String, String>{
        'assets/questions/arabe/levels.json': '{"Levels":[1,2]}',
        'assets/questions/arabe/level_1.json': levelJson(2),
        'assets/questions/arabe/level_2.json': levelJson(1),
      };

  Harness build({
    Map<String, String>? files,
    InMemoryStore? store,
    List<int>? random,
  }) {
    final logger = RecordingLogger();
    final clock = FakeClock();
    final inMemory = store ?? InMemoryStore();
    final deps = AppDependencies.create(
      store: inMemory,
      reader: FakeAssetReader(files ?? content()),
      clock: clock,
      random: FakeRandom(random),
      logger: logger,
      perQuestion: const Duration(seconds: 10),
    );
    return Harness(deps, inMemory, logger, clock);
  }

  Future<FinishResult> playAll(
    Harness harness, {
    bool correct = true,
  }) async {
    final view = await harness.deps.loadLevelMap(arabe);
    final session = await harness.deps.startQuizSession(
      theme: arabe,
      level: LevelNumber.one,
    );
    while (!session.isFinished) {
      final question = session.currentQuestion;
      final option = correct
          ? question.correctAnswer
          : question.options.firstWhere(
              (String candidate) => candidate != question.correctAnswer,
            );
      harness.deps.answerQuestion(
        session,
        questionIndex: session.index,
        option: option,
      );
    }
    return harness.deps.finishQuizSession(
      session: session,
      theme: arabe,
      level: LevelNumber.one,
      catalog: view.catalog,
    );
  }

  test('TC-INT-01 : session construite depuis les assets, ordre selon la graine',
      () async {
    final first = build(random: <int>[1, 0, 2]);
    final second = build(random: <int>[1, 0, 2]);
    final sessionA = await first.deps.startQuizSession(
      theme: arabe,
      level: LevelNumber.one,
    );
    final sessionB = await second.deps.startQuizSession(
      theme: arabe,
      level: LevelNumber.one,
    );
    expect(sessionA.questions, hasLength(2));
    for (var i = 0; i < sessionA.questions.length; i++) {
      expect(
        sessionA.questions[i].options,
        sessionB.questions[i].options,
        reason: 'même graine = même ordre (REQ-007, REQ-078)',
      );
    }
  });

  test('TC-INT-02 : les clés héritées sont migrées puis supprimées (REQ-015)',
      () async {
    final legacy = InMemoryStore(<String, String>{'levels__Arabe': '[1,2]'});
    final harness = build(store: legacy);
    final view = await harness.deps.loadLevelMap(arabe);

    expect(view.isUnlocked(LevelNumber.parse(2)), isTrue);
    expect(legacy.snapshot.containsKey('levels__Arabe'), isFalse);
    expect(
      legacy.snapshot.containsKey(PrefsStateRepository.stateKey),
      isTrue,
      reason: 'l\'état migré est écrit avant suppression',
    );
  });

  test('TC-INT-03 : une seule écriture pour un parcours complet (REQ-022)',
      () async {
    final harness = build();
    final result = await playAll(harness);

    expect(result.score, 2);
    expect(result.total, 2);
    expect(result.persisted, isTrue);
    expect(harness.store.writeCount, 1, reason: 'transaction unique');

    final after = await harness.deps.loadLevelMap(arabe);
    expect(after.isUnlocked(LevelNumber.parse(2)), isTrue);
    expect(await harness.deps.readTotalScore(), 2);
  });

  test('TC-INT-04 : échec d\'écriture signalé, journalisé, résultat conservé',
      () async {
    final harness = build();
    harness.store.failOnWrite = true;
    final result = await playAll(harness);

    expect(result.persisted, isFalse);
    expect(result.failureCode, 'STATE-WRITE');
    expect(result.score, 2, reason: 'le score affiché reste exact');
    expect(harness.logger.hasCode('STATE-WRITE'), isTrue);
  });

  test('TC-INT-05 : état corrompu remplacé par l\'état par défaut (REQ-041)',
      () async {
    final corrupted = InMemoryStore(<String, String>{
      PrefsStateRepository.stateKey: '{"v":1,"crc":"deadbeef","data":{}}',
    });
    final harness = build(store: corrupted);
    final view = await harness.deps.loadLevelMap(arabe);

    expect(view.unlocked, <LevelNumber>{LevelNumber.one});
    expect(await harness.deps.readTotalScore(), 0);
    expect(harness.logger.hasCode('STATE-CORRUPTED'), isTrue);
  });

  test('TC-INT-06 : contenu absent → code d\'erreur affichable (REQ-060)',
      () async {
    final harness = build(files: <String, String>{});
    try {
      await harness.deps.loadLevelMap(arabe);
      fail('une erreur de contenu était attendue');
    } on Object catch (error) {
      expect(error, isA<ContentNotFoundError>());
      expect(errorCodeOf(error), 'CONTENT-NOT-FOUND');
    }
  });

  test('TC-INT-07 : expiration totale → score nul, session terminée (REQ-035)',
      () async {
    final harness = build();
    final view = await harness.deps.loadLevelMap(arabe);
    final session = await harness.deps.startQuizSession(
      theme: arabe,
      level: LevelNumber.one,
    );
    while (!session.isFinished) {
      harness.clock.advance(const Duration(seconds: 10));
      harness.deps.answerQuestion.expireIfDue(session);
    }
    expect(session.answers.every((String? a) => a == null), isTrue);

    final result = await harness.deps.finishQuizSession(
      session: session,
      theme: arabe,
      level: LevelNumber.one,
      catalog: view.catalog,
    );
    expect(result.score, 0);
    expect(result.total, 2);
    expect(result.persisted, isTrue);
  });

  test('TC-INT-08 : niveau déjà déverrouillé et score nul → aucune écriture',
      () async {
    final harness = build();
    final result = await playAll(harness, correct: false);

    expect(result.unlock, isA<AlreadyUnlocked>());
    expect(result.score, 0);
    expect(result.persisted, isTrue);
    expect(
      harness.store.writeCount,
      0,
      reason: 'état inchangé : inutile d\'écrire (REQ-013, REQ-044)',
    );
  });
}
