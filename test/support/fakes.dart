import 'dart:async';

import 'package:quiz_game/application/ports/clock.dart';
import 'package:quiz_game/application/ports/logger.dart';
import 'package:quiz_game/application/ports/random_source.dart';
import 'package:quiz_game/domain/entities/question.dart';
import 'package:quiz_game/infrastructure/content/asset_reader.dart';
import 'package:quiz_game/infrastructure/storage/key_value_store.dart';

/// Horloge pilotable par le test (déterminisme, REQ-078).
final class FakeClock implements Clock {
  int current = 0;

  @override
  int nowMs() => current;

  void advance(Duration duration) => current += duration.inMilliseconds;
}

/// Aléa déterministe : séquence fournie par le test.
final class FakeRandom implements RandomSource {
  FakeRandom([List<int>? sequence]) : _sequence = sequence ?? const <int>[];

  final List<int> _sequence;
  int _cursor = 0;

  @override
  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'doit être positif');
    }
    if (_sequence.isEmpty) {
      return 0;
    }
    final value = _sequence[_cursor % _sequence.length];
    _cursor++;
    return value % max;
  }
}

/// Journal enregistreur, pour vérifier les codes d'erreur (REQ-052).
final class RecordingLogger implements Logger {
  final List<String> entries = <String>[];
  final List<String> codes = <String>[];

  @override
  void log(LogLevel level, String code, String detail) {
    entries.add('${level.name}:$code:$detail');
    codes.add(code);
  }

  bool hasCode(String code) => codes.contains(code);
}

/// Stockage en mémoire, avec injection de panne d'écriture (REQ-044).
final class InMemoryStore implements KeyValueStore {
  InMemoryStore([Map<String, String>? initial])
      : _values = <String, String>{...?initial};

  final Map<String, String> _values;
  bool failOnWrite = false;
  int writeCount = 0;
  Completer<void>? writeGate;

  Map<String, String> get snapshot => Map<String, String>.unmodifiable(_values);

  @override
  String? getString(String key) => _values[key];

  @override
  Future<void> setString(String key, String value) async {
    if (writeGate != null) {
      await writeGate!.future;
    }
    if (failOnWrite) {
      throw StateError('panne simulée');
    }
    writeCount++;
    _values[key] = value;
  }

  @override
  Future<void> remove(String key) async {
    _values.remove(key);
  }

  @override
  Set<String> keys() => _values.keys.toSet();
}

/// Lecteur d'assets alimenté par une table chemin → contenu.
final class FakeAssetReader implements AssetReader {
  FakeAssetReader(this.files);

  final Map<String, String> files;
  final List<String> reads = <String>[];

  @override
  Future<String> read(String path) async {
    reads.add(path);
    final content = files[path];
    if (content == null) {
      throw StateError('asset introuvable: $path');
    }
    return content;
  }
}

/// Question de test valide.
Question question(String text, {String correct = 'B', List<String>? options}) =>
    Question.create(
      text: text,
      correctAnswer: correct,
      options: options ?? <String>['A', correct, 'C'],
    );

/// Contenu JSON d'un niveau de test.
String levelJson(int count) {
  final buffer = StringBuffer('[');
  for (var i = 0; i < count; i++) {
    if (i > 0) {
      buffer.write(',');
    }
    buffer.write('{"question":"Q$i","correct":"B","options":["A","B","C"]}');
  }
  buffer.write(']');
  return buffer.toString();
}
