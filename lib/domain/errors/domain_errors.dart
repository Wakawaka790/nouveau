/// Taxonomie fermée des erreurs applicatives (REQ-050).
///
/// Chaque erreur porte :
///  * [code]  : identifiant stable, utilisé par le catalogue de messages de
///              l'interface (REQ-051). Jamais affiché brut à l'utilisateur.
///  * [detail]: information technique, destinée au journal uniquement (REQ-052).
sealed class AppError implements Exception {
  const AppError(this.code, this.detail);

  final String code;
  final String detail;

  @override
  String toString() => '$code: $detail';
}

/// Erreurs métier : entrée invalide, invariants violés.
sealed class DomainError extends AppError {
  const DomainError(super.code, super.detail);
}

final class InvalidThemeIdError extends DomainError {
  InvalidThemeIdError(Object? raw)
      : super('DOM-THEME-001', 'identifiant de thème invalide: "$raw"');
}

final class InvalidLevelNumberError extends DomainError {
  InvalidLevelNumberError(Object? raw)
      : super('DOM-LEVEL-001', 'numéro de niveau invalide: "$raw"');
}

final class InvalidDurationError extends DomainError {
  const InvalidDurationError(int ms)
      : super('DOM-DURATION-001', 'durée par question invalide: $ms ms');
}

final class InvalidAnswerError extends DomainError {
  InvalidAnswerError(String option)
      : super('DOM-ANSWER-001', 'réponse hors options: "$option"');
}

final class InvalidQuestionError extends DomainError {
  InvalidQuestionError(int index, String reason)
      : super('DOM-QUESTION-001', 'question ${index + 1}: $reason');
}

final class InvalidSessionError extends DomainError {
  const InvalidSessionError(String reason) : super('DOM-SESSION-001', reason);
}

final class InvalidCatalogError extends DomainError {
  const InvalidCatalogError(String reason) : super('DOM-CATALOG-001', reason);
}

/// Erreurs de contenu (données d'application, §8.4).
sealed class ContentError extends AppError {
  const ContentError(super.code, super.detail);
}

final class ContentNotFoundError extends ContentError {
  ContentNotFoundError(this.path) : super('CONTENT-NOT-FOUND', 'asset absent: $path');

  final String path;
}

final class ContentParseError extends ContentError {
  ContentParseError(this.path, String reason)
      : super('CONTENT-PARSE', 'JSON invalide dans $path: $reason');

  final String path;
}

final class ContentSchemaError extends ContentError {
  ContentSchemaError(this.path, String reason)
      : super('CONTENT-SCHEMA', 'schéma invalide dans $path: $reason');

  final String path;
}

final class EmptyLevelError extends ContentError {
  EmptyLevelError(this.path) : super('CONTENT-EMPTY', 'aucune question dans $path');

  final String path;
}

/// Erreurs de persistance (REQ-040 à REQ-044).
sealed class StateStoreError extends AppError {
  const StateStoreError(super.code, super.detail);
}

final class CorruptedStateError extends StateStoreError {
  const CorruptedStateError(String reason)
      : super('STATE-CORRUPTED', 'état persistant invalide: $reason');
}

final class StateWriteError extends StateStoreError {
  const StateWriteError(super.detail) : super('STATE-WRITE', 'écriture impossible');
}
