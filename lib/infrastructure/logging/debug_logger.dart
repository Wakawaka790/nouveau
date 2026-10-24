import 'package:flutter/foundation.dart';

import '../../application/ports/logger.dart';

/// Journalise en mode debug uniquement, sans donnée personnelle (REQ-052).
final class DebugLogger implements Logger {
  const DebugLogger();

  @override
  void log(LogLevel level, String code, String detail) {
    if (kDebugMode) {
      debugPrint('[${level.name.toUpperCase()}] $code — $detail');
    }
  }
}

/// Journal muet, utilisé en test lorsque la sortie n'est pas observée.
final class SilentLogger implements Logger {
  const SilentLogger();

  @override
  void log(LogLevel level, String code, String detail) {}
}
