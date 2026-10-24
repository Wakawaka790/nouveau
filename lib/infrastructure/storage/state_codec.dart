import 'dart:convert';

import '../../domain/errors/domain_errors.dart';
import '../../domain/values/level_number.dart';
import '../../domain/values/theme_id.dart';
import '../../application/ports/state_repository.dart';
import 'crc32.dart';

/// Sérialisation de [AppState] dans une enveloppe versionnée et contrôlée.
///
/// Format (REQ-040) :
/// `{"v":1,"crc":"<8 hex>","data":{"progress":{...},"score":N}}`
/// Le CRC est calculé sur la forme canonique de `data` : clés triées, sans
/// espace, encodage UTF-8 (REQ-040).
abstract final class StateCodec {
  static const int currentVersion = 1;
  static const int maxDocumentBytes = 8 * 1024;

  static String encode(AppState state) {
    final data = <String, Object?>{
      'score': state.score,
      'progress': <String, Object?>{
        for (final entry in state.progress.entries)
          entry.key.value: (entry.value.map((level) => level.value).toList()
            ..sort()),
      },
    };
    final canonical = canonicalJson(data);
    final envelope = <String, Object?>{
      'v': currentVersion,
      'crc': Crc32.hex(utf8.encode(canonical)),
      'data': data,
    };
    return canonicalJson(envelope);
  }

  /// Décode et valide ; lève [CorruptedStateError] en cas d'anomalie.
  static AppState decode(String raw) {
    if (raw.length > maxDocumentBytes) {
      throw const CorruptedStateError('document trop volumineux');
    }
    final Object? decoded;
    try {
      decoded = jsonDecode(raw);
    } on FormatException catch (error) {
      throw CorruptedStateError('JSON illisible (${error.message})');
    }
    if (decoded is! Map<String, Object?>) {
      throw const CorruptedStateError('enveloppe non objet');
    }
    final version = decoded['v'];
    if (version != currentVersion) {
      throw CorruptedStateError('version inconnue: $version');
    }
    final data = decoded['data'];
    final crc = decoded['crc'];
    if (data is! Map<String, Object?> || crc is! String) {
      throw const CorruptedStateError('enveloppe incomplète');
    }
    final computed = Crc32.hex(utf8.encode(canonicalJson(data)));
    if (computed != crc) {
      throw const CorruptedStateError('CRC non concordant');
    }
    return _decodeData(data);
  }

  static AppState _decodeData(Map<String, Object?> data) {
    final rawScore = data['score'];
    if (rawScore is! int || rawScore < 0 || rawScore > 1000000000) {
      throw CorruptedStateError('score invalide: $rawScore');
    }
    final rawProgress = data['progress'];
    if (rawProgress is! Map<String, Object?>) {
      throw const CorruptedStateError('progression non objet');
    }
    final progress = <ThemeId, Set<LevelNumber>>{};
    for (final entry in rawProgress.entries) {
      final levels = entry.value;
      if (levels is! List<Object?>) {
        throw CorruptedStateError('progression de "${entry.key}" non liste');
      }
      final parsed = <LevelNumber>{};
      for (final level in levels) {
        try {
          parsed.add(LevelNumber.parse(level));
        } on DomainError {
          throw CorruptedStateError('niveau invalide: $level');
        }
      }
      progress[ThemeId.parse(entry.key)] = parsed;
    }
    return AppState(score: rawScore, progress: progress);
  }

  /// JSON canonique : clés triées récursivement, aucun espace superflu.
  static String canonicalJson(Object? value) {
    if (value is Map<String, Object?> || value is Map) {
      final entries = <MapEntry<String, Object?>>[];
      for (final entry in (value as Map).entries) {
        entries.add(MapEntry(entry.key.toString(), entry.value));
      }
      entries.sort((left, right) => left.key.compareTo(right.key));
      final buffer = StringBuffer('{');
      for (var i = 0; i < entries.length; i++) {
        if (i > 0) {
          buffer.write(',');
        }
        buffer
          ..write(jsonEncode(entries[i].key))
          ..write(':')
          ..write(canonicalJson(entries[i].value));
      }
      buffer.write('}');
      return buffer.toString();
    }
    if (value is List) {
      final parts = value.map(canonicalJson).join(',');
      return '[$parts]';
    }
    return jsonEncode(value);
  }
}
