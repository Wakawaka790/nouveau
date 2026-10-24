# Quiz Game 7 — « Quiz éducatif » (application Flutter)

Application de quiz éducatif à thèmes (arabe, sira, coran, histoire,
sahaba, hijra, termes, général), avec niveaux à débloquer, minuteur
par question, sons de retour et score total sauvegardé sur l'appareil.

> Ce projet a été **restauré depuis le PDF** `code_complet_quiz_game7 (1).pdf`
> puis corrigé — voir **[CORRECTIONS.md](CORRECTIONS.md)** pour la liste
> détaillée des 23 corrections et des fichiers recréés.

## Lancer l'application

Prérequis : Flutter ≥ 3.27 (Dart ≥ 3.0) — vérifié avec `flutter --version`.

```bash
flutter pub get
flutter analyze     # analyse statique
flutter test        # tests unitaires
flutter run         # sur un téléphone/émulateur Android connecté
```

Compiler l'APK : `flutter build apk --release`
(ou poussez sur `main` : le workflow *Construire l'APK* le produit et le
publie dans l'onglet **Releases**, étiquette `apk-latest`.)

## Structure

```
lib/
  main.dart                      point d'entrée (le seul main.dart)
  models/      question.dart, quiz_category.dart (les 8 thèmes), user_profile.dart
  screens/     choix du thème → carte des niveaux → quiz → résultat, scores
  services/    chargement des questions, niveaux débloqués, score, calcul du score
  widgets/     fond d'écran animé (rotation d'images)
assets/
  questions/<thème>/levels.json     {"Levels": [1, 2, 3]}
  questions/<thème>/level_N.json    [{"question": "…", "correct": "…", "options": ["…"]}]
  backgrounds/  bg1.png, bg2.png, bg3.jpeg
  sounds/       correct.mp3, wrong.mp3
android/        configuration Android (applicationId com.example.quiz_game, minSdk 23)
test/           tests unitaires de la logique (questions, score, profil)
.github/        workflow de compilation automatique de l'APK + scripts d'aide
```

## Ajouter vos vraies questions

Les sous-dossiers de `assets/questions/<thème>/` contiennent **3 questions
d'exemple** par thème (les JSON d'origine n'étaient pas dans le PDF).
Pour mettre les vôtres : copiez vos fichiers dans ces dossiers en gardant
les mêmes noms (`levels.json`, `level_1.json`, `level_2.json`, …).
Grâce à la déclaration par dossier dans `pubspec.yaml`, **aucun fichier
n'est à déclarer un par un** — relancez simplement l'application.

Règles vérifiées par l'application au chargement (message d'erreur explicite
sinon) : le premier niveau est le n° 1 ; chaque question a une bonne réponse
présente dans ses options, au moins 2 options, sans doublon.

## Personnalisation rapide

- **Images de fond** : remplacez les fichiers de `assets/backgrounds/`
  (les noms sont listés dans `lib/widgets/animated_background.dart`).
- **Icône de l'application** : remplacez `assets/logo.png` et les fichiers
  `android/app/src/main/res/mipmap-*/ic_launcher.png`.
- **Durée par question** : paramètre `secondsPerQuestion` de `QuizScreen`
  (10 s par défaut).
