/// Niveaux de journalisation (REQ-052).
enum LogLevel { debug, info, warning, error }

/// Port de journalisation, remplaçable en test par une doublure.
abstract interface class Logger {
  void log(LogLevel level, String code, String detail);
}
