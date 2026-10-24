import '../errors/domain_errors.dart';

/// Numéro de niveau validé, borné à [1, 99] (REQ-003).
final class LevelNumber implements Comparable<LevelNumber> {
  const LevelNumber._(this.value);

  static const int minValue = 1;
  static const int maxValue = 99;
  static const LevelNumber one = LevelNumber._(1);

  final int value;

  factory LevelNumber.parse(Object? raw) {
    final int? parsed;
    if (raw is int) {
      parsed = raw;
    } else if (raw is String) {
      parsed = int.tryParse(raw.trim());
    } else {
      parsed = null;
    }
    if (parsed == null || parsed < minValue || parsed > maxValue) {
      throw InvalidLevelNumberError(raw);
    }
    return LevelNumber._(parsed);
  }

  @override
  int compareTo(LevelNumber other) => value.compareTo(other.value);

  @override
  bool operator ==(Object other) => other is LevelNumber && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => '$value';
}
