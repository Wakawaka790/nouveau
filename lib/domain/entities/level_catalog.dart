import '../errors/domain_errors.dart';
import '../values/level_number.dart';
import '../values/theme_id.dart';

/// Catalogue des niveaux configurés pour un thème (REQ-003).
///
/// Invariants : niveaux triés, sans doublon, et si non vide, premier = 1.
final class LevelCatalog {
  LevelCatalog._(this.theme, List<LevelNumber> levels)
      : _levels = List<LevelNumber>.unmodifiable(levels);

  factory LevelCatalog.create({
    required ThemeId theme,
    required List<LevelNumber> levels,
  }) {
    final sorted = <LevelNumber>[...levels]
      ..sort((left, right) => left.compareTo(right));
    for (var i = 1; i < sorted.length; i++) {
      if (sorted[i].value == sorted[i - 1].value) {
        throw InvalidCatalogError('niveau ${sorted[i].value} en double');
      }
    }
    if (sorted.isNotEmpty && sorted.first.value != LevelNumber.minValue) {
      throw const InvalidCatalogError('le premier niveau doit être le niveau 1');
    }
    return LevelCatalog._(theme, sorted);
  }

  final ThemeId theme;
  final List<LevelNumber> _levels;

  List<LevelNumber> get levels => _levels;
  int get length => _levels.length;
  bool get isEmpty => _levels.isEmpty;
  LevelNumber get first => _levels.first;
  LevelNumber get last => _levels.last;

  bool contains(LevelNumber level) => _levels.contains(level);

  /// Niveau configuré immédiatement supérieur, ou `null` (REQ-012).
  LevelNumber? next(LevelNumber current) {
    final index = _levels.indexOf(current);
    if (index < 0 || index + 1 >= _levels.length) {
      return null;
    }
    return _levels[index + 1];
  }
}
