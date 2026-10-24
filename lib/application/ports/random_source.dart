/// Source d'aléa injectée (REQ-007, REQ-078).
abstract interface class RandomSource {
  /// Entier uniformément distribué dans `[0, max)` ; `max` doit être > 0.
  int nextInt(int max);
}
