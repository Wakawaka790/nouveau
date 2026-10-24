# SPEC-TESTS-001 — Spécification des Tests de Composant, d'Intégration et d'Ensemble

| | |
|---|---|
| **Référence** | SPEC-TESTS-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §6.1.4.4 (exigences génériques), §7.2.4.16, §7.3.4.29, §7.5.4.5, §7.7.4.1 ; Tableaux A.5, A.6, A.7, A.13, A.14, A.21 |
| **Niveau** | SIL 2 |
| **Entrées** | SRS-001, ARCH-001, DD-001 |
| **Rôle responsable** | Chargé des tests (doit être distinct du Réalisateur — §5.1.2.11 f) |
| **Sortie associée** | RAP-TESTS-001 (rapport d'exécution) |

---

## 1. Objet et stratégie

### 1.1 Objet

Spécifier **avant exécution** l'ensemble des tests : cas de composant (TC-DOM,
TC-INF, TC-APP), d'intégration (TC-INT), d'ensemble (TC-SYS), d'accessibilité
(TC-PRS) et d'architecture (TC-ARCH). Chaque cas est univoque : identifiant
stable, précondition, entrée, résultat attendu, exigence couverte.

### 1.2 Techniques retenues (SIL 2)

| Tableau | Technique | SIL 2 | Application |
|---|---|---|---|
| A.13 #1 | Valeurs aux limites | **HR** | Bornes 1/2 options, 1/99 niveaux, 0/1 s, 8 Ko, 0/10⁹ points |
| A.13 #5 | Classes d'équivalence | R | Entrées valides / invalides / hors domaine |
| A.13 #2 | Supposition d'erreurs | R | JSON tronqué, CRC faux, types inattendus, panne d'écriture |
| A.14 #3 | Valeurs aux limites (boîte noire) | **HR** | Parcours d'interface |
| A.14 #4 | Classes d'équivalence (boîte noire) | **HR** | Contenu valide / absent / invalide |
| A.21 #1 | Couverture des instructions | **HR** | Seuil 100 % sur `domain` et `application` |
| A.21 #2 | Couverture des branchements | R | Seuil 100 % sur `domain` |
| A.6 #1 | Tests fonctionnels d'intégration | **HR** | TC-INT-01..10 |
| A.7 #2 | Tests fonctionnels d'ensemble | **HR** | TC-SYS-01..12 |
| A.18 #2 | Temps de réponse | R | TC-SYS-13, TC-INT-09, TC-HW-01 |

### 1.3 Environnements d'exécution

| Environnement | Usage | Cas |
|---|---|---|
| **E1 — Dart VM (sans émulateur)** | Domaine, application, infrastructure sur doublures | TC-DOM, TC-APP, TC-INF, TC-ARCH |
| **E2 — Flutter test (widget)** | Widgets et écrans avec dépendances injectées | TC-PRS |
| **E3 — Appareil Android réel** | Intégration logiciel/matériel, performance, accessibilité | TC-SYS, TC-HW |

**Propriété clé** : 100 % des exigences C1 (SRS-001) sont vérifiables en E1. Le
recours à l'émulateur n'est **jamais** nécessaire pour valider une règle métier.

### 1.4 Correspondance avec le code livré

Les cas TC-DOM, TC-INF, TC-APP et TC-ARCH sont **implémentés** dans `test/` et
exécutés par `flutter test` (`.github/workflows/ci.yml`). Les cas TC-SYS et
TC-HW nécessitent un appareil et sont **spécifiés mais non automatisés** ici.

---

## 2. Tests de composant — domaine (E1)

| ID | Objet | Précondition | Entrée | Résultat attendu | Exigence |
|---|---|---|---|---|---|
| **TC-DOM-01** | ThemeId valide | — | `"  Arabe "` | `value == "arabe"` | REQ-006 |
| **TC-DOM-02** | ThemeId invalide (7 classes) | — | `""`, `"  "`, `"a b"`, `"a/b"`, `"../etc"`, `"é"`, 33 caractères | `InvalidThemeIdError` | REQ-006 |
| **TC-DOM-03** | LevelNumber aux bornes | — | `1`, `"99"` | accepté | REQ-003 |
| **TC-DOM-04** | LevelNumber hors limites | — | `0`, `100`, `-1`, `"1.5"`, `"abc"`, `null`, `1.0` | `InvalidLevelNumberError` | REQ-003 |
| **TC-DOM-05** | Question à 2 options (borne basse) | — | `"  Q "`, `" B "`, `["B","C"]` | champs `trim`és | REQ-005 |
| **TC-DOM-06** | Une seule option | — | `options = ["A"]` | `InvalidQuestionError` | REQ-005 |
| **TC-DOM-07** | Énoncé / bonne réponse vide | — | `""`, `"   "` | `InvalidQuestionError` | REQ-005 |
| **TC-DOM-08** | Option vide ou dupliquée | — | `["A"," "]`, `["A","B"," A "]` | `InvalidQuestionError` | REQ-005 |
| **TC-DOM-09** | Bonne réponse absente | — | `correct = "Z"`, `options = ["A","B"]` | `InvalidQuestionError`, message `question 5` si `index = 4` | REQ-005 |
| **TC-DOM-10** | Catalogue trié | — | `[3,1,2]` | `[1,2,3]` | REQ-003 |
| **TC-DOM-11** | Catalogue avec doublon | — | `[1,1]` | `InvalidCatalogError` | REQ-003 |
| **TC-DOM-12** | Catalogue sans niveau 1 | — | `[2]` | `InvalidCatalogError` | REQ-003 |
| **TC-DOM-13** | Successeur = niveau du catalogue | — | catalogue `[1,3]`, `next(1)` | `3` (et non `2`) | REQ-012 |
| **TC-DOM-14** | Session vide | — | `questions = []` | `InvalidSessionError` | REQ-030 |
| **TC-DOM-15** | Durée nulle / négative (hors debug) | — | `Duration.zero`, `-1 s` | `InvalidDurationError` | REQ-030 |
| **TC-DOM-16** | Initialisation | — | 3 questions | `index 0`, `answers = [null,null,null]` | REQ-036 |
| **TC-DOM-17** | Séquence complète | — | 3 réponses | `finished`, `index == 3` | REQ-031 |
| **TC-DOM-18** | Réponse en retard ignorée | — | réponse sur index 0 après passage à 1 | aucune écriture | REQ-033 |
| **TC-DOM-19** | Option hors proposition | — | `option = "Z"` | `InvalidAnswerError`, état inchangé | REQ-032 |
| **TC-DOM-20** | Opérations après la fin | — | `answer`, `expireIfDue` après `finished` | sans effet | REQ-036 |
| **TC-DOM-21** | Temps restant = fonction de l'horloge | — | `now = 1000/4000/11000` | `10000/7000/0` | REQ-034 |
| **TC-DOM-22** | Temps restant borné | — | `now` antérieur au début | `perQuestionMs` | REQ-034 |
| **TC-DOM-23** | Expiration à l'échéance | — | `now = deadline - 1`, puis `deadline` | `false` puis `true`, réponse `null` | REQ-035 |
| **TC-DOM-24** | Arrière-plan long (60 s) | — | `expireIfDue(60000)` | expire, aucune réponse gagnée | REQ-037 |
| **TC-DOM-25** | Expiration de la dernière question | — | 1 question, `now ≥ deadline` | `finished` | REQ-035 |
| **TC-DOM-26** | Nouvelle question = durée pleine | — | réponse à 1,5 s | `remaining(1500) == 10000` | REQ-034 |
| **TC-DOM-27** | Score 0 / partiel / total | — | `[null,null,null]`, `["B","b","A"]`, `["B","B","B"]` | `0`, `1`, `3` | REQ-021 |
| **TC-DOM-28** | Incohérence de longueur | — | 3 questions, 2 réponses | `hasLengthMismatch == true`, score 2 | REQ-021 |
| **TC-DOM-29** | Liste vide | — | `[]`, `[]` | `accuracy == 0` (pas de division par zéro) | REQ-024 |
| **TC-DOM-30** | Comparaison stricte | — | `"Rabat"` vs `"rabat"`, `"Rabat "` | faux | REQ-021 |
| **TC-DOM-31** | Déblocage nominal | catalogue `[1,2,3,5]`, terminé 3, débloqués `{1,2,3}` | — | `NewlyUnlocked(5)` | REQ-012 |
| **TC-DOM-32** | Déjà débloqué | débloqués `{1,2}`, terminé 1 | — | `AlreadyUnlocked(2)` | REQ-013 |
| **TC-DOM-33** | Dernier niveau | terminé 5 | — | `NoNextLevel` | REQ-012 |
| **TC-DOM-34** | Niveau non déverrouillé | débloqués `{1}`, terminé 3 | — | `NotEligible('LEVEL-NOT-UNLOCKED')` | REQ-014 |
| **TC-DOM-35** | Niveau hors catalogue | terminé 4 | — | `NotEligible('LEVEL-NOT-IN-CATALOG')` | REQ-014 |
| **TC-DOM-36** | Catalogue de thèmes livré | — | — | 8 thèmes, identifiants `{arabe, sira, coran, histoire, sahaba, hijra, terme, general}` | REQ-001 |
| **TC-DOM-37** | Libellés et descriptions renseignés | — | — | aucun libellé vide (8 thèmes) | REQ-002 |
| **TC-DOM-38** | Liste de référence immuable | `quizThemes.add(...)` | — | `UnsupportedError` | REQ-002, RC-09 |
| **TC-DOM-39** | Résolution d'un thème livré | `themeForId('coran')` | — | `QuizTheme(label: 'Coran')` | REQ-001 |
| **TC-DOM-40** | Résolution d'un thème absent | `themeForId('inconnu')` | — | `null` | REQ-001 |

## 3. Tests de composant — infrastructure (E1)

| ID | Objet | Entrée | Résultat attendu | Exigence |
|---|---|---|---|---|
| **TC-INF-01** | Catalogue valide | `[3,1,2]` | `[1,2,3]` | REQ-001 |
| **TC-INF-02** | Clé `levels` minuscule | `{"levels":[1]}` | accepté | REQ-002 |
| **TC-INF-03** | Fichier absent | asset inexistant | `ContentNotFoundError` | REQ-008 |
| **TC-INF-04** | JSON illisible | `{oops` | `ContentParseError` | REQ-008 |
| **TC-INF-05** | Schéma invalide | `{}`, `{"Levels":"1,2"}`, `[]` | `ContentSchemaError` | REQ-002 |
| **TC-INF-06** | Catalogue incohérent | `[1,1,2]`, `[2,3]`, `[0,1]` | `ContentSchemaError` | REQ-003 |
| **TC-INF-07** | Niveau vide / non liste | `[]`, `{"q":1}` | `EmptyLevelError`, `ContentSchemaError` | REQ-004 |
| **TC-INF-08** | Question invalide indexée | 2ᵉ question avec bonne réponse absente | message `question 2` | REQ-005 |
| **TC-INF-09** | Alias de clés | `arabe`, `correctAnswer` | accepté | REQ-005 |
| **TC-INF-10** | CRC-32 vecteur de référence | `"123456789"` | `cbf43926` | REQ-040 |
| **TC-INF-11** | Aller-retour d'état | état non trivial | état identique | REQ-040 |
| **TC-INF-12** | CRC non concordant | `score` modifié | `CorruptedStateError` | REQ-041 |
| **TC-INF-13** | Enveloppe invalide | version 2, champs absents, `[]`, `"texte"` | `CorruptedStateError` | REQ-041 |
| **TC-INF-14** | Types et bornes | `score = -5`, `"42"`, `150` comme niveau | `CorruptedStateError` | REQ-041 |
| **TC-INF-15** | Document trop volumineux | > 8 Ko | `CorruptedStateError` | REQ-041 |
| **TC-INF-16** | Sérialisation canonique | état avec 2 thèmes | pas d'espace, clés triées | REQ-040 |
| **TC-INF-17** | Repli silencieux et journalisé | état corrompu en base | état par défaut + `STATE-CORRUPTED` | REQ-041 |
| **TC-INF-18** | Échec d'écriture | panne simulée | `StateWriteError` | REQ-044 |
| **TC-INF-19** | Migration non destructive | clés v7 présentes | fusion, suppression **après** écriture | REQ-015 |
| **TC-INF-20** | Migration, écriture en échec | panne simulée | clés héritées **conservées** | REQ-015 |

## 4. Tests de composant — application (E1)

| ID | Objet | Entrée | Résultat attendu | Exigence |
|---|---|---|---|---|
| **TC-APP-01** | Fin de session : cumul + déblocage | score 10, session 2/3 | score 12, `NewlyUnlocked(2)`, **1 écriture** | REQ-022 |
| **TC-APP-02** | Score 0 débloque quand même | session 0/2 | `NewlyUnlocked`, persisted | REQ-012 (H3) |
| **TC-APP-03** | Échec d'écriture | panne | `persisted = false`, code `STATE-WRITE` | REQ-044 |
| **TC-APP-04** | Aucune écriture si état inchangé | déjà `{1,2}`, score 0 | `writeCount == 0`, `AlreadyUnlocked` | REQ-043 |
| **TC-APP-05** | Dernier niveau | niveau 2/2, débloqués `{1,2}` | `NoNextLevel`, 1 écriture (score) | REQ-012 |
| **TC-APP-06** | Niveau non éligible | niveau 2 non débloqué | `NotEligible` | REQ-014 |
| **TC-APP-07** | Mélange reproductible | graine fixée | ordre identique sur 2 exécutions | REQ-007 |
| **TC-APP-08** | Mélange effectif | 10 options | ordre ≠ ordre source (au moins une fois sur 10) | REQ-007 |
| **TC-APP-09** | Reset progression | `{1,2,3}` | `{1}` en une écriture | REQ-016 |
| **TC-APP-10** | Reset score | score 120, progression `{1,2}` | score 0, progression **inchangée** | REQ-023 |

## 5. Tests d'intégration (E1/E2) — voir aussi ARCH-001 §7.2

| ID | Composants | Résultat attendu | Exigence |
|---|---|---|---|
| **TC-INT-01** | APP-02 + INF-01 | session 10 questions, ordre conforme à la graine | REQ-004, REQ-007 |
| **TC-INT-02** | APP-01 + INF-04 | migration `levels__Terme` fusionnée puis supprimée | REQ-015 |
| **TC-INT-03** | APP-04 + INF-04 | une seule écriture, score et progression cohérents | REQ-022 |
| **TC-INT-04** | APP-04 + LOG | `persisted = false`, journal `STATE-WRITE`, pas de bandeau de succès | REQ-044 |
| **TC-INT-05** | INF-02/03/04 | CRC invalide → repli + `STATE-CRC-MISMATCH`/`STATE-CORRUPTED` | REQ-041 |
| **TC-INT-06** | APP-01 + INF-01 + PRS-02 | `Failure(CONTENT-NOT-FOUND)` + « Réessayer » | REQ-060 |
| **TC-INT-07** | APP-03 + APP-04 + DOM-05 | score 0, session terminée, résultat affichable | REQ-035 |
| **TC-INT-08** | APP-04 + DOM-07 | `AlreadyUnlocked`, aucune écriture | REQ-013 |
| **TC-INT-09** | Tous + horloge réelle | changement de question ≤ 100 ms, dérive ≤ 50 ms/10 s | REQ-070 |
| **TC-INT-10** | APP-06/07 + PRS-05 | score 0, progression conservée | REQ-023 |

## 6. Tests d'ensemble (E2/E3)

| ID | Scénario | Résultat attendu | Exigence |
|---|---|---|---|
| **TC-SYS-01** | Démarrage → 8 thèmes affichés | grille 2 colonnes < 700 dp | REQ-061 |
| **TC-SYS-02** | Thème → carte des niveaux, niveau 1 seul débloqué | compteur `1 / 2` | REQ-010, REQ-017 |
| **TC-SYS-03** | Niveau 1 verrouillé → appui | aucune navigation | REQ-062 |
| **TC-SYS-04** | Partie complète 3/3 | résultat `3 / 3`, `NewlyUnlocked(2)` | REQ-064 |
| **TC-SYS-05** | Partie 0/3 | résultat `0 / 3`, niveau 2 débloqué (H3) | REQ-012 |
| **TC-SYS-06** | Abandon en cours de partie | aucun enregistrement (H5) | REQ-038 |
| **TC-SYS-07** | Expiration sur la dernière question | résultat affiché, score inchangé | REQ-035 |
| **TC-SYS-08** | Réinitialisation de progression annulée | état inchangé | REQ-065 |
| **TC-SYS-09** | Réinitialisation de progression confirmée | `1 / 2` niveaux, niveau 2 verrouillé | REQ-016 |
| **TC-SYS-10** | Remise à zéro du score | `0 points`, bouton masqué | REQ-023 |
| **TC-SYS-11** | Relance de l'application | score et progression conservés | REQ-040 |
| **TC-SYS-12** | Contenu absent pour un thème | message + « Réessayer » | REQ-060 |
| **TC-SYS-13** | Démarrage à froid | ≤ 2 s | REQ-070 |
| **TC-SYS-14** | 50 questions enchaînées | aucune fuite mémoire, ≤ 120 Mo | REQ-071 |
| **TC-SYS-15** | Rotation portrait/paysage en session | état conservé, chrono continu | REQ-076 |
| **TC-SYS-16** | Arrière-plan 5 s puis retour | temps restant −5 s | REQ-037 |
| **TC-SYS-17** | Persistance corrompue au démarrage | application utilisable, score 0 | REQ-041 |
| **TC-SYS-18** | TalkBack activé | tous les éléments annoncés | REQ-067 |
| **TC-SYS-19** | Contraste et cibles tactiles | ≥ 4,5:1, ≥ 48 dp | REQ-067 |
| **TC-SYS-20** | Aucune permission réseau | manifeste sans `INTERNET` | REQ-077 |

## 7. Tests de widgets (E2)

| ID | Objet | Résultat attendu | Exigence |
|---|---|---|---|
| **TC-PRS-01** | `QuizBoard` affiche énoncé, options, compteur, temps | 4 assertions | REQ-063 |
| **TC-PRS-02** | Appui sur une option | callback avec la bonne valeur | REQ-032 |
| **TC-PRS-03** | Le temps suit l'horloge (avance de 4 s) | affichage `6 s` | REQ-034 |
| **TC-PRS-04** | Sélection : 8 thèmes | 8 libellés | REQ-061 |
| **TC-PRS-05** | Sélection → carte des niveaux | `LevelMapScreen`, `1 / 2` | REQ-060 |
| **TC-PRS-06** | Contenu absent | message + « Réessayer » | REQ-060 |
| **TC-PRS-07** | Niveau verrouillé | libellé et `enabled == false` | REQ-062 |
| **TC-PRS-08** | Aucune chaîne technique affichée | aucun `Error`/`Exception` dans l'arbre | REQ-051 |

## 8. Tests d'architecture (E1) — analyse statique

| ID | Objet | Résultat attendu | Exigence |
|---|---|---|---|
| **TC-ARCH-01** | `domain` n'importe ni Flutter, ni plugin, ni `dart:io`, ni `dart:math` | aucune violation | REQ-074 |
| **TC-ARCH-02** | `domain` n'importe aucune autre couche ; `application` n'importe ni Flutter ni l'infrastructure | aucune violation | REQ-074 |
| **TC-ARCH-03** | `presentation` n'importe l'infrastructure que dans la racine de composition | aucune violation | ADR-01 |
| **TC-ARCH-04** | Aucun fichier > 200 lignes | conforme | REQ-073 |
| **TC-ARCH-05** | Aucun `assert(` de validation, aucun `print(`, aucun `static var/late` | conforme | RC-12, RC-14, RC-10 |
| **TC-ARCH-06** | Un seul point d'entrée | 1 `main` | ANO-05 |

## 9. Critères d'arrêt

| Critère | Seuil |
|---|---|
| Tests spécifiés exécutés | 100 % |
| Tests réussis | 100 % (aucun échec toléré sur C1) |
| Couverture `domain` + `application` | 100 % des instructions, 100 % des branchements |
| Couverture `infrastructure` | ≥ 90 % des instructions |
| Anomalies ouvertes de gravité B ou M | 0 |
| Traçabilité | 100 % des REQ couvertes par ≥ 1 cas |

**Fin du document — SPEC-TESTS-001 v1.0**
