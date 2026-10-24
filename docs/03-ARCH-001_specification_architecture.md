# ARCH-001 — Spécification de l'Architecture du Logiciel

| | |
|---|---|
| **Référence** | ARCH-001 |
| **Version** | 1.1 |
| **Date** | 24 octobre 2026 |
| **Statut** | Soumis à revue |
| **Référentiel** | NF EN 50128:2011 §7.3.4.3 à 7.3.4.32 ; Tableaux A.3, A.4, A.22, A.23 |
| **Niveau** | SIL 2 |
| **Entrées** | SRS-001 v1.0, AN-FON-001 v1.1, STD-COD-001 |
| **Sorties couvertes** | Tableau A.1 : #9 (Architecture), #11 (Spécifications d'Interface), #12 (Tests d'Intégration Logiciel), #13 (Tests d'Intégration Logiciel/Matériel), #14 (Rapport de vérification — voir RAP-VER-001 §3) |

---

## 1. Objet et démarche

### 1.1 Objet

Décrire la **structure du logiciel** en composants, leurs **interfaces**, les
**données** échangées, les **mécanismes de gestion des défauts**, et la
**stratégie d'intégration**. Le document est tracé vers SRS-001 et sert
d'entrée à DD-001.

### 1.2 Propriétés exigées de l'architecture (§7.3.4.4)

| Propriété | Réponse apportée |
|---|---|
| Complète, cohérente, précise | 45 composants couvrant 100 % des exigences ; aucune fonction orpheline |
| Vérifiable et testable | Chaque composant a une interface explicite, testable sans IHM |
| Traçable depuis le SRS | §5.3 (matrice composant ↔ exigence) |
| Équilibre taille/complexité (§7.3.4.15) | Composant le plus gros : `state_codec.dart` 122 lignes ; fichier le plus gros : `quiz_screen.dart` 183 lignes ; aucun fichier > 200 lignes |
| Gestion des défauts (§7.3.4.11) | Défense en profondeur : validation, typage, codes de détection, repli |
| Sécurité contrôlée (§Tableau A.3 #6, R) | Repli sur état par défaut en cas de corruption, jamais de crash |

### 1.3 Décisions d'architecture (ADR)

| ID | Décision | Alternatives écartées | Justification | Réf. |
|---|---|---|---|---|
| **ADR-01** | Architecture en quatre couches : `domain` → `application` → `infrastructure` → `presentation`, dépendances orientées vers le domaine | Architecture en couches classique IHM→services→données (v7) | La v7 plaçait la logique métier dans les widgets, la rendant non testable (ANO-02) | A.3 #22, A.4 #4 |
| **ADR-02** | **Ports & adaptateurs** : horloge, aléa, contenu, état, journal sont des interfaces | Appels statiques (`SharedPreferences.getInstance()`, `rootBundle`, `Random()`) | Testabilité et déterminisme (REQ-074, REQ-078) | A.4 #7, A.3 #19 |
| **ADR-03** | **Document d'état unique** versionné + CRC-32, sous une seule clé | Deux clés séparées (`levels__*`, `total_score`) comme en v7 | Une seule écriture = pas d'état partiel score/progression (REQ-022, ANO-06) | A.3 #4 |
| **ADR-04** | **Machine à états scellée** pour la session | Booléens `_isLoading`, `_isFinishing` (v7) | États exhaustifs, transitions vérifiables (REQ-036) | A.17 #4 |
| **ADR-05** | **Échéance absolue** pour le chronomètre | Décrément par `Timer.periodic` (v7) | Supprime la dérive et le contournement par mise en arrière-plan (REQ-034, REQ-037) | A.18 #2 |
| **ADR-06** | **Erreurs scellées** + catalogue de messages indexé par code | `Exception` génériques + `error.toString()` (v7) | Messages utilisateur maîtrisés, diagnostic exploitable (REQ-050/051) | A.3 #2 |
| **ADR-07** | Flutter **uniquement** dans `presentation` et `main.dart` | Flutter partout | Domaine exécutable par `dart test` seul, sans émulateur (REQ-074) | A.4 #7 |

---

## 2. Vue d'ensemble

```
┌──────────────────────────────────────────────────────────────────────┐
│  presentation/        Flutter — 5 écrans, 4 view models, 5 widgets   │
│  ── dépend de : application (cas d'usage), domain (entités, erreurs)  │
└───────────────────────────────┬──────────────────────────────────────┘
                                │ appels de cas d'usage
┌───────────────────────────────▼──────────────────────────────────────┐
│  application/         8 cas d'usage, portent les transactions        │
│  ── dépend de : domain + ports (interfaces)                          │
└───────────────────────────────┬──────────────────────────────────────┘
                                │ implémentations injectées
┌───────────────────────────────▼──────────────────────────────────────┐
│  infrastructure/      5 adaptateurs : contenu, état, horloge,        │
│                       aléa, journal                                  │
└───────────────────────────────┬──────────────────────────────────────┘
                                │
        ┌───────────────────────┴────────────────────┐
        ▼                                            ▼
  AssetBundle (IF-05)                       SharedPreferences (IF-06)

┌──────────────────────────────────────────────────────────────────────┐
│  domain/    Dart pur — entités, value objects, règles, erreurs       │
│             AUCUNE dépendance Flutter / IO / math (vérifié en CI)    │
└──────────────────────────────────────────────────────────────────────┘
```

**Règle de dépendance** (vérifiée automatiquement par `test/architecture_test.dart`) :

| Couche | Peut importer | Ne doit jamais importer |
|---|---|---|
| `domain` | `dart:core`, `dart:collection` | `flutter/*`, `shared_preferences`, `dart:io`, `dart:math`, `application`, `infrastructure`, `presentation` |
| `application` | `domain`, ses propres ports | `flutter/*`, `infrastructure`, `presentation` |
| `infrastructure` | `domain`, `application` (ports), SDK Flutter/plugins | `presentation` |
| `presentation` | tout sauf `infrastructure` | `infrastructure` (l'injection se fait dans `main.dart`) |

---

## 3. Inventaire des composants

### 3.1 Couche domaine (9 composants)

| ID | Composant | Fichier | Responsabilité | Exigences |
|---|---|---|---|---|
| **CMP-DOM-01** | `ThemeId` | `domain/values/theme_id.dart` | Value object identifiant de thème validé (REQ-006) | REQ-001, REQ-006 |
| **CMP-DOM-02** | `LevelNumber` | `domain/values/level_number.dart` | Value object numéro de niveau (1..99) | REQ-003, REQ-011 |
| **CMP-DOM-03** | `Question` | `domain/entities/question.dart` | Entité immuable portant les 6 invariants (REQ-005) | REQ-005 |
| **CMP-DOM-04** | `LevelCatalog` | `domain/entities/level_catalog.dart` | Catalogue trié, sans doublon, commençant par 1 | REQ-003, REQ-017 |
| **CMP-DOM-05** | `QuizSession` | `domain/session/quiz_session.dart` | Machine à états de session (`SessionStatus` scellé), échéance absolue, réponses | REQ-030..038 |
| **CMP-DOM-06** | `ScoringRules` | `domain/rules/scoring_rules.dart` | Score (`ScoreComputation`), taux de réussite, diagnostic de longueur | REQ-021, REQ-024 |
| **CMP-DOM-07** | `UnlockPolicy` | `domain/rules/unlock_policy.dart` | Décision de déverrouillage (4 cas de `UnlockOutcome`) | REQ-012..014 |
| **CMP-DOM-08** | `AppError` (scellé) | `domain/errors/domain_errors.dart` | Taxonomie fermée : `DomainError`, `ContentError`, `StateStoreError` | REQ-050 |
| **CMP-DOM-09** | `QuizTheme` | `domain/entities/quiz_theme.dart` | Thème jouable (identifiant + libellé) | REQ-001, REQ-002 |

### 3.2 Couche application (6 cas d'usage + 5 ports)

| ID | Composant | Fichier | Responsabilité | Exigences |
|---|---|---|---|---|
| **CMP-APP-01** | `LoadLevelMap` (+ `LevelMapView`) | `application/load_level_map.dart` | Charge catalogue + état, calcule la vue de la carte des niveaux | REQ-010, REQ-017 |
| **CMP-APP-02** | `StartQuizSession` | `application/start_quiz_session.dart` | Charge les questions, mélange, crée la session | REQ-004, REQ-007, REQ-030 |
| **CMP-APP-03** | `AnswerQuestion` (+ `AnswerOutcome`) | `application/answer_question.dart` | Applique une réponse ou une expiration | REQ-032..035 |
| **CMP-APP-04** | `FinishQuizSession` (+ `FinishResult`) | `application/finish_quiz_session.dart` | **Transaction unique** : score + déverrouillage + écriture | REQ-021, REQ-022, REQ-044 |
| **CMP-APP-05** | `ResetLevelProgress` | `application/reset_level_progress.dart` | Remet la progression d'un thème à `{1}` | REQ-016 |
| **CMP-APP-06** | `ReadTotalScore`, `ResetTotalScore` | `application/manage_score.dart` | Lecture du score total (défaut 0) et remise à zéro | REQ-020, REQ-023 |
| **CMP-APP-07** | `AppStateRepository` (port, + `AppState`) | `application/ports/state_repository.dart` | Lecture/écriture atomique de l'état | REQ-040..044 |
| **CMP-APP-08** | `QuestionRepository` (port) | `application/ports/question_repository.dart` | Catalogue + questions | REQ-001..008 |
| **CMP-APP-09** | `Clock` (port) | `application/ports/clock.dart` | Temps monotone injecté (ms) | REQ-034, REQ-037 |
| **CMP-APP-10** | `RandomSource` (port) | `application/ports/random_source.dart` | Aléa injectable et graine | REQ-007, REQ-078 |
| **CMP-APP-11** | `Logger` (port, + `LogLevel`) | `application/ports/logger.dart` | Journalisation structurée | REQ-052 |

### 3.3 Couche infrastructure (8 composants)

| ID | Composant | Fichier | Responsabilité | Exigences |
|---|---|---|---|---|
| **CMP-INF-01** | `AssetQuestionRepository` | `infrastructure/content/asset_question_repository.dart` | Lecture assets + décodage + validation de schéma | REQ-001..008 |
| **CMP-INF-02** | `StateCodec` | `infrastructure/storage/state_codec.dart` | Enveloppe versionnée + CRC-32 + sérialisation canonique | REQ-040, REQ-041, REQ-015 |
| **CMP-INF-03** | `Crc32` | `infrastructure/storage/crc32.dart` | Implémentation CRC-32 (IEEE 802.3), pure Dart | REQ-040 |
| **CMP-INF-04** | `PrefsStateRepository` | `infrastructure/storage/prefs_state_repository.dart` | Lecture/écriture, verrou logique, migration d'anciennes clés | REQ-040..044, REQ-015 |
| **CMP-INF-05** | `SystemClock`, `SeededRandomSource` | `infrastructure/time/system_clock.dart`, `infrastructure/random/seeded_random_source.dart` | Adaptateurs temps réel et aléa (graine injectable) | REQ-034, REQ-007, REQ-078 |
| **CMP-INF-06** | `DebugLogger` / `SilentLogger` | `infrastructure/logging/debug_logger.dart` | Journalisation console en debug, silencieuse en release | REQ-052 |
| **CMP-INF-07** | `FlutterAssetReader` | `infrastructure/content/asset_reader.dart` | Adaptateur `rootBundle` (IF-05) | REQ-001, REQ-074 |
| **CMP-INF-08** | `KeyValueStore` (interface) / `SharedPreferencesStore` (adaptateur) | `infrastructure/storage/key_value_store.dart` | Isolation de `SharedPreferences` (IF-06) | REQ-044, REQ-074 |

### 3.4 Couche présentation (5 écrans + 9 widgets + 3 services)

| ID | Composant | Fichier | Responsabilité | Exigences |
|---|---|---|---|---|
| **CMP-PRS-01** | `ThemeSelectionScreen` | `presentation/screens/theme_selection_screen.dart` | Grille des thèmes, accès aux scores | REQ-061 |
| **CMP-PRS-02** | `LevelMapScreen` | `presentation/screens/level_map_screen.dart` | Liste des niveaux, reset de progression | REQ-060, REQ-062, REQ-065 |
| **CMP-PRS-03** | `QuizScreen` | `presentation/screens/quiz_screen.dart` | Déroulé de la session, chronomètre d'affichage | REQ-063, REQ-037 |
| **CMP-PRS-04** | `ResultScreen` (+ `_ScoreHeader`) | `presentation/screens/result_screen.dart` | Résultat, bandeau de déblocage, accès à la revue | REQ-064 |
| **CMP-PRS-05** | `ScoresScreen` | `presentation/screens/scores_screen.dart` | Score total, remise à zéro | REQ-023, REQ-065 |
| **CMP-PRS-06** | `AppStrings` | `presentation/app_strings.dart` | Catalogue de messages (UI + erreurs) | REQ-051, REQ-066 |
| **CMP-PRS-07** | `AsyncView<T>` (+ `ScreenState`) | `presentation/widgets/async_view.dart` | Rendu uniforme `Loading/Ready/Failure` + Réessayer | REQ-060 |
| **CMP-PRS-08** | `LoadingView` | `presentation/widgets/loading_view.dart` | Indicateur de chargement unique | REQ-060 |
| **CMP-PRS-09** | `ErrorView` | `presentation/widgets/error_view.dart` | Message d'erreur traduit + action Réessayer | REQ-051 |
| **CMP-PRS-10** | `QuizBoard`, `_StatusBar` | `presentation/widgets/quiz_board.dart` | Plateau : question, options, chronomètre | REQ-063, REQ-067 |
| **CMP-PRS-11** | `QuizBody` | `presentation/widgets/quiz_body.dart` | Aiguillage chargement / échec / plateau | REQ-060 |
| **CMP-PRS-12** | `AnswerReviewList`, `_ReviewTile` | `presentation/widgets/answer_review_list.dart` | Revue question par question | REQ-064 |
| **CMP-PRS-13** | `LevelList` | `presentation/widgets/level_list.dart` | Liste des niveaux verrouillés/déverrouillés | REQ-062 |
| **CMP-PRS-14** | `OptionButton` | `presentation/widgets/option_button.dart` | Bouton d'option accessible (≥ 48 dp, sémantique) | REQ-067 |
| **CMP-PRS-15** | `CyclingBackground`, `AppBackground` | `presentation/widgets/cycling_background.dart` | Fond animé (cycle de 3 images), coupé si animations désactivées | REQ-067, REQ-070 |
| **CMP-PRS-16** | `AppDependencies` | `presentation/app_dependencies.dart` | Racine de composition (seul endroit qui connaît les implémentations) | ADR-01 |
| **CMP-PRS-17** | `errorCodeOf` | `presentation/error_code.dart` | Conversion erreur → code affichable | REQ-051 |

**Total : 45 composants de bibliothèque** — 9 domaine, 11 application, 8 infrastructure,
17 présentation — auxquels s'ajoutent **2 fichiers d'amorçage** (`lib/app.dart`
avec `QuizApp`, `lib/main.dart`), soit **48 fichiers** et **3 037 lignes**.

**Correspondance avec l'état antérieur** : les « view models » annoncés dans la
version 1.0 (une classe `xxxViewModel` par écran) n'ont pas été réalisés : le
`State` de chaque écran porte l'état et appelle les cas d'usage. Ce choix
supprime une couche de recopie d'état (risque de désynchronisation, ANO-19) et
est couvert par le Tableau A.4 #3 (approche structurée). Le document a été mis à
jour en conséquence (v1.1).

---

## 4. Données et structures

### 4.1 Modèle conceptuel

| Entité | Attributs | Invariants | Persisté |
|---|---|---|---|
| `ThemeId` | `value` | `^[a-z0-9_-]{1,32}$` | clé de map |
| `LevelNumber` | `value` | `1..99` | oui (int) |
| `Question` | `text`, `correctAnswer`, `options` | 6 invariants REQ-005, options non modifiables | non (assets) |
| `LevelCatalog` | `theme`, `levels` (trié, unique, 1er = 1) | REQ-003 | non (assets) |
| `QuizSession` | `questions`, `answers`, `index`, `perQuestion`, `deadlineMs`, `status` | REQ-030..037 | non |
| `AppState` | `score`, `progress: Map<ThemeId, Set<LevelNumber>>` | `score ≥ 0`, niveaux ⊆ catalogue | **oui** |
| `UnlockOutcome` | `newlyUnlocked` \| `alreadyUnlocked` \| `noNextLevel` \| `notEligible` | exactement un cas | non |
| `SessionResult` | `score`, `total`, `unlock`, `persisted` | `0 ≤ score ≤ total` | non (transition) |

### 4.2 Format persisté (REQ-040)

```json
{
  "v": 1,
  "crc": "1a2b3c4d",
  "data": {
    "score": 42,
    "progress": { "arabe": [1, 2, 3], "sira": [1] }
  }
}
```

**Sérialisation canonique** : `data` est sérialisé avec des clés triées
lexicographiquement, sans espace, en UTF-8, puis le CRC-32 est calculé sur ces
octets. Le CRC est stocké en hexadécimal minuscule sur 8 caractères.

**Clés de persistance** :

| Clé | Contenu | Écriture | Lecture |
|---|---|---|---|
| `quizgame.state.v1` | Document ci-dessus | CMP-INF-04 | CMP-INF-04 |
| `levels__<type>` | **Héritage v7** (liste de chaînes) | jamais (sauf suppression post-migration) | CMP-INF-04 (migration) |
| `levels__<Type>` | **Héritage v7** capitalisé | jamais | CMP-INF-04 (migration) |

### 4.3 Machine à états de la session (REQ-036)

```
        ┌──────────────────────────────────────────────┐
        │  answering(index = 0)                        │
        │  deadline = now + perQuestion                │
        └───────┬──────────────────────┬───────────────┘
   answer()     │                      │  expire(now ≥ deadline)
   (option      │                      │  → answers[i] = null
   valide)      │                      │
                ▼                      ▼
        ┌──────────────────────────────────────────────┐
        │  index < n-1 ?  →  answering(index+1)        │
        │  index = n-1 ?  →  finished                  │
        └───────┬──────────────────────────────────────┘
                ▼
        ┌──────────────────────────────────────────────┐
        │  finished  (terminal : toute opération = noop)│
        └──────────────────────────────────────────────┘
```

Invariants :
1. `answers.length == questions.length` à tout instant ;
2. `0 ≤ index ≤ n` ; `index == n` ⇔ `finished` ;
3. `answers[i] == null` tant que la question `i` n'a pas été traitée ;
4. une fois `answers[i]` non nul, il ne peut plus changer ;
5. `deadline` est strictement croissante d'une question à la suivante.

---

## 5. Défense en profondeur et gestion des défauts (§7.3.4.11)

### 5.1 Couches de défense

| Niveau | Mécanisme | Composant | Défaut adressé |
|---|---|---|---|
| **D1 — Validation d'entrée** | `ThemeId.parse`, `LevelNumber.parse`, `Question` (6 invariants), schéma JSON | DOM-01..03, INF-01 | Données d'application ou d'interface invalides |
| **D2 — Typage** | Hiérarchie scellée d'erreurs ; aucun `dynamic` hors adaptateur | DOM-08 | Erreurs silencieuses, `cast` non contrôlé |
| **D3 — Invariants d'exécution** | Machine à états scellée, gardes explicites, transitions illégales = noop journalisé | DOM-05 | Séquencement invalide, double soumission |
| **D4 — Détection de corruption** | Enveloppe versionnée + CRC-32 | INF-02/03 | Altération ou troncature de l'état |
| **D5 — Repli sûr** | État par défaut (`score 0`, progression vide) + journalisation, jamais de crash | INF-04 | Persistance corrompue |
| **D6 — Isolation d'échec** | Chaque cas d'usage renvoie un résultat typé ou une erreur ; l'IHM affiche un état d'échec avec réessai | APP, PRS | Panne de lecture/écriture |

### 5.2 Combinaison retenue au Tableau A.3 (SIL 2)

| # | Technique | SIL 2 requis | État | Mise en œuvre |
|---|---|---|---|---|
| 1 | Programmation défensive | **HR** | ✅ | D1, D3, D6 |
| 4 | Codes de détection d'erreurs | R | ✅ | D4 (CRC-32), choisi parmi 2/4/5/7/12/15/21 |
| 19 | Interface entièrement définie | **HR** | ✅ | §6 : 10 interfaces spécifiées |
| 22 | Méthodologie structurée | **HR** | ✅ | ADR-01, §2, §5.3 |
| 2 | Détection des défauts & diagnostic | R | ✅ | D2, journalisation structurée |
| 18 | Encapsulation d'informations | **HR** | ✅ | Value objects, champs privés, aucun état global mutable |

**Conformité à l'exigence 2 du Tableau A.3** (combinaison SIL 1/2) :
`1 + 19 + 22 + (4)` → satisfaite.

### 5.3 Combinaison retenue au Tableau A.4 (SIL 2)

| # | Technique | SIL 2 | État | Mise en œuvre |
|---|---|---|---|---|
| 3 | Méthodologie structurée | **HR** | ✅ | 4 couches, dépendances orientées |
| 4 | Approche modulaire | **M** | ✅ | 45 composants, 1 responsabilité chacun ; aucune dépendance montante (TC-ARCH-01..03) |
| 5 | Composants | **HR** | ✅ | Interfaces explicites, versionnés, testés isolément |
| 6 | Règles de conception et de codage | **HR** | ✅ | STD-COD-001, RC-01..RC-20 |
| 8 | Langage fortement typé | **HR** | ✅ | Dart *sound null safety*, `sealed`, pas de cast implicite |

**Conformité à l'exigence 2 du Tableau A.4** : `3 + 4 + 5 + 6 + (8)` → satisfaite.

---

## 6. Spécifications d'interface (§7.3.4.18-19)

Chaque interface est spécifiée selon les 7 points exigés : (a)
préconditions/postconditions, (b) valeurs limites, (c) comportement hors
limites, (d) comportement aux limites, (e) contraintes de temps et gestion des
exceptions, (f) tampons/mémoire, (g) synchronisation.

### IF-05 — Assets de contenu

| Rubrique | Spécification |
|---|---|
| **(a) Contrat** | `Future<LevelCatalog> loadCatalog(ThemeId)` ; `Future<List<Question>> loadQuestions(ThemeId, LevelNumber)`. Précondition : `ThemeId` valide (garanti par le type). Postcondition : objet validé ou `ContentError`. |
| **(b) Limites** | 1 ≤ niveaux ≤ 99 ; 1 ≤ questions/niveau ≤ 200 ; 2 ≤ options/question ≤ 10 ; longueur texte ≤ 500 caractères. |
| **(d) À la limite** | 1 niveau, 1 question, 2 options, textes vides → **refus** (`EmptyLevelError`, `InvalidQuestionError`). |
| **(c) Hors limites** | 0 question → `EmptyLevelError` ; > 99 niveaux → `ContentSchemaError` ; > 10 options → `ContentSchemaError`. |
| **(e) Temps/exceptions** | Lecture asynchrone, non bloquante ; délai non borné (asset local) ; toute exception du bundle convertie en `ContentNotFoundError`. |
| **(f) Tampons** | Chargement intégral en mémoire : ≤ 200 questions × (500 + 10×500) octets ≈ 1,1 Mo pire cas. Documenté comme borne supérieure. |
| **(g) Synchronisation** | Lecture seule, idempotente, sans état partagé : appels concurrents sûrs. |

### IF-06 — État persistant

| Rubrique | Spécification |
|---|---|
| **(a) Contrat** | `Future<AppState> load()` ; `Future<void> save(AppState)`. Postcondition : après `save` sans erreur, `load` renvoie une valeur égale. |
| **(b) Limites** | score ≤ 10⁹ ; thèmes ≤ 8 ; niveaux/thème ≤ 99 ; taille du document ≤ 8 Ko. |
| **(d) À la limite** | score = 0, progression = {1} pour 8 thèmes → document ≈ 400 octets, accepté. |
| **(c) Hors limites** | score négatif ou > 10⁹ → `CorruptedStateError` → repli ; document > 8 Ko → refus + repli. |
| **(e) Temps/exceptions** | Écriture ≤ 50 ms typique ; échec → `StateWriteError` ; lecture en échec → repli (jamais d'exception vers l'IHM, REQ-041). |
| **(f) Mémoire** | Document chargé intégralement (≤ 8 Ko) ; aucun tampon partagé. |
| **(g) Synchronisation** | **Verrou logique obligatoire** (REQ-042) : les opérations `load`/`save` sont sérialisées par une file interne ; aucune écriture concurrente. |

### IF-07 / IF-08 — Horloge et cycle de vie

| Rubrique | Spécification |
|---|---|
| **(a) Contrat** | `Clock.nowMs()` monotone, non décroissant. Le cycle de vie notifie `suspended`/`resumed`. |
| **(b) Limites** | Durée/question ∈ [1 s, 300 s] ; session ≤ 200 questions. |
| **(d) À la limite** | Durée = 1 s : une question expirée immédiatement après affichage est un cas **valide** et testé (TC-DOM-20). |
| **(c) Hors limites** | Durée ≤ 0 ou > 300 s → `InvalidDurationError` (REQ-030). |
| **(e) Temps/exceptions** | Précision attendue ±50 ms ; aucun report d'exception depuis les callbacks de cycle de vie. |
| **(g) Synchronisation** | L'horloge est **lue**, jamais modifiée ; la reprise après suspension utilise uniquement l'échéance absolue (REQ-037). |

### IF-01..IF-04, IF-09, IF-10 — Interfaces humaines et système

Spécifiées dans DD-001 §7 (comportement par écran) et couvertes par les tests
d'ensemble TC-SYS-01..12. Points saillants :

* **IF-03** : une option pressée deux fois dans la même trame produit **une**
  réponse (garde de la machine à états, REQ-033) ;
* **IF-04** : fermeture d'un dialogue par retour système = annulation, aucun effet ;
* **IF-09** : image absente → repli couleur unie, aucune exception ;
* **IF-10** : chaque élément interactif possède un libellé sémantique (REQ-067).

---

## 7. Stratégie d'intégration (§7.6) et Spécification de Tests d'Intégration

### 7.1 Ordre d'intégration (bottom-up)

| Étape | Composants intégrés | Critère de passage |
|---|---|---|
| **I1** | DOM-01..04, DOM-06..08 | Tests de composant verts ; domaine sans dépendance |
| **I2** | + DOM-05 (`QuizSession`) | Tous les cas de la machine à états couverts |
| **I3** | INF-02/03 (`StateCodec` + `Crc32`) | Aller-retour de sérialisation sur 100 documents générés + 20 documents corrompus |
| **I4** | + INF-04 (dépôt d'état) sur `shared_preferences` mémoire | Contrat REQ-040..044 respecté, migration incluse |
| **I5** | + INF-01 (contenu) sur assets de test | Contrat REQ-001..008 respecté |
| **I6** | + APP-01..07 | Cas d'usage verts sur doublures |
| **I7** | + PRS-01..06 | Parcours complet de bout en bout (tests d'ensemble) |
| **I8** | Logiciel complet sur appareil Android réel | TC-SYS exécutés, aucune exception |

### 7.2 Spécification des tests d'intégration (Tableau A.1 #12)

Technique retenue : **tests fonctionnels et boîte noire** (Tableau A.6 #1, HR à
SIL 2) + **tests de performance** d'intégration (A.6 #2, R).

| ID | Composants | Objet | Entrées | Résultat attendu | Exigence |
|---|---|---|---|---|---|
| **TC-INT-01** | APP-02 + INF-01 | Session créée avec un contenu valide | Thème `arabe`, niveau 1, 10 questions | Session `answering(0)`, 10 réponses nulles, ordre des options conforme à la graine | REQ-004, REQ-007 |
| **TC-INT-02** | APP-01 + INF-04 (migration) | Progression héritée `levels__Terme` = `["1","2"]` | État vide | État courant contient `{1,2}` **et** clé héritée supprimée après écriture réussie | REQ-015 |
| **TC-INT-03** | APP-04 + INF-04 | Transaction de fin de session | Session 7/10, progression `{1}` | Une seule écriture ; score + progression cohérents ; aucun état partiel | REQ-022 |
| **TC-INT-04** | APP-04 + INF-04 + LOG | Échec d'écriture en fin de session | Dépôt levant `StateWriteError` | Résultat `persisted = false`, erreur journalisée, **aucun** bandeau de succès | REQ-044, REQ-038 |
| **TC-INT-05** | INF-02 + INF-03 + INF-04 | Corruption de l'état | Document avec CRC invalide | Repli `score = 0` + progression vide, journal `STATE-CRC-MISMATCH`, pas d'exception | REQ-041 |
| **TC-INT-06** | APP-01 + INF-01 + PRS-02 | Contenu absent | `levels.json` manquant | Écran `Failure(CONTENT-NOT-FOUND)` avec action Réessayer | REQ-008, REQ-060 |
| **TC-INT-07** | APP-03 + APP-04 + DOM-05 | Fin de session après expiration de la dernière question | 1 question, 1 s, aucune réponse | Score 0, session `finished`, résultat affichable | REQ-035, REQ-038 |
| **TC-INT-08** | APP-04 + DOM-07 | Déverrouillage déjà effectif | Niveau 2 déjà déverrouillé, terminer le niveau 1 | `alreadyUnlocked(2)`, aucune écriture (idempotence) | REQ-013, REQ-043 |
| **TC-INT-09** | Tous + INF-05 (horloge réelle) | Performance d'intégration | 50 questions | Changement de question ≤ 100 ms ; dérive ≤ 50 ms sur 10 s | REQ-070 |
| **TC-INT-10** | APP-06/07 + PRS-05 | Remise à zéro du score | Score 120, progression `{1,2}` | Score 0, progression **inchangée** | REQ-023 |

### 7.3 Intégration logiciel/matériel (Tableau A.1 #13)

| ID | Objet | Environnement | Critère |
|---|---|---|---|
| **TC-HW-01** | Démarrage à froid, mesure du temps | Android API 30, 4 Go | ≤ 2 s |
| **TC-HW-02** | Rotation portrait ↔ paysage en session | Appareil réel | Aucune perte d'état, chronomètre continu (échéance absolue) |
| **TC-HW-03** | Mise en arrière-plan 5 s puis reprise | Appareil réel | Temps restant diminué de 5 s ; expiration si dépassée |
| **TC-HW-04** | Verrouillage de l'écran pendant une question | Appareil réel | Comportement de TC-HW-03 |
| **TC-HW-05** | Mémoire résidente en session | `adb shell dumpsys meminfo` | ≤ 120 Mo |
| **TC-HW-06** | Accessibilité | TalkBack activé | Tous les éléments interactifs annoncés |

---

## 8. Traçabilité composant → exigence (§7.3.4.23 e)

| Exigence | Composants réalisant | Tests |
|---|---|---|
| REQ-001..008 | INF-01, DOM-01, DOM-02, DOM-03, DOM-04 | TC-INF-01..08, TC-DOM-01..09 |
| REQ-010..017 | DOM-04, DOM-07, APP-01, APP-05, INF-04 | TC-DOM-10..13, TC-APP-01..06 |
| REQ-020..024 | DOM-06, APP-04, APP-06, APP-07, INF-04 | TC-DOM-14..17, TC-APP-05, TC-INT-10 |
| REQ-030..038 | DOM-05, APP-02, APP-03, APP-04 | TC-DOM-18..26, TC-APP-07..10 |
| REQ-040..044 | INF-02, INF-03, INF-04 | TC-INF-09..16 |
| REQ-050..053 | DOM-08, APP-12, PRS-06, PRS-07 | TC-INT-04..06 |
| REQ-060..067 | PRS-01..11 | TC-SYS-01..12 |
| REQ-070..080 | Transverse (CI, tests, STD-COD) | TC-SYS-13..20, TC-ARCH-01..03 |

---

## 9. Risques d'architecture et parades

| ID | Risque | Gravité | Parade |
|---|---|---|---|
| **R-01** | `shared_preferences` ne garantit pas l'atomicité multi-clés | Élevée | ADR-03 : **une** clé unique, donc une seule écriture |
| **R-02** | Perte de l'état si l'application est tuée pendant une écriture | Moyenne | Document ≤ 8 Ko, écriture unique, CRC à la lecture → détection et repli |
| **R-03** | Dérive du chronomètre liée à l'ordonnanceur | Moyenne | ADR-05 : échéance absolue, contrôle ±50 ms en TC-INT-09 |
| **R-04** | Contenu invalide livré en production | Élevée | APP-DATA-001 : schéma + validateur en CI bloquante |
| **R-05** | Couplage résiduel IHM ↔ logique | Moyenne | Test d'architecture TC-ARCH-01 (imports interdits) + revue de code |
| **R-06** | Croissance du coût de test sans automatisation | Élevée | 100 % des tests du domaine exécutables par `dart test`, sans émulateur |

---

## 10. Éléments de vérification de l'architecture (§7.3.4.12)

| Critère | Preuve |
|---|---|
| Toutes les exigences sont allouées | §8 : 100 % des REQ ont au moins un composant |
| Aucune dépendance ascendante | `test/architecture_test.dart` (TC-ARCH-01) |
| Aucun composant > 200 lignes | Mesuré par `tool/check_size.dart` en CI |
| Techniques A.3/A.4 satisfaites | §5.2, §5.3 |
| Interfaces entièrement définies | §6 : 10 interfaces × 7 rubriques |
| Gestion des défauts équilibrée | §5.1 : 6 niveaux de défense |

**Fin du document — ARCH-001 v1.0**
