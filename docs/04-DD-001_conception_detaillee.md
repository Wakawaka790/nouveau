# DD-001 — Spécification de la Conception du Logiciel et des Composants

| | |
|---|---|
| **Référence** | DD-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §7.3.4.20 à 7.3.4.28 ; Tableau A.4 ; Tableau A.12 |
| **Niveau** | SIL 2 |
| **Entrées** | SRS-001 v1.0, ARCH-001 v1.0, STD-COD-001 |
| **Sorties couvertes** | Tableau A.1 #10 (Conception), #15 (Conception de composant), #16 (Tests de composant → SPEC-TESTS-001), #17 (Rapport de vérification → RAP-VER-001 §3) |

---

## 1. Objet

Décrire, pour chaque composant de ARCH-001, sa **conception interne** : structures
de données, algorithmes, séquencement, mécanismes de compte-rendu d'erreur
(§7.3.4.23 f et g). Chaque description est traçable vers une exigence du SRS et
vers les tests de composant correspondants.

---

## 2. Conception du domaine

### 2.1 `ThemeId` (CMP-DOM-01) — REQ-006

| Rubrique | Contenu |
|---|---|
| **Structure** | Un champ `value` (String), constructeur privé. |
| **Algorithme** | `trim()` → `toLowerCase()` → correspondance `^[a-z0-9_-]{1,32}$`. |
| **Erreur** | `InvalidThemeIdError` (code `DOM-THEME-001`) portant la valeur brute **en détail**, jamais en message utilisateur. |
| **Justification** | Ferme la porte à l'injection de chemin (`../`, `/`) avant tout accès aux assets ou au stockage (ANO-02 de la v7 : `quizType` venait de l'IHM sans validation). |
| **Tests** | TC-DOM-01, TC-DOM-02 |

### 2.2 `LevelNumber` (CMP-DOM-02) — REQ-003

| Rubrique | Contenu |
|---|---|
| **Structure** | Champ `value` (int), bornes statiques `minValue = 1`, `maxValue = 99`. |
| **Algorithme** | Accepte `int` ou `String` convertible ; rejette `bool`, `double`, `null`, hors bornes. |
| **Erreur** | `InvalidLevelNumberError` (`DOM-LEVEL-001`). |
| **Justification** | La v7 utilisait `int.parse` sur des chaînes persistées sans borne : une valeur `150` serait devenue un chemin d'asset invalide (ANO-07). |
| **Tests** | TC-DOM-03, TC-DOM-04 |

### 2.3 `Question` (CMP-DOM-03) — REQ-005

| Rubrique | Contenu |
|---|---|
| **Structure** | `text`, `correctAnswer`, `options` (liste non modifiable). |
| **Algorithme** | `trim` sur les trois champs, puis 6 contrôles dans l'ordre : énoncé non vide → bonne réponse non vide → ≥ 2 options → aucune option vide → aucune option dupliquée → bonne réponse présente. |
| **Séquencement** | L'ordre des contrôles est **normatif** : il détermine le message d'erreur renvoyé. Un test par contrôle (TC-DOM-05..09). |
| **Erreur** | `InvalidQuestionError(index, reason)` — l'index est celui de la question dans le fichier, affiché en base 1. |
| **Invariants** | Aucune instance ne peut exister sans satisfaire les 6 conditions. |
| **Tests** | TC-DOM-05..09 |

### 2.4 `LevelCatalog` (CMP-DOM-04) — REQ-003, REQ-017

| Rubrique | Contenu |
|---|---|
| **Structure** | `theme`, `_levels` (liste triée non modifiable). |
| **Algorithme** | Tri croissant → contrôle de doublon (comparaison avec le prédécesseur) → contrôle du premier élément = 1. |
| **`next(current)`** | `indexOf(current)` ; `-1` → `null` ; dernier → `null` ; sinon `levels[index + 1]`. **Le successeur est celui du catalogue, pas `current + 1`** (correction d'un cas non traité en v7 : catalogue `[1, 3]`). |
| **Tests** | TC-DOM-10..13 |

### 2.5 `QuizSession` (CMP-DOM-05) — REQ-030 à REQ-038

**Structure**

| Champ | Type | Invariant |
|---|---|---|
| `questions` | `List<Question>` non modifiable | non vide |
| `perQuestionMs` | `int` | `> 0` |
| `_answers` | `List<String?>` de même longueur | `null` = non traitée |
| `_status` | `SessionAnswering(index, deadlineMs)` \| `SessionFinished` | exhaustif |

**Machine à états** (ARCH-001 §4.3). Transitions et gardes :

| Opération | Garde | Effet |
|---|---|---|
| `start` | questions non vide ∧ durée > 0 | `answering(0, now + perQuestion)` |
| `answer(index, option)` | `status is answering` ∧ `index == status.index` ∧ `option ∈ options` | `_record(index, option)` |
| `answer(...)` (index périmé) | `index != status.index` | **aucun effet** (double appui, ANO v7) |
| `answer(...)` (option inconnue) | `option ∉ options` | lève `InvalidAnswerError`, état inchangé |
| `expireIfDue(now)` | `now ≥ deadline` | `_record(index, null)` |
| `_record(i, v)` | `answers[i]` déjà non nul | **aucun effet** (idempotence, REQ-033) |
| `_record(i, v)` | `i == n-1` | `finished` |
| `_record(i, v)` | sinon | `answering(i+1, now + perQuestion)` |

**Algorithme du chronomètre (REQ-034)** — décision de conception majeure :

```
remaining(now) = clamp(deadline - now, 0, perQuestionMs)
```

Aucun compteur n'est décrémenté : la dérive est **structurellement impossible**
et une mise en arrière-plan ne peut pas « offrir » de temps (ANO-10/ANO-11 de la
v7). L'interface rafraîchit l'affichage à 200 ms ; ce rafraîchissement n'a
**aucun effet** sur la mesure.

**Erreurs** : `InvalidSessionError` (`DOM-SESSION-001`), `InvalidDurationError`
(`DOM-DURATION-001`), `InvalidAnswerError` (`DOM-ANSWER-001`).

**Tests** : TC-DOM-14..26.

### 2.6 `ScoringRules` (CMP-DOM-06) — REQ-021, REQ-024

| Rubrique | Contenu |
|---|---|
| **Algorithme** | Boucle `i < min(len(questions), len(answers))` ; incrément si `questions[i].isCorrect(answers[i])`. |
| **Diagnostic** | `hasLengthMismatch` vaut vrai si les longueurs diffèrent : l'appelant **doit** journaliser (ANO-13 : la v7 tronquait en silence). |
| **Accuracy** | `total == 0 ? 0 : score / total` — pas de division par zéro. |
| **Tests** | TC-DOM-27..30 |

### 2.7 `UnlockPolicy` (CMP-DOM-07) — REQ-012 à REQ-014

| Ordre | Condition | Résultat |
|---|---|---|
| 1 | niveau terminé absent du catalogue | `NotEligible('LEVEL-NOT-IN-CATALOG')` |
| 2 | niveau terminé non déverrouillé | `NotEligible('LEVEL-NOT-UNLOCKED')` |
| 3 | aucun successeur au catalogue | `NoNextLevel` |
| 4 | successeur déjà déverrouillé | `AlreadyUnlocked(next)` |
| 5 | sinon | `NewlyUnlocked(next)` |

Cet ordre est **normatif** : il garantit qu'aucune écriture n'a lieu dans les cas
1, 2 et 4 (REQ-043) et que l'IHM n'annonce un déverrouillage que dans le cas 5
(ANO-09 de la v7, où l'écran de résultat affichait « Niveau X débloqué ! » même
si X l'était déjà).

**Tests** : TC-DOM-31..35.

### 2.8 Taxonomie d'erreurs (CMP-DOM-08) — REQ-050

```
AppError (scellé, Exception)
├── DomainError (scellé)
│   ├── InvalidThemeIdError        DOM-THEME-001
│   ├── InvalidLevelNumberError    DOM-LEVEL-001
│   ├── InvalidDurationError       DOM-DURATION-001
│   ├── InvalidAnswerError         DOM-ANSWER-001
│   ├── InvalidQuestionError       DOM-QUESTION-001
│   ├── InvalidSessionError        DOM-SESSION-001
│   └── InvalidCatalogError        DOM-CATALOG-001
├── ContentError (scellé)
│   ├── ContentNotFoundError       CONTENT-NOT-FOUND
│   ├── ContentParseError          CONTENT-PARSE
│   ├── ContentSchemaError         CONTENT-SCHEMA
│   └── EmptyLevelError            CONTENT-EMPTY
└── StateStoreError (scellé)
    ├── CorruptedStateError        STATE-CORRUPTED
    └── StateWriteError            STATE-WRITE
```

Chaque erreur porte `code` (stable, utilisé par `AppStrings.forErrorCode`) et
`detail` (technique, journal uniquement). Le `switch` de `AppStrings` est
exhaustif par code, avec repli générique pour tout code inconnu.

### 2.9 `QuizTheme` et catalogue de thèmes (CMP-DOM-09) — REQ-001, REQ-002

```
QuizTheme { id: ThemeId, label: String, description: String }
quizThemes : List<QuizTheme> non modifiable  // 8 entrées livrées
themeForId(id: ThemeId) -> QuizTheme?        // résolution linéaire, null si absent
```

| Décision | Motif |
|---|---|
| Thèmes en **donnée de référence compilée**, pas en asset | la liste est une propriété du logiciel (REQ-002) ; un asset corrompu ne peut pas vider l'écran d'accueil |
| `List.unmodifiable` | RC-09 : une donnée de référence ne doit pas être altérée à l'exécution ; toute tentative lève `UnsupportedError` (test TC-DOM-38) |
| `themeForId` renvoie `null` plutôt que de lever | l'appelant décide du repli ; une entrée inconnue ne doit pas interrompre l'affichage |
| L'icône n'est pas dans le domaine | le domaine ignore Flutter (RC-15) ; la présentation choisit l'icône à partir de l'identifiant |
| Aucune traduction | les libellés sont en français, langue unique du logiciel (SRS-001 §2.3) |

**Couverture** : TC-DOM-36 à TC-DOM-40 (5 cas) — liste, complétude des libellés,
immuabilité, résolution, absence.

---

## 3. Conception de l'application

### 3.1 `LoadLevelMap` (CMP-APP-01)

```
catalog ← questionRepository.loadCatalog(theme)   // peut lever ContentError
state   ← stateRepository.load()                   // ne lève jamais
retourne LevelMapView(catalog, state.unlockedFor(theme))
```

`unlockedFor` **force** la présence du niveau 1 (REQ-010) : même si l'état
persisté est vide ou corrompu, le niveau 1 reste jouable.

### 3.2 `StartQuizSession` (CMP-APP-02) — REQ-007

```
questions ← repository.loadQuestions(theme, level)
pour chaque question : mélange de Fisher-Yates avec randomSource
session   ← QuizSession.start(questions, perQuestion, clock.nowMs())
```

Fisher-Yates (et non `shuffle()` non graine de la v7) garantit une distribution
uniforme **et** la reproductibilité à graine fixée (REQ-078). Le mélange porte
sur la **liste d'options**, la bonne réponse restant identifiée par valeur.

### 3.3 `AnswerQuestion` (CMP-APP-03)

Deux opérations : `call(...)` pour une réponse (retourne `accepted` ou
`ignoredStale`) et `expireIfDue(session)` pour l'expiration. Aucune décision
métier : la garde est dans `QuizSession`.

### 3.4 `FinishQuizSession` (CMP-APP-04) — REQ-022, transaction unique

```
1. calcul    ← ScoringRules.compute(session.questions, session.answers)
2. si incohérence de longueur → journal ERROR 'SCORE-LENGTH-MISMATCH'
3. état      ← stateRepository.load()
4. décision  ← UnlockPolicy.decide(catalog, level, état.unlockedFor(theme))
5. nouveau   ← état + score, + niveau si NewlyUnlocked
6. si nouveau == état → aucune écriture (REQ-043)
   sinon → une seule écriture ; échec ⇒ persisted = false + journal
7. retourne FinishResult(score, total, décision, persisted, failureCode)
```

**Point clé** : score **et** progression sont dans le **même document**, écrit
une seule fois. Il n'existe aucun état observable où le score serait enregistré
sans la progression (ANO-06 de la v7, deux écritures indépendantes).

### 3.5 `ResetLevelProgress` / `ReadTotalScore` / `ResetTotalScore`

Réinitialisation d'un thème : `progress[theme] = {1}`, écriture unique, aucune
autre clé touchée (REQ-016). Lecture du score : borne basse à 0 (REQ-020).
Remise à zéro : n'écrit que si `score != 0` (REQ-043), ne touche pas à la
progression (REQ-023).

---

## 4. Conception de l'infrastructure

### 4.1 `StateCodec` (CMP-INF-02) — REQ-040, REQ-041

| Rubrique | Contenu |
|---|---|
| **Encodage** | `data = {score, progress}` → JSON **canonique** (clés triées, sans espace) → `crc = CRC32(utf8(canonique))` → enveloppe `{v, crc, data}` sérialisée de la même façon. |
| **Décodage** | 5 contrôles dans l'ordre : taille ≤ 8 Ko → JSON lisible → objet → `v == 1` → `crc` présent et concordant → types et bornes des champs. |
| **Erreur** | `CorruptedStateError` avec motif précis (`document trop volumineux`, `CRC non concordant`, …). |
| **Choix** | La forme canonique rend le CRC **indépendant de l'ordre d'insertion** des clés dans la Map Dart, sinon un aller-retour légitime serait déclaré corrompu. |
| **Tests** | TC-INF-09..16 |

### 4.2 `PrefsStateRepository` (CMP-INF-04) — REQ-040 à REQ-044, REQ-015

| Opération | Algorithme |
|---|---|
| `load()` | clé présente → décodage protégé ; `CorruptedStateError` → journal `STATE-CORRUPTED` + état par défaut (jamais d'exception, REQ-041). Clé absente → `_migrateLegacy()`. |
| `_migrateLegacy()` | parcourt les clés `levels__*`, normalise le thème, filtre les niveaux (journal `MIGRATION-LEVEL-IGNORED`), **écrit d'abord**, puis supprime les clés héritées **seulement en cas de succès** (REQ-015, ANO-06 de la v7 où la suppression précédait l'écriture). |
| `save(state)` | mise en file : chaque écriture s'exécute après la précédente (`_queue`), y compris en cas d'échec (le `catchError` empêche le blocage de la file). |
| `_write(state)` | encodage → contrôle de taille → `store.setString` → toute exception convertie en `StateWriteError` (REQ-044). |

**Preuve d'absence d'état partiel** : le dépôt n'expose qu'une clé ; un
`setString` sur `shared_preferences` est atomique au niveau de la clé. Il n'y a
donc **aucune fenêtre** où score et progression divergeraient.

### 4.3 `AssetQuestionRepository` (CMP-INF-01) — REQ-001 à REQ-008

| Étape | Contrôle | Erreur |
|---|---|---|
| Lecture | `AssetReader.read(path)` | `ContentNotFoundError` |
| Décodage | `jsonDecode` | `ContentParseError` |
| Catalogue | objet, clé `Levels`/`levels`, liste, ≤ 99, entiers valides, tri, 1er = 1 | `ContentSchemaError` |
| Niveau | liste, non vide, ≤ 200 questions | `EmptyLevelError`, `ContentSchemaError` |
| Question | objet, alias `arabe`/`correctAnswer`, types, ≤ 10 options, ≤ 500 caractères, 6 invariants | `ContentSchemaError` avec index base 1 |

Le **chemin** est construit uniquement à partir d'un `ThemeId` validé et d'un
`LevelNumber` validé : aucune chaîne libre ne peut désigner un asset.

### 4.4 Horloge, aléa, journal

`SystemClock` : `Stopwatch` démarré à la construction (monotone, insensible aux
changements d'heure système). `SeededRandomSource` : `Random(seed)`, graine
nulle en production (non prédictible hors session), graine fixée en test.
`DebugLogger` : n'écrit qu'en `kDebugMode` ; `SilentLogger` en test.

---

## 5. Conception de la présentation

### 5.1 Règle structurante

Aucun widget ne contient de règle métier, de calcul ou d'accès direct à un
service : toute décision vient du domaine ou d'un cas d'usage. Les écrans
manipulent un `ScreenState<T>` scellé (ARCH-001 §3.4).

### 5.2 `QuizScreen` — cycle de vie et absence de contournement du temps

| Étape | Action |
|---|---|
| `initState` | enregistre l'observateur de cycle de vie, lance `_load()` |
| `_load()` | `StartQuizSession` → `ScreenReady` ou `ScreenError(code)` ; arme un rafraîchissement de 200 ms |
| `_onTick()` | `expireIfDue(session)` puis `setState` ; si terminée → `_finish()` |
| appui option | `AnswerQuestion.call(...)` ; `DomainError` → code d'erreur affiché ; si terminée → `_finish()` |
| `resumed` | `_onTick()` : l'échéance absolue suffit, aucun temps n'est ajouté |
| `_finish()` | garde d'idempotence `_isFinishing`, `FinishQuizSession`, puis `pushReplacement` vers le résultat |
| `dispose` | retire l'observateur, annule le rafraîchissement |

Le rafraîchissement de 200 ms est **purement cosmétique** : il ne mesure pas le
temps, il déclenche un repaint. Un test dédié (TC-PRS-03) vérifie que l'affichage
suit l'horloge et non le nombre de rafraîchissements.

### 5.3 Catalogue de messages (CMP-PRS-06)

`AppStrings` centralise **toutes** les chaînes (REQ-066) et la correspondance
`code d'erreur → message utilisateur` (REQ-051). Le repli est générique :
« Une erreur inattendue est survenue. » Aucun `toString()` d'exception n'atteint
l'interface.

---

## 6. Règles de codage appliquées (Tableau A.12)

| # | Règle | SIL 2 | Mise en œuvre vérifiée par |
|---|---|---|---|
| 1 | Norme de codage | M | STD-COD-001 |
| 2 | Guide de style | **HR** | `dart format`, `flutter analyze --fatal-infos` |
| 3-4 | Pas d'objets/variables dynamiques | R | `strict-casts`, `avoid_dynamic_calls` |
| 5 | Usage limité des pointeurs | R | sans objet en Dart (pas de pointeurs) |
| 6 | Récursivité limitée | R | aucune fonction récursive (revue RAP-VER-001 §4) |
| 7 | Pas de branchements inconditionnels | **HR** | aucun `goto`, aucun `break`/`continue` non motivé |
| 8 | Taille et complexité limitées | **HR** | ≤ 200 lignes/fichier, ≤ 30 lignes/fonction (test d'architecture) |
| 9 | Point d'entrée/sortie unique | R | `return` unique en fin de fonction métier |
| 9 bis | Nombre limité de paramètres | R | ≤ 4 paramètres (`deps`, `theme`, `level`, `catalog`) |
| 10 | Usage limité des variables globales | **HR** | aucun `static var` (test d'architecture) |

---

## 7. Traçabilité composant → exigence → test

| Composant | Exigences | Tests de composant |
|---|---|---|
| DOM-01/02 | REQ-003, REQ-006 | TC-DOM-01..04 |
| DOM-03 | REQ-005 | TC-DOM-05..09 |
| DOM-04 | REQ-003, REQ-017 | TC-DOM-10..13 |
| DOM-05 | REQ-030..038 | TC-DOM-14..26 |
| DOM-06 | REQ-021, REQ-024 | TC-DOM-27..30 |
| DOM-07 | REQ-012..014 | TC-DOM-31..35 |
| DOM-08 | REQ-050 | TC-INT-04, TC-ARCH-02 |
| APP-01..07 | REQ-010..044 | TC-APP-01..10 |
| INF-01 | REQ-001..008 | TC-INF-01..08 |
| INF-02/03/04 | REQ-040..044, REQ-015 | TC-INF-09..20 |
| PRS-01..11 | REQ-060..067 | TC-PRS-01..08 |

**Fin du document — DD-001 v1.0**
