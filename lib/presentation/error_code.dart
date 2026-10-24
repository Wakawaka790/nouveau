import '../domain/errors/domain_errors.dart';

/// Code d'erreur affichable, jamais un message technique (REQ-051).
String errorCodeOf(Object error) => error is AppError ? error.code : 'UNKNOWN';
