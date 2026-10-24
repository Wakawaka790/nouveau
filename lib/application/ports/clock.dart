/// Source de temps monotone, injectée (REQ-034, REQ-074).
abstract interface class Clock {
  /// Millisecondes écoulées depuis une origine arbitraire, jamais décroissantes.
  int nowMs();
}
