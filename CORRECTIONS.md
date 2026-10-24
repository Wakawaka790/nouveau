# Corrections du code contenu dans « code_complet_quiz_game7 (1).pdf »

## Ce qui a été fait

Le dépôt ne contenait que le PDF (58 pages). Le code a été **extrait de la
couche texte du PDF** (numéros de ligne en marge retirés, indentation
conservée) : les 39 fichiers annoncés ont été récupérés intégralement —
chaque nombre de lignes concorde avec la table des matières du PDF.
Le projet Flutter complet a ensuite été **restauré à la racine du dépôt**
et corrigé fichier par fichier.

> Le texte qui « se chevauche » sur certaines captures d'écran (pages 5 à 8)
> est un artefact d'affichage du lecteur PDF : la couche texte du document
> est propre, le code récupéré est exact.

> Le PDF ne contenait ni les questions JSON, ni les images/sons, ni les
> binaires Android (`gradle-wrapper.jar`, icônes du lanceur). Ils ont été
> **remplacés par des exemples minimaux** (voir §5) pour que le projet
> soit compilable et lançable tel quel : remplacez-les par vos vrais
> fichiers, les chemins sont identiques.

---

## 1. Erreurs qui empêchaient la compilation

| # | Fichier | Problème | Correction |
|---|---------|----------|------------|
| 1 | `pubspec.yaml` | `sdk: ">=2.17.0 <3.0.0"` interdisait Dart 3, exigé par `flutter_lints ^3.0.1` et `audioplayers ^6.4.0` → `flutter pub get` échouait sur tout Flutter récent. | `sdk: ">=3.0.0 <4.0.0"` (+ `flutter: ">=3.27.0"` pour `Color.withValues`). |
| 2 | `pubspec.yaml` | Aucun champ `version:` (utilisé pour `versionCode`/`versionName` Android). | Ajout de `version: 1.0.0+1` et `publish_to: 'none'`. |
| 3 | `pubspec.yaml` | `dev_dependencies` indenté à 4 espaces (YAML valide mais non conventionnel) et section `flutter:` collée sans ligne vide. | Indentation normalisée à 2 espaces. |
| 4 | `pubspec.yaml` | Entrées d'assets **en double** : `arabe/level_3.json` ×2, `general/level_1.json` ×3 — et **`arabe/level_2.json` absent** (le niveau 2 d'arabe ne pouvait pas se charger). Les entrées `assets/questions/` et `assets/images/` déclaraient des dossiers sans fichier direct (Flutter refuse : *« No file or variants found for asset »*) et n'incluaient de toute façon pas les sous-dossiers. | Une entrée **dossier par thème** (`assets/questions/arabe/`, …), `assets/backgrounds/`, `assets/sounds/` : tous les `levels.json` / `level_N.json` sont inclus automatiquement, fini doublons et oublis. |
| 5 | `android/app/build.gradle.kts` | `minSdk = flutter.minSdkVersion` (= API 21 sur Flutter 3.29) alors qu'**audioplayers exige ≥ 23** : échec à la fusion des manifests en local (seul le CI corrigeait après coup). | `minSdk = 23`, avec commentaire explicatif. |
| 6 | `android/…/quiz_game7/MainActivity.kt` | Deux `MainActivity` (`quiz_game` **et** `quiz_game7`) alors que `namespace`/`applicationId` valent `com.example.quiz_game` : la seconde était une classe morte issue d'un renommage, source de confusion. | Supprimée. Il ne reste que la cohérente `com.example.quiz_game.MainActivity`. |
| 7 | `main.dart` (racine) | Doublon périmé de `lib/main.dart` (autre thème, `primarySwatch`, pas de `ensureInitialized`). Flutter ne l'utilise jamais, mais l'analyseur le lisait. | Supprimé. Le vrai point d'entrée est `lib/main.dart`. |
| 8 | `.github/scripts/prepare_project.py` | Les emojis notés `\u{…}` dans le PDF sont **invalides en Python** (`SyntaxError: truncated \uXXXX escape`, vérifié) : recopié tel quel, le script du CI ne démarrait même pas. Même notation dans le Dart, le Kotlin et le YAML. | Les 10 symboles `\u{…}` ont été restaurés en vrais caractères (🙂 🔧 📁 📄 ❌ ✅ ⚠️) dans les 4 fichiers concernés. |

## 2. Erreurs et oublis à l'exécution

| # | Fichier | Problème | Correction |
|---|---------|----------|------------|
| 9 | `lib/screens/quiz_screen.dart` | `audioplayers` et les sons `correct.mp3`/`wrong.mp3` étaient déclarés mais **jamais utilisés** : aucun retour sonore. | Lecture du son à chaque réponse (juste/faux/temps écoulé), en arrière-plan (`unawaited`), erreurs ignorées proprement (un son absent ne casse plus le quiz), lecteur libéré dans `dispose()`. |
| 10 | `lib/widgets/cycling_background.dart` | Si la liste d'images rétrécissait entre deux ticks du minuteur, `widget.images[_currentIndex]` pouvait lever un `RangeError`. | Index calculé avec `% widget.images.length`. |
| 11 | `lib/screens/level_map_screen.dart` | `Color.withOpacity` déprécié depuis Flutter 3.22. | `withValues(alpha: 0.82)`. |
| 12 | `android/…/AndroidManifest.xml` | Le téléphone affichait « quiz_game » sous l'icône. | `android:label="Quiz éducatif"`. |
| 13 | `android/gradle.properties` | `android.enableJetifier=true` : obsolète, supprimé dans AGP 9. | Ligne retirée (tous les plugins sont déjà AndroidX). |

## 3. Erreurs dans le workflow CI (`.github/`)

| # | Fichier | Problème | Correction |
|---|---------|----------|------------|
| 14 | `build-apk.yml` (publication) | `APK_FILE="$(ls …/app-release.apk …/app-debug.apk \| head -1)"` : `ls` sort en erreur dès qu'**un** des deux fichiers est absent — cas normal après un build réussi. Sous `set -euo pipefail`, l'étape mourait **avant** le test d'absence → **l'APK n'aurait jamais été publié en Release**. *(Reproduit : l'ancien extrait sort en code 2, le nouveau en code 0.)* | Boucle `for candidate … [ -f … ]`. |
| 15 | `build-apk.yml` (×2) | `fix_android_config.py` appelé **sans `--root`** : il visait `GITHUB_WORKSPACE`, donc pour un projet en sous-dossier ou en archive .zip, l'ajustement de minSdk était silencieusement ignoré (« introuvable — ajustement ignoré »). | `--root "$ROOT"` ajouté aux deux appels. |
| 16 | `fix_android_config.py` | L'expression régulière « corrigeait » aussi le mot `minSdkVersion` **dans les commentaires**. *(Elle a mordu pendant cette correction même : un commentaire du `build.gradle.kts` a été réécrit.)* | Clé ancrée en début de ligne (`^[ \t]*`), indentation préservée. Testé : les commentaires sont intacts et un vrai réglage est toujours corrigé. |
| 17 | `prepare_project.py` | `zipfile.extractall()` sans contrôle : une archive contenant `../../…` pouvait écrire hors du dossier cible (**Zip Slip, CWE-22**). | Nouvelle fonction `_safe_extract()` qui refuse tout chemin sortant de la cible ; l'archive est alors ignorée avec un message clair. |
| 18 | `build-apk.yml` | Aucune analyse ni test : une erreur Dart n'apparaissait qu'après un build *release* complet, puis un *debug* voué au même échec. | Étape ajoutée : `flutter analyze --no-fatal-infos` + `flutter test`. |

## 4. Qualité et hygiène du dépôt

| # | Fichier | Correction |
|---|---------|------------|
| 19 | `analysis_options.yaml` | Retrait de `analyzer: errors: depend_on_referenced_packages: ignore` (masquait une vraie catégorie d'erreurs alors qu'aucun import ne le justifie) ; `include:` remis en tête. |
| 20 | `GeneratedPluginRegistrant.java` | Fichier **généré** (marqué « Generated file. Do not edit. ») : supprimé du dépôt et ajouté à `.gitignore`, Flutter le régénère à chaque build. Versionné, il provoque des erreurs dès qu'un plugin change. |
| 21 | `.gitignore` | Ajouts : `/android/local.properties` (chemins propres à une machine, le PDF le disait lui-même) et `/.projet_extraite/`. |
| 22 | `android/gradlew.bat` + `.gitattributes` (nouveau) | Fins de ligne converties en **CRLF** (cmd.exe peut échouer sur les `goto` en LF seul), et règle Git permanente `eol=crlf` / `gradlew eol=lf`. `gradlew` rendu exécutable. |
| 23 | `test/quiz_game7_test.dart` (nouveau) | 7 tests unitaires : validation de `Question` (bonne réponse présente, doublons après `trim`, JSON incomplet), calcul du score (temps écoulé = 0 point, précision), tolérance de `UserProfile.fromJson`. |

## 5. Fichiers absents du PDF, recréés

| Fichier | Origine |
|---------|---------|
| `android/gradle/wrapper/gradle-wrapper.jar` | Récupéré depuis le dépôt officiel `gradle/gradle`, étiquette **v8.10.2** (conforme à `gradle-wrapper.properties`). Empreinte Git vérifiée : `a4b76b95…` (43 583 octets, contient `GradleWrapperMain`). Sans lui, `./gradlew` échoue immédiatement. |
| `android/app/src/main/res/mipmap-*/ic_launcher.png` (×5) | Icônes provisoires générées (point d'interrogation sur fond violet du thème). Le manifest les référence : sans elles, le build Android échoue à la liaison des ressources. |
| `assets/questions/<thème>/levels.json` + `level_1.json` (×8) | **3 questions d'exemple par thème**, au format exact attendu par `QuestionLoader`/`Question.fromJson` (bonne réponse ∈ options, ≥ 2 options, sans doublon, `{"Levels": [1]}`). 👉 Remplacez par vos fichiers d'origine : il suffit de copier vos JSON dans ces dossiers. |
| `assets/backgrounds/bg1.png`, `bg2.png`, `bg3.jpeg` | Dégradés provisoires aux couleurs de l'app (720×1280). |
| `assets/sounds/correct.mp3` / `wrong.mp3` | Petits sons de retour générés (880 Hz / 196 Hz, MP3 décodables vérifiés). |
| `assets/logo.png` | Logo provisoire 512×512. |

## 6. Vérifications effectuées

✅ Extraction du PDF : 39/39 fichiers, nombre de lignes conforme au sommaire, 0 ligne perdue.
✅ Syntaxe Dart : les 16 fichiers `.dart` (15 de `lib/` + le test) analysés par la grammaire
officieuse tree-sitter — aucune erreur. *(Contrôle de syntaxe, pas de types.)*
✅ Cohérence croisée : tous les imports `package:quiz_game7/…` résolus, tous les paquets
importés sont déclarés, les 8 identifiants de catégories correspondent aux dossiers de
questions, les 5 `ic_launcher` et l'unique `MainActivity` correspondent à `namespace`.
✅ Python : `py_compile` OK ; **`prepare_project.py` exécuté sur le dépôt restauré** →
« tous les assets déclarés existent », « pubspec.yaml inchangé » (autrement dit le CI n'a
plus rien à bricoler) ; `fix_android_config.py` → « déjà conforme », fichier inchangé.
✅ YAML (pubspec, analysis_options, workflow à 12 étapes), XML (7 fichiers Android) et
JSON (16 fichiers d'exemples) tous relus par leur analyseur respectif.
✅ Bash : `gradlew` valide (`bash -n`) ; bug n°14 reproduit avant/après.
✅ Médias : images relues (format/dimensions), MP3 décodés par ffmpeg, jar Gradle vérifié.

⚠️ **Non vérifiable dans cet environnement** (le SDK Flutter n'y est pas téléchargeable) :
la compilation réelle. À lancer chez vous ou via l'onglet **Actions** de GitHub :

```bash
flutter pub get
flutter analyze
flutter test
flutter run            # ou : flutter build apk --release
```

## 7. Points relevés mais **volontairement non modifiés** (à vous de décider)

1. **Déblocage des niveaux** : terminer un niveau débloque le suivant **quel que soit
   le score** (même 0, en laissant le temps s'écouler). `calculateQuizAccuracy`
   existe mais n'est jamais utilisée — un seuil (50 % ?) était peut-être prévu.
2. **Score total cumulable à l'infini** : rejouer le même niveau rajoute ses points
   à chaque fois (`ProfileManager.updateScore` additionne). Si le score doit
   refléter la progression, il faudrait enregistrer le meilleur score par niveau.
3. **Code mort** : `UserProfile` et `ProfileManager.clearScore()` ne sont utilisés nulle
   part ; `audioplayers` ne l'était pas non plus (corrigé au n°9). Conservés : ce sont
   peut-être des fonctions en préparation (profils joueurs).
4. **Signature release** : l'APK *release* est signé avec la clé *debug*
   (`signingConfigs.getByName("debug")`) — classique en développement, mais
   inacceptable pour le Play Store ; créez un keystore avant publication.
5. **Versions** : `flutter_lints ^3.0.1` fonctionne avec Dart 3 mais date ;
   un passage à `^5.0.0` (modèle de Flutter 3.29) est possible dès que
   `flutter analyze` passe chez vous.

---

*Extraction + corrections réalisées le 24 octobre 2026 sur la branche
`arena/1ad9ed66-nouveau`. Le fichier PDF d'origine est conservé à la racine
du dépôt ; vous pouvez le supprimer (ou le déplacer dans un dossier `docs/`)
une fois vos vraies ressources remises en place.*
