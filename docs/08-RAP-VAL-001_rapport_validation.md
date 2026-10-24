# RAP-VAL-001 — Plan et Rapport de Validation du Logiciel

| | |
|---|---|
| **Référence** | RAP-VAL-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §6.3.4.7 à 6.3.4.11 (rapport), §7.7.4.6 à 7.7.4.11 ; Tableau A.7 |
| **Niveau** | SIL 2 |
| **Rôle responsable** | Chargé de validation — distinct du Gestionnaire des exigences, du Concepteur, du Réalisateur, du Chargé d'intégration et du Chargé des tests (§5.1.2.11 h) |

---

## 1. Statut

> ⚠️ **La validation n'a pas été effectuée.** Ce document contient le **plan de
> validation** (critères, scénarios, environnement) et le **rapport** à l'état
> « non exécuté ». Il ne peut en aucun cas être présenté comme une preuve de
> validation (§7.7.4.10).
>
> Le rôle de Chargé de validation n'est pas nommé : l'exigence §5.1.2.8 (accord
> formel sur toute version diffusée) **n'est pas satisfaite** (C-03, C-05).

---

## 2. Objectif de la validation

Démontrer que le logiciel, **dans son environnement réel**, répond aux besoins de
l'utilisateur — et non seulement à sa spécification (§3.1.47 de la norme :
« adéquation de son fonctionnement selon son objectif dans son environnement
prévu »).

Différence avec la vérification : la vérification demande « a-t-on construit le
logiciel correctement ? » ; la validation demande « a-t-on construit le bon
logiciel ? ». Les scénarios ci-dessous sont donc **orientés utilisateur**, non
orientés exigence.

---

## 3. Environnement de validation

| Élément | Valeur |
|---|---|
| Appareil cible | Android, API ≥ 23, écran 5 à 10 pouces |
| Appareil de référence | API 30, 4 Go RAM |
| Réseau | **désactivé** (l'application ne requiert aucune connexion) |
| Données | contenu livré + une progression préexistante et une progression corrompue |
| Langue | français |
| Accessibilité | un scénario avec TalkBack activé, un avec police agrandie à 200 % |

---

## 4. Scénarios de validation (orientés utilisateur)

| ID | Scénario | Critère de succès | Résultat | Verdict |
|---|---|---|---|---|
| **VAL-01** | Un utilisateur découvre l'application sans consigne et trouve un thème à jouer | atteint l'écran de quiz en ≤ 3 interactions, sans aide | — | ☐ |
| **VAL-02** | Premier lancement : un seul niveau accessible, compréhension immédiate du verrouillage | aucun utilisateur-testeur ne signale de confusion | — | ☐ |
| **VAL-03** | Partie complète : 10 questions en 10 s chacune | fin de partie sans blocage ni perte de réponse | — | ☐ |
| **VAL-04** | Partie avec interruptions : appel entrant, retour au bout de 30 s | le temps restant reflète la réalité ; aucune triche possible | — | ☐ |
| **VAL-05** | Progression : terminer le niveau 1, relancer l'application | niveau 2 toujours accessible, score conservé | — | ☐ |
| **VAL-06** | Échec de contenu : un thème dont le JSON est retiré | message compréhensible, application stable, autres thèmes utilisables | — | ☐ |
| **VAL-07** | Données corrompues : document d'état altéré avant lancement | application démarre, score à 0, message si pertinent | — | ☐ |
| **VAL-08** | Réinitialisation : progression puis score | double confirmation, effets conformes, aucune perte inattendue | — | ☐ |
| **VAL-09** | Accessibilité : TalkBack + police 200 % | toutes les actions réalisables, aucune information tronquée | — | ☐ |
| **VAL-10** | Utilisation 30 min : 15 parties enchaînées | aucune dégradation, mémoire stable, pas de plantage | — | ☐ |

**Tests supplémentaires à la discrétion du Chargé de validation (§7.7.4.3)** :
scénarios non couverts par la spécification, notamment l'usage en classe
(plusieurs élèves sur un même appareil), l'interruption par une notification, et
le comportement à 0 % de batterie pendant une écriture.

---

## 5. Critères d'acceptation de la validation

| Critère | Seuil |
|---|---|
| Scénarios VAL exécutés | 100 % |
| Scénarios réussis | 100 % (tout échec sur VAL-03, VAL-05, VAL-07 est bloquant) |
| Anomalies bloquantes détectées | 0 ouverte |
| Anomalies majeures détectées | 0 ouverte ou dérogation documentée |
| Accord formel du Chargé de validation (§5.1.2.8) | Signé |

---

## 6. Rapport de validation — contenu exigé (§7.7.4.10) et état

| Élément exigé | Contenu | État |
|---|---|---|
| a) identité et configuration du logiciel | Version 2.0.0+20 ; commit de référence ; `pubspec.lock` | À renseigner au moment de la validation |
| b) logiciels et équipements de support | Flutter 3.29.2, Dart 3.x, Android SDK 34, Java 17 | **Identifiés** |
| c) modèles de simulation utilisés | Aucun (pas de simulation : appareil réel) | **Sans objet** |
| d) résultats des tests de validation | Tableau §4 | **Vide — non exécuté** |
| e) anomalies et leur traitement | À alimenter | **Vide** |
| f) conclusions et restrictions d'emploi | À alimenter | **Vide** |

---

## 7. Conclusion

| | |
|---|---|
| **Statut** | **NON VALIDÉ** |
| **Motif** | Validation non exécutée ; Chargé de validation non nommé ; contenu pédagogique non revu (V-07) |
| **Condition de levée** | Exécution des scénarios VAL-01..10 sur appareil réel, revue du contenu par une autorité pédagogique, signature du Chargé de validation |

**Fin du document — RAP-VAL-001 v1.0**
