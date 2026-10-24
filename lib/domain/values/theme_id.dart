import '../errors/domain_errors.dart';

/// Identifiant de thème validé (REQ-006).
///
/// Toute instance existante est valide : la validation est faite à la
/// construction (défense en profondeur, Tableau A.3 #1).
final class ThemeId {
  const ThemeId._(this.value);

  static final RegExp _pattern = RegExp(r'^[a-z0-9_-]{1,32}$');

  final String value;

  factory ThemeId.parse(String raw) {
    final normalized = raw.trim().toLowerCase();
    if (!_pattern.hasMatch(normalized)) {
      throw InvalidThemeIdError(raw);
    }
    return ThemeId._(normalized);
  }

  @override
  bool operator ==(Object other) => other is ThemeId && other.value == value;

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => value;
}
