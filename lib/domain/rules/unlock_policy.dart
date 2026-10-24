import '../entities/level_catalog.dart';
import '../values/level_number.dart';

/// Issue d'une décision de déverrouillage (REQ-013).
sealed class UnlockOutcome {
  const UnlockOutcome();
}

/// Le niveau [level] vient d'être déverrouillé : l'IHM peut l'annoncer.
final class NewlyUnlocked extends UnlockOutcome {
  const NewlyUnlocked(this.level);

  final LevelNumber level;
}

/// [level] était déjà déverrouillé : aucune écriture, aucune annonce.
final class AlreadyUnlocked extends UnlockOutcome {
  const AlreadyUnlocked(this.level);

  final LevelNumber level;
}

/// Aucun niveau supérieur n'est configuré.
final class NoNextLevel extends UnlockOutcome {
  const NoNextLevel();
}

/// Le déverrouillage n'est pas permis ; [reason] est un code de diagnostic.
final class NotEligible extends UnlockOutcome {
  const NotEligible(this.reason);

  final String reason;
}

abstract final class UnlockPolicy {
  /// Décide du déverrouillage après achèvement de [completed] (REQ-012/014).
  static UnlockOutcome decide({
    required LevelCatalog catalog,
    required LevelNumber completed,
    required Set<LevelNumber> unlocked,
  }) {
    if (!catalog.contains(completed)) {
      return const NotEligible('LEVEL-NOT-IN-CATALOG');
    }
    if (!unlocked.contains(completed)) {
      return const NotEligible('LEVEL-NOT-UNLOCKED');
    }
    final next = catalog.next(completed);
    if (next == null) {
      return const NoNextLevel();
    }
    if (unlocked.contains(next)) {
      return AlreadyUnlocked(next);
    }
    return NewlyUnlocked(next);
  }
}
