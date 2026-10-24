# Fonctions du programme — Quiz Game 7 (Quiz éducatif)

Inventaire **exhaustif** des fonctions nommées du code restauré et corrigé
(voir `CORRECTIONS.md`). Les numéros de ligne correspondent aux fichiers
actuels du dépôt.

**Totaux (application Dart, dossier `lib/`) : 75 déclarations nommées**

- 4 **fonctions libres** (hors classe) ;
- 14 **constructeurs** (12 génératifs, dont 10 `const`, + 2 `factory`) ;
- 57 **méthodes, getters et opérateur** (dont 15 méthodes `static`
  de services et 3 getters).

S'y ajoutent : de nombreuses **fermetures anonymes** (callbacks `onPressed`,
`onTap`, `itemBuilder`, minuteurs…), 22 fonctions Python dans les scripts CI,
3 fonctions shell dans `gradlew`, et aucune fonction propre en Kotlin.

---

## 1. Point d'entrée — `lib/main.dart`

| Ligne | Fonction | Rôle |
|---:|---|---|
| 4 | `void main()` *(libre)* | Démarre l'app : `WidgetsFlutterBinding.ensureInitialized()` puis `runApp(const QuizGameApp())`. |
| 10 | `const QuizGameApp({super.key})` | Constructeur du widget racine. |
| 13 | `Widget build(BuildContext)` | Construit le `MaterialApp` « Quiz éducatif » : thème Material 3 (couleur graine `0xFF493A8C`, barre d'app bleu nuit, boutons ≥ 48 px), écran d'accueil = `QuizTypeSelectionScreen`. |

## 2. Modèles — `lib/models/`

### `question.dart` — classe `Question`

| Ligne | Fonction | Rôle |
|---:|---|---|
| 4 | `Question({required question, correctAnswer, options})` | Assainit (`trim`, liste `unmodifiable`) puis **valide** : question et bonne réponse non vides, ≥ 2 options, aucune vide ni en double, bonne réponse présente dans les options ; sinon `ArgumentError`. |
| 45 | `factory Question.fromJson(Map<String, dynamic>)` | Crée une question depuis le JSON (`question` ou ancien champ `arabe`, `correct` ou `correctAnswer`, `options`), vérifie les types, **mélange les options** (`shuffle(Random())`) pour que la bonne réponse ne soit pas toujours en premier ; convertit les `ArgumentError` en `FormatException`. |
| 75 | `Map<String, dynamic> toJson()` | Sérialise en `{question, correct, options}`. |

### `quiz_category.dart` — classe `QuizCategory` + données

| Ligne | Fonction | Rôle |
|---:|---|---|
| 5 | `const QuizCategory({required id, label, description, icon})` | Décrit un thème (identifiant stable utilisé pour les clés de préférences et les dossiers d'assets). |
| 70 | `QuizCategory? quizCategoryForId(String id)` *(libre)* | Recherche un thème par identifiant normalisé (`trim` + minuscules) dans la constante `quizCategories` (8 thèmes : arabe, sira, coran, histoire, sahaba, hijra, terme, general) ; `null` si inconnu. |

### `user_profile.dart` — classe `UserProfile` ⚠️ non utilisée par l'app (seulement par les tests)

| Ligne | Fonction | Rôle |
|---:|---|---|
| 2 | `UserProfile({required name, avatar, score = 0})` | Profil joueur : nom, avatar (emoji), score. |
| 8 | `Map<String, dynamic> toJson()` | Sérialise `{name, avatar, score}`. |
| 14 | `factory UserProfile.fromJson(...)` | Lecture tolérante : score accepté comme nombre ou chaîne, borné à ≥ 0, valeurs par défaut `''` et 🙂. |
| 28 | `bool operator ==(Object other)` | Égalité sur **nom + avatar** (pas sur le score). |
| 33 | `int get hashCode` | `Object.hash(name, avatar)`, cohérent avec `==`. |

## 3. Écrans — `lib/screens/`

### `quiz_type_selection_screen.dart` — accueil / choix du thème

| Ligne | Fonction | Rôle |
|---:|---|---|
| 8 | `const QuizTypeSelectionScreen({super.key})` | |
| 10 | `void _openScores(BuildContext)` | Navigue vers l'écran du score total (`ScoresScreen`). |
| 16 | `void _openCategory(BuildContext, QuizCategory)` | Navigue vers les niveaux du thème choisi (`LevelMapScreen`). |
| 25 | `Widget build(BuildContext)` | Barre d'app + bouton « trophée » ; grille responsive (2 ou 4 colonnes) de cartes des 8 thèmes (icône, libellé, description) sur fond animé. |

### `level_map_screen.dart` — choix du niveau (avec état `_LevelMapScreenState`)

| Ligne | Fonction | Rôle |
|---:|---|---|
| 9 | `const LevelMapScreen({required quizType})` | Reçoit l'identifiant du thème. |
| 14 | `State createState()` | Crée l'objet d'état. |
| 23 | `String get _title` | Libellé lisible du thème (ou l'identifiant brut). |
| 26 | `void initState()` | Lance le chargement des niveaux. |
| 31 | `Future<void> _loadLevels()` | Charge les niveaux configurés (`QuestionLoader.loadAvailableLevels`), initialise la progression (`LevelManager`), récupère les niveaux débloqués, gère chargement/erreurs. |
| 63 | `Future<void> _startLevel(int level)` | Ouvre le quiz (`push<bool>`) ; recharge la liste si le niveau s'est terminé. |
| 76 | `Future<void> _confirmReset()` | Boîte de confirmation puis réinitialisation de la progression du thème (`LevelManager.resetLevels`). |
| 108 | `Widget _buildLevelList()` | 4 états d'affichage : chargement (indicateur), erreur (message + bouton « Réessayer »), aucun niveau, ou liste des niveaux avec cadenas (débloqué/à terminer). |
| 206 | `Widget build(BuildContext)` | `Scaffold` : titre, bouton « réinitialiser », en-tête (x / y niveaux débloqués), liste. |

### `quiz_screen.dart` — déroulement du quiz (avec état `_QuizScreenState`) — *le fichier le plus riche : 14 fonctions*

| Ligne | Fonction | Rôle |
|---:|---|---|
| 15 | `const QuizScreen({required niveau, quizType, availableLevels, secondsPerQuestion = 10})` | Paramètres du niveau joué ; `assert(secondsPerQuestion > 0)`. |
| 29 | `State createState()` | |
| 45 | `String get _title` | Libellé du thème. |
| 48 | `void initState()` | S'abonne au cycle de vie de l'app et charge les questions. |
| 55 | `void didChangeAppLifecycleState(AppLifecycleState)` | Met le minuteur **en pause** quand l'app passe en arrière-plan, le reprend (sans réinitialiser) au retour. |
| 66 | `Future<void> _loadQuestions()` | Charge les questions du niveau (`QuestionLoader`), prépare `réponses = null` partout, repart à la question 1, démarre le minuteur. |
| 97 | `void _startTimer({bool reset = true})` | Minuteur d'1 seconde : décrémente le temps restant et, à 0, soumet automatiquement « pas de réponse ». |
| 112 | `Future<void> _playFeedbackSound(bool isCorrect)` *(ajout de la correction)* | Joue `sounds/correct.mp3` ou `sounds/wrong.mp3` (temps écoulé = faux) ; ne casse jamais le quiz si le son échoue. |
| 124 | `void _submitAnswer(String? answer)` | Cœur du jeu : arrête le minuteur, joue le son, enregistre la réponse, passe à la question suivante ou termine. |
| 151 | `Future<void> _finishQuiz()` | Calcule le score (`calculateQuizScore`), **ajoute les points** au score total (`ProfileManager.updateScore`), **débloque le niveau suivant** (`LevelManager.unlockNextLevel`), collecte les erreurs de sauvegarde, puis remplace l'écran par `ScoreScreen` (résultat `true` renvoyé à la carte des niveaux). |
| 190 | `void dispose()` | Désabonne l'observateur, annule le minuteur, libère le lecteur audio. |
| 197 | `Widget _buildMessage(String, {required isError})` | Message centré (attente ou erreur + bouton « Réessayer »). |
| 229 | `Widget _buildQuiz()` | Interface du quiz : progression (« Question i sur n »), score courant, jauge de temps, carte de la question, boutons des options. |
| 326 | `Widget build(BuildContext)` | Choisit l'état à afficher (chargement / erreur / aucune question / quiz). |

### `score_screen.dart` — résultat d'un niveau

| Ligne | Fonction | Rôle |
|---:|---|---|
| 8 | `const ScoreScreen({required quizType, niveau, questions, answers, unlockedNextLevel, persistenceError})` | Données du résultat. |
| 26 | `Widget build(BuildContext)` | Affiche `score / total`, l'annonce « Niveau X débloqué ! », une éventuelle erreur de sauvegarde, la **correction question par question** (votre réponse / bonne réponse), et le bouton « Retour aux niveaux ». |

### `scores_screen.dart` — score total (avec état `_ScoresScreenState`)

| Ligne | Fonction | Rôle |
|---:|---|---|
| 6 / 9 | `const ScoresScreen(...)` / `createState()` | |
| 18 | `void initState()` | Charge le score. |
| 23 | `Future<void> _loadScore()` | Lit le score total sauvegardé (`ProfileManager.getTotalScore`), gère les erreurs. |
| 41 | `Future<void> _resetScore()` | Confirmation, remise à zéro du score, rechargement de l'écran. |
| 74 | `Widget build(BuildContext)` | Chargement / erreur / « X points » (+ bouton « Réinitialiser le score » si > 0). |

## 4. Services — `lib/services/` (toute la logique « métier », méthodes `static`)

### `question_loader.dart`

| Ligne | Fonction | Rôle |
|---:|---|---|
| 8 | `const QuizContentException(this.message)` | Exception métier à message lisible. |
| 13 | `String QuizContentException.toString()` | Renvoie le message tel quel. |
| 17 | `static String _normalizedQuizType(String quizType)` | Normalise et valide l'identifiant de thème (regex `^[a-z0-9_-]+$`, anti-injection de chemin) ; sinon `ArgumentError`. |
| 25 | `static Future<dynamic> _loadJson(String path)` | Lit un asset (`rootBundle.loadString`) et le décode ; fichier absent ou JSON invalide → `QuizContentException` explicite. |
| 42 | `static Future<List<int>> loadAvailableLevels(String quizType)` | Lit `assets/questions/<thème>/levels.json` (liste `Levels`), valide : numéros ≥ 1, sans doublon, triés, premier niveau = 1. |
| 78 | `static Future<List<Question>> loadQuestions(String quizType, int niveau)` | Lit `assets/questions/<thème>/level_N.json`, convertit chaque objet avec `Question.fromJson` (numéro de question cité dans les erreurs), exige au moins 1 question. |

### `level_manager.dart` — progression (sauvegardée en `SharedPreferences`, clé `levels__<thème>`)

| Ligne | Fonction | Rôle |
|---:|---|---|
| 4 | `static String _keyFor(String quizType)` | Fabrique/valide la clé de stockage. |
| 13 | `static Future<void> initializeLevelsForQuiz(quizType, {totalLevels = 10})` | Garantit que le niveau 1 est débloqué, nettoie les valeurs hors limite, **migre l'ancienne clé capitalisée** (« Terme »), n'écrit que si ça change. |
| 63 | `static Future<int?> unlockNextLevel(completedLevel, quizType, {required availableLevels})` | Après un niveau terminé : vérifie qu'il était débloqué, ajoute et persiste le niveau suivant configuré, renvoie son numéro (`null` si aucun). |
| 97 | `static Future<List<String>> getUnlockedLevels(String quizType)` | Lit et assainit les niveaux débloqués (triés, `{1}` par défaut), en chaînes pour compatibilité avec les sauvegardes anciennes. |
| 110 | `static Future<void> resetProgressForQuiz(String quizType)` | Supprime la clé (et les clés héritées) du thème. |
| 126 | `static Future<void> resetLevels(quizType, {totalLevels = 10})` | = `resetProgressForQuiz` puis `initializeLevelsForQuiz`. |

### `profile_functions.dart` — `ProfileManager` (score total, clé `total_score`)

| Ligne | Fonction | Rôle |
|---:|---|---|
| 7 | `static Future<int> updateScore(int additionalPoints)` | **Additionne** les points gagnés au total sauvegardé (rejette les valeurs négatives) et renvoie le nouveau total. |
| 22 | `static Future<void> resetScore()` | Remet le total à 0. |
| 27 | `static Future<void> clearScore()` | Supprime la clé. ⚠️ Jamais appelée (doublon fonctionnel de `resetScore`). |
| 32 | `static Future<int> getTotalScore()` | Lit le total (0 par défaut). |

### `quiz_scoring.dart` — logique pure (fonctions libres)

| Ligne | Fonction | Rôle |
|---:|---|---|
| 4 | `int calculateQuizScore(List<Question>, List<String?>)` | Compte les bonnes réponses ; sans réponse/temps écoulé (`null`) = 0 point. |
| 12 | `double calculateQuizAccuracy(List<Question>, List<String?>)` | `score / nombre de questions` (0 si liste vide). ⚠️ Utilisée seulement par les tests, pas encore par l'app (seuil de déblocage éventuel). |

## 5. Widgets — `lib/widgets/`

### `animated_background.dart` 🟰 `AnimatedBackground`

| Ligne | Fonction | Rôle |
|---:|---|---|
| 7 | `const AnimatedBackground({required child})` | Fond d'écran commun à tous les écrans. |
| 18 | `Widget build(BuildContext)` | Délègue à `CyclingBackground` (3 images `bg1/bg2/bg3`, rotation 10 s) + voile sombre `0x660B1020` pour garder le texte blanc lisible. |

### `cycling_background.dart` 🟰 `CyclingBackground` (+ `_CyclingBackgroundState`)

| Ligne | Fonction | Rôle |
|---:|---|---|
| 8 | `const CyclingBackground({required child, images, interval = 6 s})` | |
| 20 | `State createState()` | |
| 28 | `void initState()` | Démarre la rotation. |
| 34 | `void didUpdateWidget(oldWidget)` | Si images/intervalle changent : annule l'ancien minuteur, repart de la 1ʳᵉ image. |
| 43 | `void _startCycle()` | Minuteur périodique qui avance l'index (modulo) si ≥ 2 images et intervalle > 0. |
| 52 | `void dispose()` | Annule le minuteur. |
| 58 | `Widget build(BuildContext)` | Liste vide → enfant seul ; sinon `AnimatedSwitcher` (fondu 700 ms) sur l'image courante (index borné par `% length` — correction n°10), couleur de secours si l'image est illisible, enfant par-dessus. |

## 6. Enchaînement principal (qui appelle qui)

```
main() ─► QuizGameApp.build ─► QuizTypeSelectionScreen
                                  ├─ _openScores ─► ScoresScreen (_loadScore / _resetScore ─► ProfileManager)
                                  └─ _openCategory ─► LevelMapScreen (_loadLevels ─► QuestionLoader
                                                        │                              + LevelManager)
                                                        └─ _startLevel ─► QuizScreen
                                                              _loadQuestions ─► QuestionLoader.loadQuestions
                                                                              ─► Question.fromJson
                                                              _startTimer ─┐ (timeout)
                                                              boutons ─────┴► _submitAnswer
                                                                                ├► _playFeedbackSound
                                                                                └► _finishQuiz
                                                                                     ├► calculateQuizScore
                                                                                     ├► ProfileManager.updateScore
                                                                                     ├► LevelManager.unlockNextLevel
                                                                                     └► ScoreScreen (correction)
```

## 7. Tests — `test/quiz_game7_test.dart`

`void main()` (L.10) déclare **8 tests fermetures** en 3 groupes :
`Question` (mélange des options, bonne réponse absente, doublons après
`trim`, JSON incomplet) · `calculateQuizScore / calculateQuizAccuracy`
(temps écoulé = 0 point, précision) · `UserProfile` (tolérance de
`fromJson`, aller-retour `toJson`/`fromJson`).

## 8. Annexes hors application Flutter

### Scripts CI en Python (22 fonctions)

**`.github/scripts/fix_android_config.py`** — aligne minSdk/compileSdk dans le Gradle :
`normalize(key)` · `find_gradle_file(root)` · `patch(path, targets)` et sa fonction
imbriquée `replace(match)` (ignorer les commentaires, ne jamais baisser) · `main()`.

**`.github/scripts/prepare_project.py`** — prépare le projet avant le build de l'APK :
`log()` · `set_output()` (écrit dans `$GITHUB_OUTPUT`) · `add_summary()` ·
`has_dart_source()` / `looks_like_project()` / `has_stray_main()` (détection) ·
`walk_projects()` (générateur de recherche en sous-dossiers) · `_safe_extract()`
(protection Zip Slip) · `extract_archives()` · `locate_project()` ·
`_major()` · `fix_dart_constraint()` (autoriser Dart 3) · `ensure_version()` ·
`prune_assets()` (assets absents/doublons) · `read_field()` · `explain_missing()`
(diagnostic si le code est absent) · `main()` (orchestrateur).

### Autres

- **`android/gradlew`** (shell) : `warn()` (afficher), `die()` (afficher + sortir en erreur),
  `splitJvmOpts()` (mettre les options JVM en tableau) — script standard généré par Flutter.
- **Kotlin** : `MainActivity : FlutterActivity()` — **aucune fonction propre**,
  tout le comportement est hérité de Flutter.
- **Fermetures anonymes** : non comptées dans les 75, mais essentielles à l'UI —
  `itemBuilder`/`separatorBuilder` des listes et grilles, `builder` des boîtes de
  dialogue et des routes, `errorBuilder` des images, rappels des `Timer.periodic`,
  et les `onPressed`/`onTap` des boutons et cartes.

---

*Inventaire généré à partir de l'arbre syntaxique Dart (tree-sitter) et Python (`ast`),
sur la branche `arena/1ad9ed66-nouveau`, le 24 octobre 2026.*
