import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/application/ports/state_repository.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';
import 'package:quiz_game/infrastructure/storage/prefs_state_repository.dart';
import 'package:quiz_game/infrastructure/storage/state_codec.dart';

import '../support/fakes.dart';

void main() {
  final arabe = ThemeId.parse('arabe');
  final terme = ThemeId.parse('terme');

  PrefsStateRepository repository(InMemoryStore store, RecordingLogger logger) =>
      PrefsStateRepository(store: store, logger: logger);

  group('Lecture (REQ-041)', () {
    test('état par défaut quand aucune donnée', () async {
      final state = await repository(InMemoryStore(), RecordingLogger()).load();
      expect(state, const AppState());
      expect(state.score, 0);
    });

    test('repli silencieux et journalisé si le document est corrompu', () async {
      final store = InMemoryStore(<String, String>{
        PrefsStateRepository.stateKey: '{"v":1,"crc":"deadbeef","data":{}}',
      });
      final logger = RecordingLogger();
      final state = await repository(store, logger).load();
      expect(state, const AppState());
      expect(logger.hasCode('STATE-CORRUPTED'), isTrue);
    });

    test('erreur de type inattendu dans le stockage : repli, pas de crash', () async {
      final store = InMemoryStore(<String, String>{
        PrefsStateRepository.stateKey: 'null',
      });
      final state = await repository(store, RecordingLogger()).load();
      expect(state, const AppState());
    });
  });

  group('Écriture (REQ-042 à REQ-044)', () {
    test('écrit puis relit le même état', () async {
      final store = InMemoryStore();
      final repo = repository(store, RecordingLogger());
      final state = AppState(
        score: 12,
        progress: <ThemeId, Set<LevelNumber>>{
          arabe: <LevelNumber>{LevelNumber.parse(1), LevelNumber.parse(2)},
        },
      );
      await repo.save(state);
      expect(await repo.load(), state);
      expect(store.snapshot.keys, <String>[PrefsStateRepository.stateKey]);
    });

    test('remonte une erreur typée en cas d\'échec d\'écriture (REQ-044)', () async {
      final store = InMemoryStore()..failOnWrite = true;
      await expectLater(
        repository(store, RecordingLogger()).save(const AppState(score: 3)),
        throwsA(isA<StateWriteError>()),
      );
    });

    test('sérialise les écritures concurrentes (REQ-042)', () async {
      final store = InMemoryStore();
      final repo = repository(store, RecordingLogger());
      store.writeGate = Completer<void>();
      final first = repo.save(const AppState(score: 1));
      final second = repo.save(const AppState(score: 2));
      store.writeGate!.complete();
      store.writeGate = null;
      await Future.wait<void>(<Future<void>>[first, second]);
      final reloaded = await repo.load();
      expect(reloaded.score, 2, reason: 'la dernière écriture gagne, sans corruption');
    });
  });

  group('Migration des clés héritées (REQ-015)', () {
    test('fusionne les clés v7 puis les supprime', () async {
      final store = InMemoryStore(<String, String>{
        'levels__arabe': '["1","2"]',
        'levels__Terme': '[1,3]',
        'total_score': '99',
      });
      final logger = RecordingLogger();
      final repo = repository(store, logger);

      final state = await repo.load();

      expect(state.progress[arabe], isNotNull);
      expect(state.progress[arabe]?.length, 2);
      expect(state.progress[terme]?.length, 2, reason: 'clé capitalisée fusionnée');
      expect(store.snapshot.containsKey('levels__arabe'), isFalse);
      expect(store.snapshot.containsKey('levels__Terme'), isFalse);
      expect(store.snapshot.containsKey(PrefsStateRepository.stateKey), isTrue);
      expect(logger.hasCode('MIGRATION-DONE'), isTrue);
    });

    test('ignore les niveaux invalides en les journalisant (REQ-011)', () async {
      final store = InMemoryStore(<String, String>{
        'levels__arabe': '["1","x","150","2"]',
      });
      final logger = RecordingLogger();
      final state = await repository(store, logger).load();
      expect(state.progress[arabe]?.length, 2);
      expect(logger.hasCode('MIGRATION-LEVEL-IGNORED'), isTrue);
    });

    test('conserve les clés héritées si l\'écriture échoue (non destructif)', () async {
      final store = InMemoryStore(<String, String>{'levels__arabe': '["1"]'})
        ..failOnWrite = true;
      final repo = repository(store, RecordingLogger());
      await expectLater(repo.load(), throwsA(isA<StateWriteError>()));
      expect(store.snapshot.containsKey('levels__arabe'), isTrue);
    });

    test('le document migré est relisible sans migration supplémentaire', () async {
      final store = InMemoryStore(<String, String>{'levels__arabe': '["1","4"]'});
      final repo = repository(store, RecordingLogger());
      final first = await repo.load();
      final second = await repo.load();
      expect(second, first);
      expect(store.snapshot.containsKey('levels__arabe'), isFalse);
    });
  });

  group('Idempotence (REQ-043)', () {
    test('n\'écrit pas un état identique — vérifié par le cas d\'usage', () {
      // Le dépôt écrit ce qu'on lui demande ; c'est FinishQuizSession qui
      // compare avant d'écrire (voir test/application/finish_quiz_session_test).
      expect(StateCodec.encode(const AppState()), isNotEmpty);
    });
  });
}
