import '../../application/ports/logger.dart';
import '../../application/ports/state_repository.dart';
import '../../domain/errors/domain_errors.dart';
import '../../domain/values/level_number.dart';
import '../../domain/values/theme_id.dart';
import 'key_value_store.dart';
import 'state_codec.dart';

/// Dépôt de l'état persistant : une clé unique, une écriture, un CRC.
///
/// Répond à REQ-040 à REQ-044 :
///  * encodage versionné + contrôle d'intégrité ;
///  * repli sur l'état par défaut en cas de corruption, sans exception ;
///  * écritures sérialisées par un verrou logique ;
///  * migration des clés héritées v7, non destructive (REQ-015).
final class PrefsStateRepository implements StateRepository {
  PrefsStateRepository({
    required KeyValueStore store,
    required Logger logger,
  })  : _store = store,
        _logger = logger;

  static const String stateKey = 'quizgame.state.v1';
  static const String legacyPrefix = 'levels__';

  final KeyValueStore _store;
  final Logger _logger;

  Future<void> _queue = Future<void>.value();

  @override
  Future<AppState> load() async {
    final raw = _store.getString(stateKey);
    if (raw != null) {
      return _decodeSafely(raw);
    }
    return _migrateLegacy();
  }

  AppState _decodeSafely(String raw) {
    try {
      return StateCodec.decode(raw);
    } on CorruptedStateError catch (error) {
      _logger.log(LogLevel.error, error.code, '${error.detail} — repli par défaut');
      return const AppState();
    }
  }

  /// Migration v7 → v2 : fusion des clés `levels__<theme>`, puis suppression.
  Future<AppState> _migrateLegacy() async {
    final legacyKeys = _store
        .keys()
        .where((key) => key.startsWith(legacyPrefix))
        .toList(growable: false);
    if (legacyKeys.isEmpty) {
      return const AppState();
    }

    final progress = <ThemeId, Set<LevelNumber>>{};
    for (final key in legacyKeys) {
      final theme = _themeFromLegacyKey(key);
      if (theme == null) {
        _logger.log(LogLevel.warning, 'MIGRATION-KEY-IGNORED', key);
        continue;
      }
      final levels = _levelsFromLegacyValue(_store.getString(key));
      progress[theme] = <LevelNumber>{...?progress[theme], ...levels};
    }

    final migrated = AppState(progress: progress);
    if (progress.isEmpty) {
      return const AppState();
    }

    // Écriture d'abord : la suppression n'a lieu qu'en cas de succès (REQ-015).
    await save(migrated);
    for (final key in legacyKeys) {
      await _store.remove(key);
    }
    _logger.log(
      LogLevel.info,
      'MIGRATION-DONE',
      '${legacyKeys.length} clé(s) héritée(s) migrée(s)',
    );
    return migrated;
  }

  ThemeId? _themeFromLegacyKey(String key) {
    try {
      return ThemeId.parse(key.substring(legacyPrefix.length));
    } on DomainError {
      return null;
    }
  }

  /// Seuls les entiers valides sont retenus ; le reste est journalisé (REQ-011).
  Set<LevelNumber> _levelsFromLegacyValue(String? raw) {
    if (raw == null) {
      return const <LevelNumber>{};
    }
    final levels = <LevelNumber>{};
    for (final part in raw.split(',')) {
      final trimmed = part.trim().replaceAll(RegExp(r'[\[\]"]'), '');
      if (trimmed.isEmpty) {
        continue;
      }
      final parsed = int.tryParse(trimmed);
      if (parsed == null || parsed < LevelNumber.minValue) {
        _logger.log(LogLevel.warning, 'MIGRATION-LEVEL-IGNORED', trimmed);
        continue;
      }
      if (parsed > LevelNumber.maxValue) {
        _logger.log(LogLevel.warning, 'MIGRATION-LEVEL-IGNORED', trimmed);
        continue;
      }
      levels.add(LevelNumber.parse(parsed));
    }
    return levels;
  }

  @override
  Future<void> save(AppState state) {
    // Les écritures sont sérialisées : aucune ne peut en écraser une autre
    // (REQ-042, IF-06 point g).
    final next = _queue.then((_) => _write(state));
    _queue = next.catchError((Object _) {});
    return next;
  }

  Future<void> _write(AppState state) async {
    final encoded = StateCodec.encode(state);
    if (encoded.length > StateCodec.maxDocumentBytes) {
      throw const StateWriteError('document trop volumineux');
    }
    try {
      await _store.setString(stateKey, encoded);
    } on Object catch (error) {
      _logger.log(LogLevel.error, 'STATE-WRITE', '$error');
      throw StateWriteError('$error');
    }
  }
}
