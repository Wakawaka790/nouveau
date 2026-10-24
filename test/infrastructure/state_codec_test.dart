import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/application/ports/state_repository.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';
import 'package:quiz_game/infrastructure/storage/crc32.dart';
import 'package:quiz_game/infrastructure/storage/state_codec.dart';

void main() {
  final arabe = ThemeId.parse('arabe');
  final sira = ThemeId.parse('sira');

  final sample = AppState(
    score: 42,
    progress: <ThemeId, Set<LevelNumber>>{
      arabe: <LevelNumber>{
        LevelNumber.parse(1),
        LevelNumber.parse(2),
      },
      sira: <LevelNumber>{LevelNumber.parse(1)},
    },
  );

  group('Crc32 (REQ-040)', () {
    test('vecteur de référence IEEE 802.3', () {
      expect(Crc32.hex(utf8.encode('123456789')), 'cbf43926');
    });

    test('déterministe et sensible à un octet près', () {
      final first = Crc32.hex(utf8.encode('{"a":1}'));
      expect(Crc32.hex(utf8.encode('{"a":1}')), first);
      expect(Crc32.hex(utf8.encode('{"a":2}')), isNot(first));
    });
  });

  group('StateCodec (REQ-040)', () {
    test('aller-retour sans perte', () {
      final decoded = StateCodec.decode(StateCodec.encode(sample));
      expect(decoded, sample);
      expect(decoded.score, 42);
      expect(decoded.progress[arabe]?.length, 2);
    });

    test('état vide : aller-retour et score par défaut', () {
      final decoded = StateCodec.decode(StateCodec.encode(const AppState()));
      expect(decoded, const AppState());
      expect(decoded.score, 0);
    });

    test('sérialisation canonique : clés triées, pas d\'espace', () {
      final encoded = StateCodec.encode(sample);
      expect(encoded.contains(' '), isFalse);
      final dataIndex = encoded.indexOf('"data"');
      final scoreIndex = encoded.indexOf('"score"');
      expect(dataIndex < scoreIndex, isTrue, reason: 'clés de data triées');
    });

    test('refuse un document dont le CRC ne concorde pas', () {
      final encoded = StateCodec.encode(sample);
      final tampered = encoded.replaceFirst('"score":42', '"score":43');
      expect(
        () => StateCodec.decode(tampered),
        throwsA(isA<CorruptedStateError>()),
      );
    });

    test('refuse un JSON illisible', () {
      expect(
        () => StateCodec.decode('{ceci n\'est pas du json'),
        throwsA(isA<CorruptedStateError>()),
      );
    });

    test('refuse une version inconnue', () {
      expect(
        () => StateCodec.decode('{"v":2,"crc":"00000000","data":{}}'),
        throwsA(isA<CorruptedStateError>()),
      );
    });

    test('refuse une enveloppe incomplète', () {
      for (final raw in <String>[
        '{"v":1,"data":{}}',
        '{"v":1,"crc":"00000000"}',
        '[]',
        '"texte"',
      ]) {
        expect(
          () => StateCodec.decode(raw),
          throwsA(isA<CorruptedStateError>()),
          reason: 'entrée: $raw',
        );
      }
    });

    test('refuse un score négatif ou non entier', () {
      for (final value in <String>['-5', '"42"', '1.5', 'null']) {
        final data = '{"progress":{},"score":$value}';
        final crc = Crc32.hex(utf8.encode(data));
        final document = '{"v":1,"crc":"$crc","data":$data}';
        expect(
          () => StateCodec.decode(document),
          throwsA(isA<CorruptedStateError>()),
          reason: 'score: $value',
        );
      }
    });

    test('refuse un niveau hors bornes dans la progression', () {
      final data = '{"progress":{"arabe":[1,150]},"score":0}';
      final crc = Crc32.hex(utf8.encode(data));
      expect(
        () => StateCodec.decode('{"v":1,"crc":"$crc","data":$data}'),
        throwsA(isA<CorruptedStateError>()),
      );
    });

    test('refuse un document trop volumineux', () {
      final oversized = List<String>.filled(
        StateCodec.maxDocumentBytes + 1,
        'x',
      ).join();
      expect(
        () => StateCodec.decode(oversized),
        throwsA(isA<CorruptedStateError>()),
      );
    });
  });
}
