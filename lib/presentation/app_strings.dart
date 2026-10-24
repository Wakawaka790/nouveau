/// Catalogue des messages destinés à l'utilisateur (REQ-051, REQ-066).
///
/// Aucune chaîne d'interface ne doit être écrite en dur dans un widget : toutes
/// passent par cette classe, ce qui prépare la localisation (REQ-080) et évite
/// l'exposition de messages techniques (ANO-14).
abstract final class AppStrings {
  static const String appTitle = 'Quiz éducatif';
  static const String themeSelectionTitle = 'Choisissez un thème';
  static const String themeSelectionSubtitle = 'Apprenez en jouant, à votre rythme.';
  static const String scoresTooltip = 'Voir les scores';

  static const String levelMapTitle = 'Niveaux';
  static const String levelMapInstruction = 'Choisissez un niveau pour le thème « %s ».';
  static const String levelUnlockedHint = 'Touchez pour jouer';
  static const String levelLockedHint = 'Terminez le niveau précédent';
  static const String levelLabel = 'Niveau %d';
  static const String quizTitle = '%s — niveau %d';
  static const String levelTitle = 'Niveau'; 
  static const String levelCount = '%d / %d niveaux débloqués';
  static const String resetProgressTooltip = 'Réinitialiser la progression';
  static const String resetProgressTitle = 'Réinitialiser la progression ?';
  static const String resetProgressBody =
      'Les niveaux débloqués pour « %s » seront remis à zéro.';
  static const String cancel = 'Annuler';
  static const String reset = 'Réinitialiser';
  static const String retry = 'Réessayer';
  static const String emptyLevels = 'Aucun niveau n’est configuré pour ce thème.';

  static const String questionCounter = 'Question %d sur %d';
  static const String scoreLabel = 'Score : %d';
  static const String secondsShort = '%d s';
  static const String remainingTimeSemantics = 'Temps restant';
  static const String progressSemantics = 'Progression dans le niveau';
  static const String scoreSemantics = 'Score courant';
  static const String noAnswer = 'Aucune réponse';

  static const String resultTitle = 'Résultat du quiz';
  static const String resultScore = '%d / %d';
  static const String resultSubtitle = '%s — niveau %d';
  static const String levelUnlockedBanner = 'Niveau %d débloqué !';
  static const String persistenceWarning =
      'Votre résultat n’a pas pu être enregistré. Il sera perdu à la fermeture.';
  static const String yourAnswer = 'Votre réponse : %s';
  static const String correctAnswer = 'Bonne réponse : %s';
  static const String backToLevels = 'Retour aux niveaux';

  static const String scoresTitle = 'Votre score';
  static const String scoresPoints = '%d points';
  static const String resetScoreLabel = 'Réinitialiser le score';
  static const String resetScoreTitle = 'Effacer le score ?';
  static const String resetScoreBody = 'Cette action remettra votre score total à zéro.';
  static const String erase = 'Effacer';

  static const String loading = 'Chargement…';

  /// Message utilisateur associé à un code d'erreur (REQ-051).
  ///
  /// Aucun code inconnu ne doit produire un message technique : le repli est
  /// volontairement générique.
  static String forErrorCode(String code) => switch (code) {
        'CONTENT-NOT-FOUND' => 'Le contenu de ce thème est introuvable.',
        'CONTENT-PARSE' => 'Le contenu de ce thème est illisible.',
        'CONTENT-SCHEMA' => 'Le contenu de ce thème est mal formé.',
        'CONTENT-EMPTY' => 'Ce niveau ne contient aucune question.',
        'DOM-THEME-001' => 'Ce thème n’existe pas.',
        'DOM-LEVEL-001' => 'Ce niveau n’existe pas.',
        'DOM-QUESTION-001' => 'Une question de ce niveau est invalide.',
        'DOM-CATALOG-001' => 'La liste des niveaux de ce thème est invalide.',
        'DOM-SESSION-001' => 'La partie ne peut pas continuer.',
        'DOM-DURATION-001' => 'La durée de la partie est invalide.',
        'DOM-ANSWER-001' => 'Cette réponse n’est pas proposée.',
        'STATE-CORRUPTED' => 'Vos données ont été réinitialisées.',
        'STATE-WRITE' => 'L’enregistrement a échoué.',
        _ => 'Une erreur inattendue est survenue.',
      };
}
