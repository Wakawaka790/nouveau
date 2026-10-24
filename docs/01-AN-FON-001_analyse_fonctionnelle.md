# AN-FON-001 — Analyse fonctionnelle du logiciel « Quiz Game 7 »

| | |
|---|---|
| **Référence document** | AN-FON-001 |
| **Version** | 1.1 |
| **Date** | 24 octobre 2026 |
| **Statut** | Soumis à revue |
| **Objet** | Analyse fonctionnelle du logiciel existant, inventaire exhaustif des fonctions, identification des écarts au référentiel NF EN 50128 |
| **Référentiel principal** | NF EN 50128:2011 — Applications ferroviaires — Systèmes de signalisation — Logiciel pour systèmes de commande et de protection ferroviaires |
| **Niveau d'intégrité retenu** | **SIL 2** (décision D-001, cf. §1.3 et SRS-001 §3) |
| **Référentiels connexes** | NF EN 50126-1 (sûreté de fonctionnement), NF EN 50128 §4 (allocation SIL), §6.5 (AQ), §7 (cycle de vie), §8.4 (données d'application) |
| **Source analysée** | `code_complet_quiz_game7 (1).pdf`, 58 pages, édition du 17/10/2026 — 39 fichiers dont 16 fichiers Dart (1 610 lignes) |
| **Baseline de référence** | `legacy/baseline_v7/` (copie extraite, numérotation de lignes identique au PDF) |
| **Documents amont** | Aucun (l'analyse se fonde sur le code ; cf. §16 pour les hypothèses) |
| **Documents aval prévus** | SRS (Spécification des Exigences du Logiciel), SW-ARCH (Spécification de l'Architecture), SW-DD (Conception détaillée), jeux de tests CT, rapports de vérification et de validation |

---

## 1. Objet, périmètre et statut vis-à-vis de la norme

### 1.1 Objet

Ce document constitue l'**analyse fonctionnelle** du logiciel « Quiz Game 7 »,
application mobile éducative Flutter. Il répond à trois objectifs :

1. **Décrire la frontière, les acteurs et les modes de fonctionnement** du
   logiciel tel qu'il existe aujourd'hui (AS-IS), sans rien modifier.
2. **Identifier exhaustivement toutes les fonctions** — 87 unités fonctionnelles
   recensées : 64 dans le logiciel applicatif (37 présentation, 13 domaine,
   14 services) et 23 dans la configuration, le démarrage et l'outillage de
   build/CI — avec leurs entrées, sorties, pré/post-conditions et modes
   d'erreur (exigence NF EN 50128 §7.2.4.13 : « toutes les fonctions que le
   logiciel est tenu d'exécuter doivent être clairement identifiées »).
3. **Établir le socle de traçabilité** requis avant toute refonte :
   `Exigence → Fonction → Test → Anomalie` (§13), base du futur cycle de vie
   conforme.

### 1.2 Périmètre

**Inclus** : les 16 fichiers Dart (`lib/`, `main.dart` racine), la configuration
du projet (`pubspec.yaml`, `analysis_options.yaml`), l'enveloppe Android
(manifestes, Gradle, `MainActivity`), les scripts de préparation et le workflow
CI. Sont décrits comme « composants logiciels » au sens de la norme.

**Exclu** : le **contenu pédagogique** (`assets/questions/**/*.json`, images,
sons). Ce contenu n'est pas du code, mais il est **une donnée d'application**
au sens du §8.4 de la norme : il est donc traité séparément (§6.2 et §14.6),
car il conditionne le comportement du logiciel.

### 1.3 Statut d'applicabilité et niveau d'intégrité retenu

La NF EN 50128:2011 s'applique aux **logiciels de commande et de protection
ferroviaires** participant à des fonctions de sécurité. Une application de quiz
n'exerce **aucune fonction de sécurité** au sens ferroviaire.

En conséquence :

* l'application de la norme ici est **volontaire** et **méthodologique** : elle
  fournit un cadre d'ingénierie (cycle en V, spécifications, V&V, règles de
  codage, gestion de configuration, traçabilité) ;
* le niveau d'intégrité de sécurité logicielle retenu est **SIL 2**, par
  décision de projet **D-001** du 24 octobre 2026 (cf. SRS-001 §3) ;
* **aucune allégation de conformité certifiée SIL 1 à SIL 4 ne peut être faite**
  pour ce produit : une telle allocation exigerait une analyse de risques
  système (EN 50126-1) et une évaluation indépendante (§6.2 de la norme). Le
  dossier **applique les exigences SIL 2** sans revendiquer que ce niveau est
  celui du produit.

> **Réserve majeure** : à SIL 2, le §5.1.2.11 h) impose que le Chargé de
> vérification et le Chargé de validation ne soient ni Gestionnaire des
> exigences, ni Concepteur, ni Réalisateur. Ce dossier est produit par un rôle
> unique : il est donc **techniquement complet mais organisationnellement
> incomplet** (non-conformité C-05, ouverte dans MATRICE-CONFORMITE).
>
> **Conséquence pratique** : les techniques retenues dans ARCH-001 §5 sont
> justifiées pour SIL 2, avec un durcissement supplémentaire sur les fonctions
> marquées C1 (§7.1) : elles portent l'essentiel des anomalies et devront être
> couvertes à 100 %.

---

## 2. Documents de référence

| Réf. | Titre | Usage dans ce document |
|---|---|---|
| [1] | NF EN 50128:2011, §4 | Objectifs, conformité, niveaux SIL |
| [2] | NF EN 50128:2011, §6.5 | Assurance qualité du logiciel, gestion de configuration |
| [3] | NF EN 50128:2011, §7.2 | Spécification des exigences du logiciel, tests d'ensemble |
| [4] | NF EN 50128:2011, §7.3 | Architecture, conception, interfaces (7.3.4.19), règles de codage (7.3.4.25) |
| [5] | NF EN 50128:2011, §7.5 / §7.6 / §7.7 | Vérification, intégration, validation |
| [6] | NF EN 50128:2011, §8.4 | Données et algorithmes d'application (contenu des quiz) |
| [7] | NF EN 50128:2011, Tableaux A.1 à A.23 | Techniques et mesures par SIL |
| [8] | `code_complet_quiz_game7 (1).pdf` | Source analysée |
| [9] | `legacy/baseline_v7/` | Baseline de code (référence des `fichier:ligne`) |

---

## 3. Méthode d'analyse et conventions

### 3.1 Méthode

1. **Lecture intégrale** des 39 fichiers (aucun échantillonnage).
2. **Analyse statique manuelle** : inventaire des symboles (classes,
   constructeurs, fabriques, méthodes, accesseurs, opérateurs, fonctions
   libres), extraction des dépendances.
3. **Analyse dynamique par lecture de flux** : reconstitution des séquences
   nominales et des chemins d'erreur, sans exécution (le projet n'a ni tests ni
   artefacts de build exploitables).
4. **Confrontation au référentiel** : chaque observation est rattachée à une
   clause ou à un tableau de la norme (§11).
5. **Traçabilité** : identifiants stables et univoques (§3.2).

### 3.2 Conventions d'identifiants

| Préfixe | Objet | Portée |
|---|---|---|
| `FON-P-xx` | Fonction de présentation (écrans, widgets, états d'IHM) | 37 |
| `FON-D-xx` | Fonction de domaine (modèles, règles, calculs) | 13 |
| `FON-S-xx` | Fonction de service (accès assets, persistance) | 14 |
| `FON-C-xx` | Fonction de configuration, démarrage, outillage build/CI | 23 |
| `EF-xx` | Exigence fonctionnelle (niveau produit) | 20 |
| `RG-xx` | Règle de gestion (niveau règle métier) | 12 |
| `ENF-xx` | Exigence non fonctionnelle | 12 |
| `IF-xx` | Interface (logicielle, matérielle, humaine) | 10 |
| `UC-xx` | Cas d'utilisation | 7 |
| `ANO-xx` | Anomalie / écart constaté | 22 |
| `CT-xx` | Cas de test à spécifier | 31 |

**Criticité** : `C1` = cœur métier (score, progression, intégrité des données),
`C2` = support (chargement, navigation, erreurs), `C3` = présentation/outillage
(aucun impact fonctionnel direct).

**Emplacement** : `fichier:ligne` renvoie à `legacy/baseline_v7/`, dont la
numérotation est identique à celle du PDF.

---

## 4. Description du système

### 4.1 Finalité et contexte d'utilisation

Application mobile **hors ligne**, à vocation éducative : l'utilisateur choisit
un thème religieux/culturel, progresse dans des niveaux débloqués
successivement, répond à des questions à choix unique sous contrainte de temps,
et cumule un score global.

| Élément | Description constatée |
|---|---|
| Plateforme | Android (projet Flutter ; `minSdk` forcé à 23 par la CI pour `audioplayers`) |
| Réseau | **Aucun** — aucune permission `INTERNET` dans le manifeste, contenu embarqué |
| Utilisateurs | Un seul utilisateur local, anonyme, non authentifié, non profilé |
| Données personnelles | **Aucune** (ni nom, ni identifiant, ni télémétrie) |
| Langue | Français, chaînes codées en dur |
| Persistance | `shared_preferences` (stockage clé/valeur local) |
| Contenu | 8 thèmes × N niveaux × M questions, en JSON dans les assets |

### 4.2 Frontière du logiciel

```
                        ┌──────────────────────────────────────────────┐
   Utilisateur          │            LOGICIEL « Quiz Game 7 »          │
  (tactile, lecture)    │                                              │
        │               │  ┌────────────────────────────────────────┐  │
        └──IF-01..04───►│  │ Couche présentation (16 widgets/écrans)│  │
                        │  └───────────────┬────────────────────────┘  │
                        │                  │ appels directs            │
                        │  ┌───────────────▼────────────────────────┐  │
                        │  │ Couche services (statique)             │  │
                        │  │ QuestionLoader / LevelManager /        │  │
                        │  │ ProfileManager                         │  │
                        │  └───────┬───────────────────┬────────────┘  │
                        │          │ IF-05             │ IF-06          │
                        └──────────┼───────────────────┼───────────────┘
                                   ▼                   ▼
                        ┌────────────────────┐  ┌─────────────────────┐
                        │ AssetBundle        │  │ SharedPreferences   │
                        │ assets/questions/  │  │ (stockage local     │
                        │ assets/backgrounds │  │  persistant)        │
                        └────────────────────┘  └─────────────────────┘
                                   │
                        Entrées système : IF-07 horloge/Timer,
                        IF-08 cycle de vie Android, IF-09 mémoire, IF-10 accessibilité
```

**Constat (ANO-02)** : il n'existe **aucune couche intermédiaire** entre l'IHM
et les services. Les écrans appellent directement `SharedPreferences` via des
méthodes statiques, exécutent le calcul du score et orchestrent la persistance.
La frontière est donc correcte, mais **l'architecture interne est plate**.

### 4.3 Modes de fonctionnement

| Mode | Déclencheur | Comportement |
|---|---|---|
| **M1 — Démarrage** | Lancement de l'app | `main()` → `WidgetsFlutterBinding.ensureInitialized()` → `QuizGameApp` → écran de sélection |
| **M2 — Exploration** | Sélection d'un thème | Chargement des niveaux, affichage liste verrouillée/déverrouillée |
| **M3 — Session de quiz** | Appui sur un niveau déverrouillé | Chargement des questions, chronomètre actif, une question à la fois |
| **M4 — Résultat** | Dernière question répondue ou expirée | Calcul du score, cumul, déverrouillage, revue des réponses |
| **M5 — Consultation du score** | Icône trophée | Lecture du score total, réinitialisation possible |
| **M6 — Erreur de contenu** | JSON absent / invalide / vide | Message d'erreur + bouton « Réessayer » ; aucune donnée partielle affichée |
| **M7 — Suspension** | App en arrière-plan | Chronomètre annulé ; reprise sans remise à zéro (le temps écoulé hors app n'est pas décompté — ANO-10) |
| **M8 — Abandon** | Bouton retour pendant une session | Sortie sans enregistrement du score ni de la progression (comportement non spécifié — ANO-15/§16) |

### 4.4 Inventaire et volumétrie

| Catégorie | Fichiers | Lignes |
|---|---|---|
| Modèles (`lib/models`) | 3 | 190 |
| Écrans (`lib/screens`) | 5 | 964 |
| Services (`lib/services`) | 4 | 291 |
| Widgets (`lib/widgets`) | 2 | 110 |
| Point d'entrée (`lib/main.dart`) | 1 | 35 |
| **Sous-total `lib/`** | **15** | **1 590** |
| Point d'entrée secondaire (`main.dart` racine) | 1 | 20 |
| **Total Dart (16 fichiers)** | **16** | **1 610** |
| Android / Gradle | 17 | ~450 |
| Scripts et CI (`.github`) | 3 | 661 |
| Configuration (`.gitignore`, `analysis_options.yaml`, `pubspec.yaml`) | 3 | 143 |
| **Total** | **39** | — |

---

## 5. Exigences fonctionnelles

### 5.1 Exigences fonctionnelles (niveau produit)

| ID | Exigence fonctionnelle | Fonctions porteuses | Criticité |
|---|---|---|---|
| **EF-01** | Le logiciel doit présenter les 8 thèmes disponibles sous forme de grille tactile (2 colonnes en dessous de 700 px de large, 4 au-delà). | FON-P-02, FON-P-04, FON-D-05 | C3 |
| **EF-02** | Le logiciel doit afficher le score total cumulé de l'utilisateur, valeur par défaut 0. | FON-P-26..30, FON-S-14 | C2 |
| **EF-03** | Le logiciel doit permettre la remise à zéro du score total, après confirmation explicite. | FON-P-29, FON-S-12 | C2 |
| **EF-04** | Le logiciel doit afficher, pour un thème, la liste des niveaux configurés avec leur état (verrouillé/déverrouillé) et le compteur « niveaux débloqués ». | FON-P-08, FON-P-11, FON-S-03 | C2 |
| **EF-05** | Le logiciel doit déverrouiller le niveau configuré suivant lorsqu'un niveau est terminé, et conserver cet état entre deux exécutions. | FON-P-20, FON-S-07 | **C1** |
| **EF-06** | Le logiciel doit permettre la réinitialisation de la progression d'un thème, après confirmation explicite. | FON-P-10, FON-S-06, FON-S-10 | C2 |
| **EF-07** | Le logiciel doit charger le référentiel de questions d'un niveau depuis les assets embarqués. | FON-P-17, FON-S-04 | **C1** |
| **EF-08** | Le logiciel doit rejeter toute question ne satisfaisant pas les invariants de validation (RG-01) et refuser d'afficher un niveau partiellement valide. | FON-D-01, FON-D-02, FON-S-04 | **C1** |
| **EF-09** | Le logiciel doit présenter les options de réponse dans un ordre aléatoire à chaque chargement. | FON-D-02 | C2 |
| **EF-10** | Le logiciel doit dérouler les questions séquentiellement, une seule à la fois, avec une progression affichée « Question i sur n ». | FON-P-23, FON-P-19 | **C1** |
| **EF-11** | Le logiciel doit imposer une durée maximale par question (10 s par défaut) et passer automatiquement à la suite à expiration. | FON-P-18, FON-P-16 | **C1** |
| **EF-12** | Le logiciel doit enregistrer la réponse choisie, ou l'absence de réponse en cas d'expiration, sans possibilité de modification. | FON-P-19 | **C1** |
| **EF-13** | Le logiciel doit calculer le score de la session : 1 point par réponse strictement égale à la bonne réponse. | FON-D-11 | **C1** |
| **EF-14** | Le logiciel doit ajouter le score de la session au score total persisté et restituer le nouveau total. | FON-P-20, FON-S-11 | **C1** |
| **EF-15** | Le logiciel doit restituer le résultat : score / nombre de questions, thème, niveau, niveau éventuellement débloqué, et la revue question par question. | FON-P-25 | C2 |
| **EF-16** | Le logiciel doit suspendre le chronomètre lorsque l'application passe en arrière-plan et le reprendre à la restauration, sans perte de l'état de la session. | FON-P-18 | C2 |
| **EF-17** | Le logiciel doit afficher un fond animé cyclant 3 images toutes les 10 s, avec repli sur une couleur unie en cas d'image absente. | FON-P-31..37 | C3 |
| **EF-18** | Le logiciel doit permettre la navigation : sélection → niveaux → quiz → résultat → niveaux, et le retour à la sélection. | FON-P-03, FON-P-09, FON-P-20 | C2 |
| **EF-19** | En cas d'erreur de chargement, le logiciel doit présenter un message compréhensible et un moyen de réessayer, sans état incohérent. | FON-P-13, FON-P-08, FON-P-28 | C2 |
| **EF-20** | Le logiciel doit conserver la progression entre deux exécutions et reprendre les données écrites par les versions antérieures (clés `levels__<Type>`). | FON-S-05..06, FON-S-08 | **C1** |

### 5.2 Règles de gestion

| ID | Règle | Source | Vérifiable par |
|---|---|---|---|
| **RG-01** | Une question est valide si : énoncé non vide ; bonne réponse non vide ; au moins 2 options ; aucune option vide ; aucune option dupliquée ; la bonne réponse figure **exactement** parmi les options (comparaison après `trim`, sensible à la casse/espaces internes). | `question.dart:13-38` | CT-05..CT-12 |
| **RG-02** | Le niveau 1 est toujours considéré comme déverrouillé. | `level_manager.dart:53`, `:105` | CT-16 |
| **RG-03** | Un niveau est déverrouillé si et seulement si le niveau configuré précédent a été **terminé** — aucun seuil de réussite n'est appliqué. | `level_manager.dart:63-93` | CT-18 |
| **RG-04** | Une seule réponse par question ; la réponse est définitive dès l'appui. | `quiz_screen.dart:108-128` | CT-21 |
| **RG-05** | À l'expiration du temps, la réponse vaut « aucune réponse » et rapporte 0 point. | `quiz_screen.dart:98-101` | CT-22 |
| **RG-06** | 1 point par bonne réponse ; comparaison stricte de chaînes. | `quiz_scoring.dart:4-10` | CT-24 |
| **RG-07** | Le score cumulé est non négatif et strictement croissant (ajout d'un score de session ≥ 0). | `profile_functions.dart:7-20` | CT-26 |
| **RG-08** | Durée par question = 10 s par défaut, paramétrable à la construction de l'écran. | `quiz_screen.dart:20` | CT-20 |
| **RG-09** | Un identifiant de thème est valide s'il correspond à `^[a-z0-9_-]+$` après `trim` + minuscules. | `question_loader.dart:17-23`, `level_manager.dart:4-11` | CT-13 |
| **RG-10** | Clés de persistance : `levels__<type>` (liste de niveaux, chaînes triées) et `total_score` (entier). | `level_manager.dart:9`, `profile_functions.dart:4` | CT-27 |
| **RG-11** | `levels.json` doit contenir une liste d'entiers ≥ 1, sans doublon, triée, commençant par 1. | `question_loader.dart:42-76` | CT-14 |
| **RG-12** | Les niveaux affichés proviennent exclusivement de `levels.json` ; un niveau listé sans fichier `level_N.json` provoque une erreur au lancement. | `question_loader.dart:78-90` | CT-15 |

### 5.3 Cas d'utilisation

| ID | Cas d'utilisation | Acteur | Séquence nominale | Exceptions |
|---|---|---|---|---|
| **UC-01** | Choisir un thème | Utilisateur | Sélection → grille → appui sur une carte → écran des niveaux | Aucune |
| **UC-02** | Consulter les niveaux | Utilisateur | Ouverture du thème → chargement `levels.json` → initialisation → affichage | M6 si JSON absent/invalide |
| **UC-03** | Jouer un niveau | Utilisateur | Appui sur un niveau déverrouillé → chargement des questions → questions chronométrées → résultat | M6 si contenu invalide ; M8 si abandon |
| **UC-04** | Consulter son score | Utilisateur | Icône trophée → lecture `total_score` → affichage | Erreur de lecture → message |
| **UC-05** | Réinitialiser son score | Utilisateur | Bouton → dialogue → confirmation → remise à 0 → rafraîchissement | Annulation |
| **UC-06** | Réinitialiser une progression | Utilisateur | Icône « restart » → dialogue → confirmation → suppression + réinitialisation → rechargement | Annulation ; erreur d'écriture |
| **UC-07** | Reprendre après suspension | Système | App en arrière-plan → annulation du timer → retour → reprise du décompte restant | Perte de temps non décomptée (ANO-10) |

---

## 6. Modèle de données

### 6.1 Entités

| Entité | Nature | Attributs | Invariants |
|---|---|---|---|
| `Question` | Immuable | `question`, `correctAnswer`, `options` (liste non modifiable) | RG-01 ; options non modifiables après construction |
| `QuizCategory` | Immuable, `const` | `id`, `label`, `description`, `icon` | `id` unique, stable, utilisé comme clé de préférence et nom de dossier d'assets |
| `UserProfile` | Muable (`score` non final) | `name`, `avatar`, `score` | `score ≥ 0` à la désérialisation ; **jamais instancié dans le code** (ANO-16) |
| `QuizContentException` | Exception | `message` | — |
| État de session (implicite) | Champs de `_QuizScreenState` | `_questions`, `_answers`, `_currentIndex`, `_timeLeft`, `_isLoading`, `_isFinishing`, `_errorMessage` | Aucun invariant formalisé — **écart** (§11) |

### 6.2 Format des données d'application

> Les blocs ci-dessous sont en notation illustrative : les commentaires `//`
> expliquent les variantes acceptées et **ne font pas partie du format réel**.

**`assets/questions/<theme>/levels.json`**

```json
{ "Levels": [1, 2, 3, 4] }        // clé "levels" également acceptée
```

Contraintes : objet JSON ; clé `Levels` ou `levels` ; liste ; éléments `int` ou
chaîne convertible ; valeur ≥ 1 ; pas de doublon ; après tri, premier = 1.

**`assets/questions/<theme>/level_<n>.json`**

```json
[
  {
    "question": "Énoncé…",          // alias accepté : "arabe"
    "correct": "Bonne réponse",     // alias accepté : "correctAnswer"
    "options": ["A", "B", "C"]      // doit contenir "correct"
  }
]
```

Contraintes cumulatives : liste non vide ; chaque élément objet ; application de
RG-01 ; la liste peut être dans n'importe quel ordre.

### 6.3 Persistance

| Clé | Type | Contenu | Valeur par défaut | Producteur | Consommateur |
|---|---|---|---|---|---|
| `levels__<type>` | `List<String>` | Niveaux déverrouillés, triés, sous forme de chaînes | `["1"]` | FON-S-06, FON-S-07, FON-S-10 | FON-S-08 |
| `levels__<Type>` | `List<String>` | **Héritage** : ancienne clé à capitalisation initiale (ex. `levels__Terme`) | — | (version antérieure) | FON-S-06 (migration), FON-S-09 |
| `total_score` | `int` | Score cumulé | `0` | FON-S-11 | FON-S-14 |

Aucune version de schéma, aucune somme de contrôle, aucune transaction : voir
ANO-06 et ANO-07.

---

## 7. Inventaire exhaustif des fonctions

### 7.1 Vue d'ensemble

| Couche | Nombre | Criticité C1 | C2 | C3 |
|---|---|---|---|---|
| Présentation (`FON-P`) | 37 | 5 | 13 | 19 |
| Domaine (`FON-D`) | 13 | 3 | 2 | 8 |
| Services (`FON-S`) | 14 | 6 | 7 | 1 |
| Configuration / démarrage / outillage (`FON-C`) | 23 | 0 | 9 | 14 |
| **Total** | **87** | **14** | **31** | **42** |

Les 14 fonctions C1 (cœur métier) sont : FON-P-08, P-17, P-18, P-19, P-20,
FON-D-01, D-02, D-11, FON-S-03, S-04, S-06, S-07, S-08 et S-11. Ce sont elles
qui portent l'essentiel des anomalies de robustesse et qui devront être
couvertes à 100 % des décisions.

### 7.2 Couche présentation — 37 fonctions

| ID | Fonction | Emplacement | Rôle | Entrées → Sorties / effets | Erreurs / cas limites | Crit. |
|---|---|---|---|---|---|---|
| FON-P-01 | `QuizGameApp.build` | `main.dart:13` | Construit `MaterialApp` (thème Material 3, AppBar, boutons 48 px) et monte l'écran de sélection | `context` → arbre de widgets | Aucune | C3 |
| FON-P-02 | `QuizTypeSelectionScreen.build` | `quiz_type_selection_screen.dart:25` | Grille responsive des 8 thèmes + entrée « scores » | `context` → arbre de widgets | Aucune | C3 |
| FON-P-03 | `_openScores` | `:10` | Navigue vers l'écran des scores | `context` → route empilée | Aucune | C2 |
| FON-P-04 | `_openCategory` | `:16` | Navigue vers la carte des niveaux du thème | `context`, `QuizCategory` → route | `id` non résolu → titre = `id` brut | C2 |
| FON-P-05 | `LevelMapScreen.createState` | `level_map_screen.dart:13` | Crée l'état de l'écran | — → `State` | Aucune | C3 |
| FON-P-06 | `_LevelMapScreenState._title` | `:23` | Libellé du thème, repli sur l'identifiant | — → `String` | Catégorie inconnue → `id` brut | C3 |
| FON-P-07 | `initState` (carte) | `:26` | Déclenche le chargement des niveaux | — → appel asynchrone | Aucune | C2 |
| FON-P-08 | `_loadLevels` | `:31` | Charge `levels.json`, initialise la progression, lit les niveaux déverrouillés, met à jour l'état | `quizType` → `_availableLevels`, `_unlockedLevels`, `_isLoading`, `_errorMessage` | Exception capturée → message brut (`:58`) ; `mounted` vérifié | **C1** |
| FON-P-09 | `_startLevel` | `:63` | Ouvre la session de quiz et recharge la carte si la session est terminée | `level` → route + `Future<bool>` | Retour `null` (abandon) → pas de rechargement | C2 |
| FON-P-10 | `_confirmReset` | `:76` | Dialogue de confirmation puis réinitialisation de la progression | — → reset + rechargement | `_availableLevels.last` sur liste vide → `StateError` (protégé par bouton désactivé) ; erreur → message | C2 |
| FON-P-11 | `_buildLevelList` | `:108` | Construit la liste : chargement, erreur + « Réessayer », vide, ou liste verrouillée/déverrouillée | état → widgets | Aucune | C3 |
| FON-P-12 | `build` (carte) | `:205` | Assemble l'écran, le compteur de progression et l'action de reset | `context` → arbre | Aucune | C3 |
| FON-P-13 | `QuizScreen.createState` | `quiz_screen.dart:27` | Crée l'état de session | — → `State` | Aucune | C3 |
| FON-P-14 | `_QuizScreenState._title` | `:41` | Libellé du thème | — → `String` | Catégorie inconnue → `id` brut | C3 |
| FON-P-15 | `initState` (quiz) | `:44` | Enregistre l'observateur de cycle de vie et lance le chargement | — → appel asynchrone | Aucune | C2 |
| FON-P-16 | `didChangeAppLifecycleState` | `:51` | Suspend le timer hors `resumed`, le reprend au retour sans remise à zéro | état d'application → timer | Reprise impossible si `_isFinishing` ; temps hors app non décompté | C2 |
| FON-P-17 | `_loadQuestions` | `:62` | Charge et valide les questions, initialise `_answers`, arme le timer | `quizType`, `niveau` → `_questions`, `_answers`, `_currentIndex`, `_timeLeft` | Exception → `_errorMessage` ; `mounted` vérifié ; `_startTimer` appelé hors `setState` | **C1** |
| FON-P-18 | `_startTimer({reset})` | `:93` | Arme un `Timer.periodic` de 1 s qui décrémente `_timeLeft` ; à 1 → 0 puis soumission nulle | `reset` → `_timeLeft`, callback | Double armement évité (`cancel`) ; dérive cumulative ; `secondsPerQuestion = 0` → division par zéro en aval | **C1** |
| FON-P-19 | `_submitAnswer` | `:108` | Enregistre la réponse, passe à la question suivante ou déclenche la fin | `String?` → `_answers[i]`, `_currentIndex`, `_isFinishing` | Ignorée si `_isFinishing`/`_isLoading`/liste vide ; pas de garde sur `_currentIndex` | **C1** |
| FON-P-20 | `_finishQuiz` | `:130` | Calcule le score, cumule le score, déverrouille le niveau suivant, navigue vers le résultat | `_questions`, `_answers` → écritures persistantes + route | Deux `try/catch` séparés → écritures partielles possibles ; erreurs agrégées en texte | **C1** |
| FON-P-21 | `dispose` (quiz) | `:169` | Retire l'observateur et annule le timer | — → libération | Aucune | C2 |
| FON-P-22 | `_buildMessage` | `:175` | Message centré (icône, texte, bouton « Réessayer » si erreur) | message, `isError` → widget | Aucune | C3 |
| FON-P-23 | `_buildQuiz` | `:207` | Assemble l'écran de question : progression, score courant, chrono, options | état → widgets | Index hors bornes si `_questions` vide (protégé en amont) | C2 |
| FON-P-24 | `build` (quiz) | `:304` | Sélectionne le corps : chargement / erreur / vide / quiz | état → arbre | Aucune | C3 |
| FON-P-25 | `ScoreScreen.build` | `score_screen.dart:26` | Restitue le score, le niveau débloqué, l'erreur de persistance et la revue des réponses | listes immuables → arbre | Aucune | C2 |
| FON-P-26 | `ScoresScreen.createState` | `scores_screen.dart:8` | Crée l'état | — → `State` | Aucune | C3 |
| FON-P-27 | `initState` (scores) | `:18` | Lance la lecture du score | — → appel asynchrone | Aucune | C2 |
| FON-P-28 | `_loadScore` | `:23` | Lit le score total et met à jour l'état | — → `_totalScore`, `_errorMessage` | Exception → message brut ; `mounted` vérifié | C2 |
| FON-P-29 | `_resetScore` | `:41` | Dialogue de confirmation puis remise à zéro | — → write `total_score = 0` | Échec → message préfixé ; `mounted` vérifié | C2 |
| FON-P-30 | `build` (scores) | `:74` | Affiche chargement / erreur / score + bouton de reset conditionnel | état → arbre | Aucune | C3 |
| FON-P-31 | `AnimatedBackground.build` | `animated_background.dart:18` | Empile `CyclingBackground` + voile sombre `0x660B1020` | `child` → widget | Aucune | C3 |
| FON-P-32 | `CyclingBackground.createState` | `cycling_background.dart:19` | Crée l'état | — → `State` | Aucune | C3 |
| FON-P-33 | `initState` (fond) | `:28` | Démarre le cycle d'images | — → timer | Aucune | C3 |
| FON-P-34 | `didUpdateWidget` | `:34` | Redémarre le cycle si images ou intervalle changent | ancien/nouvel widget → timer | Aucune | C3 |
| FON-P-35 | `_startCycle` | `:43` | `Timer.periodic(interval)` incrémentant l'index modulo la taille | — → `_currentIndex` | Aucun timer si `< 2` images ou intervalle nul | C3 |
| FON-P-36 | `dispose` (fond) | `:52` | Annule le timer | — → libération | Aucune | C3 |
| FON-P-37 | `build` (fond) | `:58` | Empile l'image courante (fondu 700 ms) et l'enfant ; repli couleur si image absente | état → widget | Image manquante → `ColoredBox` | C3 |

### 7.3 Couche domaine — 13 fonctions

| ID | Fonction | Emplacement | Rôle | Entrées → Sorties | Erreurs / cas limites | Crit. |
|---|---|---|---|---|---|---|
| FON-D-01 | `Question(...)` | `question.dart:3` | Construit une question et vérifie les 6 invariants de RG-01 | 3 paramètres → instance immuable | `ArgumentError.value` (6 cas) | **C1** |
| FON-D-02 | `Question.fromJson` | `:45` | Désérialise, gère les alias de clés, mélange les options | `Map` → `Question` | `FormatException` (type/clé absente) ; `ArgumentError` converti en `FormatException` | **C1** |
| FON-D-03 | `Question.toJson` | `:75` | Sérialise au format canonique (`correct`) | `Question` → `Map` | Aucune | C3 |
| FON-D-04 | `QuizCategory(...)` | `quiz_category.dart:5` | Construit une catégorie immuable | 4 paramètres → instance `const` | Aucune | C3 |
| FON-D-05 | `quizCategories` (donnée) + `quizCategoryForId` | `:19`, `:70` | Table des 8 thèmes ; résolution par identifiant normalisé | `id` → `QuizCategory?` | `null` si inconnu ; `id` vide → `null` | C2 |
| FON-D-06 | `UserProfile(...)` | `user_profile.dart:2` | Construit un profil | 3 paramètres → instance | Aucune | C3 |
| FON-D-07 | `UserProfile.fromJson` | `:14` | Désérialise, tolère `score` numérique ou chaîne, borne à ≥ 0 | `Map` → `UserProfile` | Valeurs absentes → défauts (`''`, 🙂, 0) | C3 |
| FON-D-08 | `UserProfile.toJson` | `:8` | Sérialise | instance → `Map` | Aucune | C3 |
| FON-D-09 | `UserProfile.==` | `:28` | Égalité structurelle sur `name` + `avatar` (**ignore `score`**) | deux objets → `bool` | Incohérence : deux profils de scores différents sont égaux | C3 |
| FON-D-10 | `UserProfile.hashCode` | `:33` | Hachage cohérent avec `==` | instance → `int` | Aucune | C3 |
| FON-D-11 | `calculateQuizScore` | `quiz_scoring.dart:4` | Compte les réponses exactes, borné par `min(len(questions), len(answers))` | 2 listes → `int` | **Silencieux** si les listes diffèrent en longueur (ANO-13) | **C1** |
| FON-D-12 | `calculateQuizAccuracy` | `:12` | Ratio score / nombre de questions | 2 listes → `double` | `0` si liste vide ; **jamais appelée** (ANO-16) | C3 |
| FON-D-13 | `QuizContentException.toString` | `question_loader.dart:13` | Rend le message exploitable par l'IHM | — → `String` | Aucune | C2 |

### 7.4 Couche services et accès aux données — 14 fonctions

| ID | Fonction | Emplacement | Rôle | Entrées → Sorties / effets | Erreurs / cas limites | Crit. |
|---|---|---|---|---|---|---|
| FON-S-01 | `QuestionLoader._normalizedQuizType` | `question_loader.dart:17` | Normalise et valide l'identifiant de thème (RG-09) | `String` → `String` | `ArgumentError` si non conforme | C2 |
| FON-S-02 | `QuestionLoader._loadJson` | `:25` | Lit une ressource et la décode en JSON | chemin → objet décodé | `FlutterError` → `QuizContentException` (fichier absent) ; `FormatException` → message dédié | C2 |
| FON-S-03 | `loadAvailableLevels` | `:42` | Charge et valide la liste des niveaux | `quizType` → `List<int>` triée | 5 motifs de `QuizContentException` | **C1** |
| FON-S-04 | `loadQuestions` | `:78` | Charge, valide et agrège les questions d'un niveau | `quizType`, `niveau` → `List<Question>` | `ArgumentError` si `niveau < 1` ; erreurs indexées par question ; liste vide refusée | **C1** |
| FON-S-05 | `LevelManager._keyFor` | `level_manager.dart:4` | Construit la clé de persistance (RG-10) | `quizType` → `String` | `ArgumentError` si identifiant non conforme | C2 |
| FON-S-06 | `initializeLevelsForQuiz` | `:13` | Initialise / normalise / migre la progression | `quizType`, `totalLevels` → écriture conditionnelle | `ArgumentError` si `totalLevels < 1` ; **écrit à chaque divergence de format** | **C1** |
| FON-S-07 | `unlockNextLevel` | `:63` | Débloque le niveau suivant et le retourne | niveau terminé, type, niveaux → `int?` | `null` si niveau inconnu, dernier, non déverrouillé ou `< 1` ; **retourne le niveau même s'il était déjà débloqué** (ANO-09) | **C1** |
| FON-S-08 | `getUnlockedLevels` | `:97` | Lit, filtre et trie les niveaux déverrouillés | `quizType` → `List<String>` | Valeurs non numériques ignorées ; liste vide → `["1"]` | **C1** |
| FON-S-09 | `resetProgressForQuiz` | `:110` | Supprime la clé canonique et les clés héritées | `quizType` → suppression | Aucune | C2 |
| FON-S-10 | `resetLevels` | `:126` | Compose suppression puis réinitialisation | `quizType`, `totalLevels` → état `["1"]` | Deux écritures non atomiques | C2 |
| FON-S-11 | `ProfileManager.updateScore` | `profile_functions.dart:7` | Lit, additionne et écrit le score total | `int ≥ 0` → nouveau total | `ArgumentError` si négatif ; **lecture-modification-écriture non atomique** | **C1** |
| FON-S-12 | `ProfileManager.resetScore` | `:22` | Écrit `total_score = 0` | — → écriture | Aucune | C2 |
| FON-S-13 | `ProfileManager.clearScore` | `:27` | Supprime la clé (retour au défaut) | — → suppression | **Jamais appelée** (ANO-16) | C3 |
| FON-S-14 | `ProfileManager.getTotalScore` | `:32` | Lit le score total | — → `int` | Défaut 0 ; aucune détection de corruption | C2 |

### 7.5 Configuration, démarrage et outillage — 23 fonctions

Ces fonctions ne sont pas exécutées sur le terminal cible (sauf `main`), mais
elles **conditionnent le produit livré**. À ce titre, elles relèvent du §6.5
(assurance qualité) et du Tableau A.1 item 26 (validation des outils) : un
défaut d'outillage peut produire un binaire non conforme.

| ID | Fonction | Emplacement | Rôle | Crit. |
|---|---|---|---|---|
| FON-C-01 | `main()` | `lib/main.dart:4` | Initialise le binding et lance `QuizGameApp` | C2 |
| FON-C-02 | `MyApp.build` | `main.dart:10` | Second point d'entrée, Material 2, **non utilisé par le build** (ANO-05) | C3 |
| FON-C-03 | `prepare_project.log` | `.github/scripts/prepare_project.py:55` | Trace console | C3 |
| FON-C-04 | `set_output` | `:59` | Écrit une sortie GitHub Actions | C2 |
| FON-C-05 | `add_summary` | `:67` | Écrit le récapitulatif de job | C3 |
| FON-C-06 | `has_dart_source` | `:74` | Détecte la présence de code Dart | C3 |
| FON-C-07 | `looks_like_project` | `:78` | Détecte un projet Flutter | C3 |
| FON-C-08 | `has_stray_main` | `:82` | Détecte un `main.dart` parasite à la racine | C2 |
| FON-C-09 | `walk_projects` | `:87` | Parcourt les projets candidats | C3 |
| FON-C-10 | `extract_archives` | `:99` | Extrait les archives poussées dans le dépôt | C3 |
| FON-C-11 | `locate_project` | `:116` | Localise la racine du projet | C2 |
| FON-C-12 | `_major` | `:129` | Extrait la version majeure d'une contrainte SDK | C3 |
| FON-C-13 | `fix_dart_constraint` | `:134` | Corrige la contrainte SDK Dart du `pubspec` | C2 |
| FON-C-14 | `ensure_version` | `:148` | Ajoute une version si absente | C3 |
| FON-C-15 | `prune_assets` | `:162` | Supprime les entrées d'assets absentes et les doublons (réécrit `pubspec.yaml`) | C2 |
| FON-C-16 | `read_field` | `:209` | Lit un champ YAML simple | C3 |
| FON-C-17 | `explain_missing` | `:214` | Explique l'absence de projet | C3 |
| FON-C-18 | `main()` (préparation) | `:265` | Orchestration complète de la préparation | C2 |
| FON-C-19 | `fix_android_config.normalize` | `fix_android_config.py:29` | Normalise une clé Gradle | C3 |
| FON-C-20 | `find_gradle_file` | `:33` | Localise le fichier Gradle du module | C3 |
| FON-C-21 | `patch` | `:41` | Applique des remplacements ciblés | C2 |
| FON-C-22 | `replace` (interne) | `:48` | Substitution regex unitaire | C3 |
| FON-C-23 | `main()` (fix Android) | `:80` | Applique la configuration Android | C2 |

### 7.6 Fiches détaillées des fonctions critiques (C1)

**FON-P-19 — `_submitAnswer(String? answer)`** · `quiz_screen.dart:108-128`

| | |
|---|---|
| **Rôle** | Consommer la réponse de l'utilisateur et faire avancer la machine de session. |
| **Entrées** | `answer` : texte d'une option, ou `null` en cas d'expiration. |
| **Préconditions** | `!_isFinishing` ∧ `!_isLoading` ∧ `_questions` non vide ∧ `0 ≤ _currentIndex < _questions.length`. |
| **Traitement** | 1) garde ; 2) annulation du timer ; 3) `_answers[_currentIndex] = answer` ; 4) si dernière question → `_isFinishing = true`, sinon incrément `_currentIndex` et remise à zéro du temps ; 5) `_finishQuiz()` (non attendu) ou réarmement du timer. |
| **Postconditions** | Exactement une écriture dans `_answers[i]` ; `_currentIndex` strictement croissant ou session close ; timer actif si et seulement si session ouverte. |
| **Effets de bord** | `setState`, annulation/armement de timer, lancement asynchrone de la persistance. |
| **Modes d'erreur** | Appel hors séquence ignoré silencieusement (pas de trace) ; **aucune validation que `answer` appartient bien à `question.options`** — l'API accepte n'importe quelle chaîne, ce qui rend la règle RG-04 non vérifiable à la frontière (écart d'interface, §10). |
| **Exigences** | EF-10, EF-12, RG-04. |
| **Tests à spécifier** | CT-20 à CT-23. |

**FON-P-20 — `_finishQuiz()`** · `quiz_screen.dart:130-166`

| | |
|---|---|
| **Rôle** | Clore la session : calcul, persistance, déverrouillage, navigation. |
| **Entrées** | `_questions`, `_answers`, `widget.niveau`, `widget.quizType`, `widget.availableLevels`. |
| **Préconditions** | Toutes les réponses ont été traitées ; `_isFinishing = true`. |
| **Traitement** | `calculateQuizScore` → `ProfileManager.updateScore` (try/catch) → `LevelManager.unlockNextLevel` (try/catch) → `pushReplacement` vers `ScoreScreen` avec `result: true`. |
| **Postconditions** | Score cumulé augmenté **ou** erreur consignée ; niveau suivant déverrouillé **ou** erreur consignée ; écran de résultat affiché ; la route de quiz est remplacée (retour impossible). |
| **Modes d'erreur** | **Deux transactions indépendantes** : si la seconde échoue, le score est enregistré mais pas la progression (état incohérent, ANO-06) ; si les deux échouent, l'utilisateur voit un message agrégé en texte brut ; `mounted` non vérifié avant `pushReplacement` si le dialogue de permission système est apparu entre-temps (risque faible). |
| **Exigences** | EF-05, EF-13, EF-14, EF-18, RG-03, RG-06. |
| **Tests** | CT-24 à CT-27. |

**FON-P-18 — `_startTimer({bool reset})`** · `quiz_screen.dart:93-106`

| | |
|---|---|
| **Rôle** | Décompter le temps restant et provoquer l'expiration. |
| **Entrées** | `reset` (vrai à chaque nouvelle question, faux à la reprise après suspension). |
| **Traitement** | `Timer.periodic(1 s)` : si `_timeLeft ≤ 1` → annule, met 0, soumet `null` ; sinon décrémente. |
| **Postconditions** | Un seul timer actif ; `_timeLeft ∈ [0, secondsPerQuestion]`. |
| **Modes d'erreur** | Dérive cumulative (le décompte n'est pas ancré sur une horloge) ; reprise après suspension sans compensation du temps écoulé (ANO-10, ANO-11) ; `secondsPerQuestion = 0` accepté en release (assert désactivé, ANO-12) → division `0/0` dans `_buildQuiz:210` → `NaN` propagé à `LinearProgressIndicator`. |
| **Exigences** | EF-11, EF-16, RG-05, RG-08. |
| **Tests** | CT-20 à CT-22, CT-31. |

**FON-S-07 — `unlockNextLevel(...)`** · `level_manager.dart:63-93`

| | |
|---|---|
| **Rôle** | Décider et appliquer le déverrouillage du niveau suivant. |
| **Entrées** | `completedLevel`, `quizType`, `availableLevels` (liste triée fournie par l'appelant). |
| **Traitement** | Filtre > 0, dédoublonne, trie ; `indexOf(completedLevel)` ; refuse si inconnu ou dernier ; vérifie que le niveau terminé **est** déverrouillé ; calcule `nextLevel` ; écrit la liste triée si absent ; retourne `nextLevel`. |
| **Postconditions** | `levels__<type>` contient `nextLevel` ; retour = niveau suivant ou `null`. |
| **Modes d'erreur** | Retourne `nextLevel` **même si déjà déverrouillé** → l'IHM annonce un déverrouillage qui n'a pas eu lieu (ANO-09) ; **aucun seuil de réussite** : terminer avec 0/10 déverrouille (RG-03, à valider) ; dépend de la validité de `availableLevels` fournie par l'IHM (couplage). |
| **Exigences** | EF-05, EF-20, RG-03. |
| **Tests** | CT-16 à CT-19. |

**FON-S-06 — `initializeLevelsForQuiz(...)`** · `level_manager.dart:13-61`

| | |
|---|---|
| **Rôle** | Garantir un état de progression valide, migrer l'héritage, normaliser. |
| **Entrées** | `quizType`, `totalLevels` (défaut 10). |
| **Traitement** | Construit la clé canonique ; recherche l'ancienne clé capitalisée si absente ; **supprime** la clé héritée si trouvée ; filtre et borne les niveaux à `[1, totalLevels]` ; force 1 ; trie ; réécrit si divergence. |
| **Postconditions** | La clé canonique existe, contient au moins `"1"`, est triée, sans doublon, dans les bornes. |
| **Modes d'erreur** | Écriture à **chaque** divergence de format (bruit d'écriture) ; migration destructive (la clé héritée est supprimée avant que l'écriture canonique ne soit confirmée) → perte de progression si l'écriture échoue (ANO-06 étendu) ; `totalLevels` issu de `_availableLevels.last` côté IHM. |
| **Exigences** | EF-05, EF-06, EF-20, RG-02, RG-11. |
| **Tests** | CT-16, CT-17, CT-28, CT-29. |

**FON-D-01 — `Question(...)`** · `question.dart:3-39`

| | |
|---|---|
| **Rôle** | Porter les invariants de contenu (RG-01) au plus près de la donnée. |
| **Traitement** | `trim` sur l'énoncé et la bonne réponse ; `trim` sur chaque option ; liste rendue non modifiable ; 6 contrôles. |
| **Postconditions** | Objet immuable dont tous les invariants sont vrais. |
| **Modes d'erreur** | 6 `ArgumentError` distincts ; **aucune borne haute** (nombre d'options, longueur des textes) ; la comparaison de la bonne réponse est sensible à la casse et aux espaces internes (comportement volontaire mais non spécifié). |
| **Exigences** | EF-08, RG-01. |
| **Tests** | CT-05 à CT-12. |

**FON-D-11 — `calculateQuizScore(...)`** · `quiz_scoring.dart:4-10`

| | |
|---|---|
| **Rôle** | Seule fonction de calcul du score (référence unique). |
| **Traitement** | Boucle bornée par `i < questions.length && i < answers.length` ; incrémente si `answers[i] == questions[i].correctAnswer`. |
| **Postconditions** | `0 ≤ score ≤ min(nb questions, nb réponses)`. |
| **Modes d'erreur** | Troncature **silencieuse** si `answers` est plus court que `questions` (ANO-13) : un défaut de séquencement produirait un score faux sans signalement. |
| **Exigences** | EF-13, RG-06. |
| **Tests** | CT-24, CT-25. |

---

## 8. Comportements dynamiques

### 8.1 Machine à états de la session de quiz

| État | Invariant | Événement | Transition | Action |
|---|---|---|---|---|
| `E0 CHARGEMENT` | `_isLoading = true`, timer inactif | succès du chargement | `E1 QUESTION` | `_answers` initialisé, `_timeLeft = 10`, timer armé |
| `E0 CHARGEMENT` | — | échec | `E5 ERREUR` | `_errorMessage` renseigné |
| `E1 QUESTION` | `1 ≤ i+1 ≤ n`, timer actif | appui sur une option | `E2 REPONDU` ou `E3 TERMINE` | réponse écrite, timer annulé |
| `E1 QUESTION` | — | expiration (`_timeLeft → 0`) | `E2`/`E3` | réponse `null` écrite |
| `E1 QUESTION` | — | mise en arrière-plan | `E4 SUSPENDU` | timer annulé |
| `E4 SUSPENDU` | état conservé | retour au premier plan | `E1 QUESTION` | timer réarmé **sans** reset |
| `E2 REPONDU` | `i` incrémenté | immédiat | `E1 QUESTION` | `_timeLeft = 10`, timer armé |
| `E3 TERMINE` | `_isFinishing = true` | — | `E6 PERSISTANCE` | `_finishQuiz()` |
| `E6 PERSISTANCE` | — | succès/échec partiel | `E7 RESULTAT` | navigation `pushReplacement` |
| `E5 ERREUR` | timer inactif | « Réessayer » | `E0` | rechargement |
| tout état | — | abandon (retour) | `E8 SORTIE` | timer annulé, **aucune persistance** |

**Constats** : la machine est **implicite** (booléens et champs d'état non
exclusifs), non formalisée, et les transitions illégales ne sont pas tracées.
L'état `E8` (abandon) n'est pas spécifié fonctionnellement.

### 8.2 Séquence nominale de fin de niveau

```
Utilisateur        QuizScreen            ProfileManager      LevelManager        ScoreScreen
    │                  │                      │                  │                  │
    │ appui option     │                      │                  │                  │
    ├─────────────────►│ _submitAnswer        │                  │                  │
    │                  │ (dernière question)  │                  │                  │
    │                  │ _finishQuiz          │                  │                  │
    │                  ├─────────────────────►│ updateScore      │                  │
    │                  │                      ├─ read total      │                  │
    │                  │                      ├─ write total     │                  │
    │                  │◄─────────────────────┤                  │                  │
    │                  ├────────────────────────────────────────►│ unlockNextLevel  │
    │                  │                                          ├─ read levels    │
    │                  │                                          ├─ write levels   │
    │                  │◄─────────────────────────────────────────┤ (int?)           │
    │                  ├────────────────────────────────────────────────────────────►│
    │                  │            pushReplacement(result: true)                    │
    │◄─────────────────┴──────────────────────────────────────────────────────────────┤
```

Points de défaillance : les deux appels sont **indépendants** ; une erreur sur
le second laisse un état persistant partiel, simplement signalé en texte.

### 8.3 Graphe de navigation

```
QuizTypeSelection ──► Scores
        │
        ▼
    LevelMap ──(push)──► Quiz ──(pushReplacement)──► Score
        ▲                                              │
        └────────────────(pop, retour = true)──────────┘
```

Note : `pushReplacement(..., result: true)` complète immédiatement le `Future`
attendu par `LevelMap._startLevel`, qui recharge alors la carte **avant** que
l'utilisateur n'ait lu le résultat (comportement correct mais peu lisible).

---

## 9. Interfaces

L'exigence §7.3.4.19 de la norme impose, pour chaque interface : pré/post
conditions, valeurs limites, comportement aux limites et hors limites, gestion
des exceptions, et classes d'équivalence. Le tableau ci-dessous établit l'état
constaté.

| ID | Interface | Sens | Précondition | Valeurs limites | Hors limites | Exceptions | État |
|---|---|---|---|---|---|---|---|
| **IF-01** | Tactile : cartes de thème | U → L | Écran affiché | 8 éléments | Aucune | — | Non spécifié (pas de test tactile) |
| **IF-02** | Tactile : lignes de niveau | U → L | Niveau déverrouillé | 1..N | Appui sur verrouillé → ignoré (`enabled: false`) | — | Correct mais non testé |
| **IF-03** | Tactile : boutons de réponse | U → L | `!_isFinishing` | 2..M options | Appui après fin → bouton désactivé | — | **Pas de contrôle d'appartenance** de la réponse aux options |
| **IF-04** | Tactile : dialogues de confirmation | U → L | — | 2 boutons | Fermeture par retour → `null` → annulation | — | Correct |
| **IF-05** | `AssetBundle.loadString` | L → assets | Chemin déclaré dans `pubspec` | Fichier présent, JSON valide | Absent → `FlutterError` ; invalide → `FormatException` | Converties en `QuizContentException` | Correct, mais messages hétérogènes |
| **IF-06** | `SharedPreferences` | L ↔ stockage | Instance obtenue | Type attendu (`int`, `List<String>`) | Type inattendu → `null`/`CastError` non gérée | **Aucune** | **Non robuste**, pas de version de schéma (ANO-07) |
| **IF-07** | `Timer` / horloge | système → L | — | 1 s | Dérive, suspension | Aucune | **Non ancré sur une horloge monotone** (ANO-11) |
| **IF-08** | Cycle de vie Android | système → L | Observateur enregistré | `resumed` / autres | Aucun traitement de `detached` | — | Partiel (ANO-10) |
| **IF-09** | Mémoire / images | système → L | Assets présents | 3 images | Image absente → `errorBuilder` | Repli couleur | Correct |
| **IF-10** | Accessibilité | L → lecteur d'écran | — | `Semantics` sur le chrono uniquement | Aucun libellé sur les options ni sur la progression | — | **Insuffisant** (ANO-20) |

---

## 10. Exigences non fonctionnelles

| ID | Exigence | État constaté | Écart |
|---|---|---|---|
| **ENF-01** | Temps de réponse : changement de question ≤ 100 ms ; démarrage ≤ 2 s ; pas de saccade pendant le chrono | Non mesuré ; timer de 1 s compétitif avec le rendu | Non vérifié (Tableau A.18 non appliqué) |
| **ENF-02** | Robustesse : aucune exception non capturée, quel que soit le contenu | `QuizContentException` couvre les cas nominaux ; **types inattendus** dans les préférences non couverts | Partiel (ANO-07) |
| **ENF-03** | Intégrité des données persistées : détection et refus des valeurs corrompues | Aucune somme de contrôle, aucun versionnement, filtrage partiel | **Non satisfait** (ANO-07) |
| **ENF-04** | Maintenabilité : fonctions ≤ 30 lignes, complexité cyclomatique ≤ 10, fichiers ≤ 200 lignes | `quiz_screen.dart` = 320 lignes, `_buildQuiz` ≈ 95 lignes, `_LevelMapScreenState.build` complexe | **Non satisfait** (Tableau A.12 #8) |
| **ENF-05** | Testabilité : cœur métier testable sans IHM ni plugin | Calcul du score testable ; persistance, chargement, timer et aléa **non injectables** | **Non satisfait** (ANO-03) |
| **ENF-06** | Portabilité : Android API 23+, écrans 320→1024 dp, portrait/paysage | Grille responsive ; pas de test paysage ; `minSdk` issu de `flutter.minSdkVersion` | Partiel |
| **ENF-07** | Utilisabilité / accessibilité : cibles ≥ 48 dp, contraste, lecteur d'écran | Boutons ≥ 48 px ; contraste non vérifié ; `Semantics` quasi absent | Partiel (ANO-20) |
| **ENF-08** | Traçabilité : chaque exigence reliée à ses fonctions et à ses tests | **Aucune** | **Non satisfait** ; ce document l'établit (§13) |
| **ENF-09** | Déterminisme : une même session rejouée avec la même graine produit le même ordre | `Random()` non graine, appelé par question | **Non satisfait** (ANO-04) |
| **ENF-10** | Confidentialité : aucune donnée personnelle, aucun accès réseau | Aucune permission réseau, aucune donnée personnelle | **Satisfait** |
| **ENF-11** | Observabilité : journalisation structurée des erreurs, sans fuite technique vers l'utilisateur | `error.toString()` affiché ; aucune journalisation | **Non satisfait** (ANO-14) |
| **ENF-12** | Capacité : 1 ≤ questions par niveau ≤ 50 ; 1 ≤ niveaux par thème ≤ 99 | Aucune borne haute contrôlée | Partiel |

---

## 11. Synthèse des écarts et anomalies (ANO-01 à ANO-23)

Gravité : **B** = bloquant pour une démarche conforme, **M** = majeur,
**m** = mineur. La colonne « Réf. » renvoie à la NF EN 50128:2011.

| ID | Anomalie | Gravité | Preuve | Réf. |
|---|---|---|---|---|
| **ANO-01** | Aucun test automatisé, aucun jeu de tests, aucun rapport de vérification | **B** | Absence de dossier `test/` dans les 39 fichiers | §7.5, Tableau A.1 (7, 12, 16, 19) |
| **ANO-02** | Logique métier et orchestration dans les widgets : l'IHM appelle directement la persistance, calcule et décide | **B** | `quiz_screen.dart:108-166`, `level_map_screen.dart:31-106` | §7.3.4.22 (décomposition en composants), Tableau A.3 #22 |
| **ANO-03** | Aucune injection de dépendance : `SharedPreferences`, `rootBundle` et `Random` sont atteints statiquement | **B** | `profile_functions.dart:16`, `question_loader.dart:27`, `question.dart:62` | §7.5 (testabilité), Tableau A.4 #7 |
| **ANO-04** | Non-déterminisme : `Random()` sans graine pour mélanger les options | **M** | `question.dart:62` | ENF-09, Tableau A.13 |
| **ANO-05** | Deux points d'entrée, dont un mort (`MyApp`, Material 2, sans `ensureInitialized`) | **M** | `main.dart:1-20` vs `lib/main.dart:1-35` | §6.5 (gestion de configuration) |
| **ANO-06** | Persistance non atomique : score et déverrouillage = 2 écritures ; migration destructive de la clé héritée | **M** | `quiz_screen.dart:130-152`, `level_manager.dart:36-42` | §7.3.4.23 g), ENF-03 |
| **ANO-07** | Aucune détection d'erreur ni version de schéma sur les données persistées | **M** | `level_manager.dart:97-108` | Tableau A.3 #4 (codes de détection), §7.3.4.19 f) |
| **ANO-08** | `_availableLevels.last` sans garde dans `_confirmReset` | **m** | `level_map_screen.dart:99` | §7.3.4.19 b) |
| **ANO-09** | `unlockNextLevel` retourne un niveau déjà débloqué → message « Niveau X débloqué ! » erroné | **M** | `level_manager.dart:92`, `score_screen.dart:59-62` | EF-05, RG-03 |
| **ANO-10** | Temps passé en arrière-plan non décompté : le chrono peut être contourné | **M** | `quiz_screen.dart:51-60` | EF-11, ENF-03 |
| **ANO-11** | Décrément par `Timer.periodic` au lieu d'une échéance absolue → dérive cumulative | **M** | `quiz_screen.dart:93-106` | Tableau A.18 #2 (contraintes de temps) |
| **ANO-12** | `assert` (debug uniquement) pour valider `secondsPerQuestion` → en release, 0 accepté → `0/0 = NaN` dans la barre de temps | **M** | `quiz_screen.dart:20`, `:210`, `:248` | §7.3.4.19 (valeurs limites) |
| **ANO-13** | Troncature silencieuse si les listes de questions et de réponses diffèrent | **m** | `quiz_scoring.dart:5` | Tableau A.3 #2 (diagnostic) |
| **ANO-14** | Messages d'erreur techniques affichés bruts (`error.toString()`) ; aucune taxonomie | **M** | `level_map_screen.dart:58`, `quiz_screen.dart:88`, `scores_screen.dart:36` | §7.3.4.23 g), ENF-11 |
| **ANO-15** | Aucune règle de réussite : 0/10 déverrouille le niveau suivant ; abandon de session non spécifié | **M** | `level_manager.dart:63-93` | §7.2.4.4 (exigences non ambiguës) |
| **ANO-16** | Code mort : `UserProfile` (34 l.), `calculateQuizAccuracy`, `clearScore`, `MyApp` | **m** | fichiers cités | Tableau A.4 #7 (programmes analysables) |
| **ANO-17** | `pubspec.yaml` : assets dupliqués (`arabe/level_3` ×2, `general/level_1` ×3) et redondants avec `assets/questions/` ; les doublons sont **supprimés à la volée** par `prune_assets` au lieu d'être corrigés dans la source | **m** | `pubspec.yaml:42-58` | §6.5 |
| **ANO-18** | `audioplayers` déclaré, sons présents, **jamais utilisés** → dépendance et surface de risque inutiles | **m** | `pubspec.yaml:13` ; aucun import | Tableau A.15 (justification des dépendances) |
| **ANO-19** | `arabe/level_2.json` absent alors que `level_3` est déclaré (à confirmer avec `levels.json`) | **M** | `pubspec.yaml:42-44` | EF-07, RG-12 |
| **ANO-20** | Internationalisation absente (FR en dur), accessibilité limitée à un `Semantics` | **m** | `quiz_screen.dart:245`, tous les écrans | ENF-07 |
| **ANO-21** | Aucune analyse statique bloquante ni test dans la CI ; build release **signé avec la clé de debug** | **M** | `.github/workflows/build-apk.yml` ; `android/app/build.gradle.kts:33-34` | §6.5, §9 (déploiement) |
| **ANO-22** | Deux `MainActivity` dans deux packages (`quiz_game`, `quiz_game7`) : la seconde est morte ; `namespace` et `applicationId` restent `com.example.quiz_game` | **m** | `android/.../kotlin/...` | §6.5 |
| **ANO-23** | **Le build réécrit la source** : `prepare_project.py` modifie `pubspec.yaml` (contrainte SDK, assets), `fix_android_config.py` modifie minSdk/compileSdk, et `pubspec.lock` est **supprimé** si la résolution échoue (« versions plus récentes ») → l'artefact n'est pas construit à partir de l'état commité, donc non reproductible | **M** | `.github/scripts/prepare_project.py:134-208`, `.github/scripts/fix_android_config.py:41-78`, `.github/workflows/build-apk.yml:88-96` | §6.5, Tableau A.1 #3 |

**Bilan** : 23 anomalies — 3 bloquantes (ANO-01, ANO-02, ANO-03), 13 majeures,
7 mineures. Les bloquantes sont toutes de **processus** (absence de tests,
logique métier dans l'IHM, absence d'injection de dépendance) : elles ne se
corrigent pas par des rustines locales, mais par la refonte en couches décrite
au §14. Aucune vulnérabilité de sécurité applicative n'est constatée (pas de
réseau, pas de données personnelles).

---

## 12. Stratégie de vérification à définir (aperçu)

La norme exige que les tests soient **spécifiés avant** l'exécution
(§7.2.4.16, §7.5.4). Les 31 cas ci-dessous constituent le squelette du futur
document « Spécification de Tests ».

| ID | Objet | Technique (Tableau A.13/A.14) | Fonctions couvertes |
|---|---|---|---|
| CT-01 | Démarrage nominal | Boîte noire | FON-C-01, FON-P-01 |
| CT-02 | Affichage des 8 thèmes, 2 colonnes < 700 px | Valeurs limites (largeur) | FON-P-02 |
| CT-03 | Ouverture d'un thème connu / inconnu | Classes d'équivalence | FON-D-05, FON-P-04, FON-P-06 |
| CT-04 | Navigation scores ↔ sélection ↔ niveaux | Boîte noire | FON-P-03, FON-P-09 |
| CT-05 | Question valide (2 options) | Valeurs limites | FON-D-01 |
| CT-06 | Question avec 1 option | Valeurs limites | FON-D-01 |
| CT-07 | Option vide / espaces seuls | Classes d'équivalence | FON-D-01 |
| CT-08 | Options dupliquées | Classes d'équivalence | FON-D-01 |
| CT-09 | Bonne réponse absente des options | Classes d'équivalence | FON-D-01 |
| CT-10 | Énoncé vide / bonne réponse vide | Valeurs limites | FON-D-01 |
| CT-11 | Alias `arabe` / `correctAnswer` | Boîte noire | FON-D-02 |
| CT-12 | Types JSON incorrects (options non-listes, nombres) | Supposition d'erreurs | FON-D-02, FON-S-04 |
| CT-13 | Identifiants de thème : `""`, `"Arabe"`, `"a b"`, `"a/../b"` | Valeurs limites / sécurité | FON-S-01, FON-S-05 |
| CT-14 | `levels.json` : vide, doublons, non trié, sans 1, valeurs < 1, chaînes | Analyse de valeurs aux limites | FON-S-03 |
| CT-15 | Fichier `level_N.json` absent, vide, non-liste | Supposition d'erreurs | FON-S-04, EF-19 |
| CT-16 | Première ouverture d'un thème → `["1"]` | Boîte noire | FON-S-06, FON-S-08 |
| CT-17 | Migration d'une clé héritée `levels__Terme` | Boîte noire | FON-S-06 |
| CT-18 | Déverrouillage du niveau suivant (nominal) | Boîte noire | FON-S-07 |
| CT-19 | Déverrouillage : dernier niveau, niveau non déverrouillé, niveau inconnu, déjà débloqué (ANO-09) | Valeurs limites | FON-S-07 |
| CT-20 | Session 1 question, réponse correcte | Boîte noire | FON-P-19, FON-D-11 |
| CT-21 | Double appui rapide sur deux options (une seule prise en compte) | Course / robustesse | FON-P-19 |
| CT-22 | Expiration du temps → `null`, 0 point | Boîte noire | FON-P-18, RG-05 |
| CT-23 | Retour arrière en cours de session (abandon) | Boîte noire | EF-18, M8 |
| CT-24 | Score : 0/n, n/n, partiel ; listes de longueurs différentes (ANO-13) | Classes d'équivalence | FON-D-11 |
| CT-25 | Comparaison stricte : casse, espaces internes, accents | Valeurs limites | FON-D-11, RG-06 |
| CT-26 | Cumul : 0, positif, valeur négative refusée | Valeurs limites | FON-S-11 |
| CT-27 | Score plafond / corruption de la valeur stockée | Supposition d'erreurs | FON-S-14, ANO-07 |
| CT-28 | Reset progression : confirmation, annulation, erreur d'écriture | Boîte noire | FON-P-10, FON-S-10 |
| CT-29 | Reset score : bouton masqué à 0, confirmation, erreur | Boîte noire | FON-P-29, FON-S-12 |
| CT-30 | Cycle de vie : arrière-plan puis retour (temps restant) | Boîte noire | FON-P-16 |
| CT-31 | `secondsPerQuestion = 0` / négatif (ANO-12) | Valeurs limites | FON-P-18 |

**Couverture visée** : 100 % des décisions sur les fonctions C1, ≥ 90 % des
instructions sur le domaine, 100 % des exigences EF-01 à EF-20 couvertes par au
moins un cas.

---

## 13. Matrice de traçabilité (extrait)

| Exigence | Fonctions | Tests | Anomalies liées |
|---|---|---|---|
| EF-01 | FON-P-02, FON-P-04, FON-D-05 | CT-02, CT-03 | ANO-20 |
| EF-02 | FON-P-26..30, FON-S-14 | CT-04, CT-27 | ANO-07, ANO-14 |
| EF-03 | FON-P-29, FON-S-12 | CT-29 | ANO-14 |
| EF-04 | FON-P-08, FON-P-11, FON-S-03 | CT-14 | ANO-08 |
| EF-05 | FON-P-20, FON-S-07 | CT-18, CT-19 | ANO-09, ANO-15 |
| EF-06 | FON-P-10, FON-S-06, FON-S-10 | CT-28 | ANO-06 |
| EF-07 | FON-P-17, FON-S-04 | CT-15 | ANO-19 |
| EF-08 | FON-D-01, FON-D-02, FON-S-04 | CT-05..CT-12 | — |
| EF-09 | FON-D-02 | CT-11 | ANO-04 |
| EF-10 | FON-P-19, FON-P-23 | CT-20 | ANO-13 |
| EF-11 | FON-P-18, FON-P-16 | CT-22, CT-30, CT-31 | ANO-10, ANO-11, ANO-12 |
| EF-12 | FON-P-19 | CT-21 | — |
| EF-13 | FON-D-11 | CT-24, CT-25 | ANO-13 |
| EF-14 | FON-P-20, FON-S-11 | CT-26 | ANO-06 |
| EF-15 | FON-P-25 | CT-04 | ANO-09 |
| EF-16 | FON-P-16 | CT-30 | ANO-10 |
| EF-17 | FON-P-31..37 | CT-01 (visuel) | — |
| EF-18 | FON-P-03, FON-P-09, FON-P-20 | CT-04, CT-23 | — |
| EF-19 | FON-P-13, FON-P-08, FON-P-28 | CT-15 | ANO-14 |
| EF-20 | FON-S-05, FON-S-06, FON-S-08 | CT-16, CT-17 | ANO-06, ANO-07 |

---

## 14. Cible de refonte proposée

### 14.1 Principes directeurs

1. **Séparer le cœur métier de l'infrastructure** : le domaine ne connaît ni
   Flutter, ni `SharedPreferences`, ni `Random`.
2. **Inverser les dépendances** : horloge, aléa, stockage et chargement de
   contenu deviennent des interfaces injectées et remplaçables en test.
3. **Rendre les états explicites** : une machine à états formelle remplace les
   booléens dispersés.
4. **Rendre les erreurs typées** : taxonomie fermée, messages utilisateur
   distincts des messages techniques.
5. **Rendre les écritures cohérentes** : un seul enregistrement versionné et
   contrôlé par somme de contrôle, écrit en une seule opération.
6. **Rendre le temps déterministe** : échéance absolue calculée sur une horloge
   monotone injectée.
7. **Traiter le contenu comme une donnée d'application** (§8.4) : schéma
   formel, validateur, jeu d'essai, revue indépendante.

### 14.2 Architecture cible

```
lib/
├── main.dart                      composition root (seule dépendance à Flutter au démarrage)
├── domain/                        Dart pur — aucune dépendance Flutter
│   ├── entities/                  Question, QuizCategory, LevelProgress, QuizSession, ScoreSummary
│   ├── values/                    ThemeId, LevelNumber, QuestionText, AnswerOption (value objects validés)
│   ├── rules/                     QuestionRules, ScoringRules, UnlockPolicy, LevelCatalogRules
│   └── errors/                    DomainError (sealed) : InvalidQuestion, InvalidThemeId, …
├── application/                   cas d'usage, orchestrations transactionnelles
│   ├── load_level_map.dart        LoadLevelMap
│   ├── start_session.dart         StartQuizSession (graine + contenu)
│   ├── answer_question.dart       AnswerQuestion / ExpireQuestion
│   ├── finish_session.dart        FinishQuizSession (commit unique)
│   ├── reset_progress.dart        ResetLevelProgress
│   └── manage_score.dart          ReadTotalScore / ResetTotalScore
├── infrastructure/                implémentations des ports
│   ├── content/                   AssetQuestionRepository (+ validation de schéma)
│   ├── storage/                   PrefsProgressRepository (enveloppe versionnée + CRC32)
│   ├── time/                      SystemClock, TimerScheduler
│   ├── random/                    SeededRandomSource
│   └── logging/                   StructuredLogger
├── presentation/
│   ├── screens/                   les 5 écrans, sans logique métier
│   ├── view_models/               états scellés (Loading, Ready, Failure) + commandes
│   └── widgets/                   AnimatedBackground, CyclingBackground, OptionButton
└── platform/                      ports (interfaces) partagés
```

**Règle d'architecture vérifiable en CI** : aucun import de
`package:flutter/*`, `shared_preferences`, `dart:io` ou `dart:math` (sauf
`Random` encapsulé) dans `lib/domain/**` — contrôlé par un test
d'architecture.

### 14.3 Techniques et mesures retenues

| Tableau | Technique retenue | SIL | Justification |
|---|---|---|---|
| A.2 | Modélisation (A.17 #4 : automates à états finis), tables de décision | R / R | Machine à états de session et règles de déverrouillage |
| A.3 | Programmation défensive (#1) | HR | Validation systématique des entrées d'interface (IF-03, IF-06) |
| A.3 | Détection des défauts & diagnostic (#2) | R | Erreurs typées + journalisation structurée |
| A.3 | Programmation par assertion (#5) | R | Invariants du domaine en plus des exceptions runtime |
| A.3 | Codes de détection d'erreurs (#4) | R | CRC32 sur l'enregistrement de progression (ANO-07) |
| A.3 | Interface entièrement définie (#19) | **HR** | Contrats explicites pour les 10 interfaces (§9) |
| A.3 | Méthodologie structurée (#22) | **HR** | Découpage en couches + cas d'usage |
| A.4 | Approche modulaire (#4) | **M** | Modules `domain/application/infrastructure/presentation` |
| A.4 | Composants (#5) | **HR** | Value objects et services à responsabilité unique |
| A.4 | Règles de conception et de codage (#6, A.12) | **HR** | §14.4 |
| A.4 | Programmes analysables (#7) | **HR** | Interdiction de `dynamic`, de la récursivité, des `static` mutables |
| A.4 | Langage fortement typé (#8) | **HR** | Dart en mode *sound null safety*, pas de cast non vérifié |
| A.4 | Programmation structurée (#9) | **HR** | Un seul point de sortie par fonction métier |
| A.5 | Traçabilité (#5) | **HR** | Matrice §13 maintenue à chaque évolution |
| A.5 | Analyse statique (#2) | **HR** | `dart analyze --fatal-infos` + règles de lint durcies |
| A.5 | Tests fonctionnels et boîte noire (#8) | **HR** | CT-01 à CT-31 |
| A.5 | Couverture (#7, A.21) | **HR** | Seuil 100 % décisions sur le domaine |
| A.7 | Tests d'ensemble (#2) | **HR** | Scénarios de bout en bout (parcours complet) |
| A.12 | Norme de codage (#1), guide de style (#2), taille/complexité (#8), paramètres limités (#9), pas de `static` mutable (#10) | HR/HR/HR/R/HR | §14.4 |
| A.11 | Méthodes de spécification en tableaux (#1) + tests fonctionnels (#4) | R/M | Validation du contenu (données d'application) |

**Combinaison A.3 retenue** (niveaux 1-2) : 1 (défensive), 19 (interfaces),
22 (structurée) + 4 (codes de détection d'erreurs) → conforme à l'exigence 2 du
tableau A.3.
**Combinaison A.4 retenue** (niveaux 1-2) : 3 (structurée), 4 (modulaire),
5 (composants), 6 (règles de codage) + 8 (typage fort) → conforme à l'exigence 2
du tableau A.4.
**Combinaison A.5 retenue** (niveaux 1-2) : 5 (traçabilité) + 8 (tests
fonctionnels) → conforme à l'exigence 2 du tableau A.5.

### 14.4 Règles de codage (Dart) — projet de norme

| Règle | Contenu | Réf. A.12 |
|---|---|---|
| RC-01 | `dart format` obligatoire, largeur 80 ; `dart analyze --fatal-infos` sans avertissement | #1, #2 |
| RC-02 | Interdiction de `dynamic` hors décodage JSON immédiatement validé | #1 |
| RC-03 | Aucune récursivité (remplacer par itération bornée) | #6 |
| RC-04 | Aucune variable globale mutable ; `static` réservé aux constantes | #10 |
| RC-05 | Fonction ≤ 30 lignes, ≤ 4 paramètres, complexité cyclomatique ≤ 10 | #8, #9 |
| RC-06 | Un seul `return` par fonction métier, sorties en fin de fonction | #9 |
| RC-07 | `assert` = documentation d'invariant, **jamais** validation d'entrée runtime (exceptions typées) | A.3 #5 |
| RC-08 | `final` par défaut ; classes `@immutable` ; collections `unmodifiable` | A.4 #5 |
| RC-09 | Toute erreur traverse la frontière sous forme de `DomainError`/`InfrastructureError` ; jamais de `toString()` vers l'IHM | A.3 #2 |
| RC-10 | Aucune I/O dans `domain/` ; ports injectés | A.4 #4 |
| RC-11 | `switch` exhaustif sur les types scellés, sans `default` masquant | A.3 #2 |
| RC-12 | Journalisation structurée (niveau, code, contexte), sans donnée personnelle | A.3 #2 |
| RC-13 | Pas de `print` ; pas de `TODO` sans ticket ; pas de code commenté | #1 |
| RC-14 | Tout fichier `pubspec`/asset justifié ; aucune dépendance non utilisée | Tableau A.15 |

### 14.5 Livrables documentaires (Tableau A.1)

| # | Document | Statut | Échéance |
|---|---|---|---|
| 1 | Plan d'Assurance Qualité du Logiciel (allégé, justifié) | À produire | E1 |
| 3 | Plan de Gestion de la Configuration | À produire | E1 |
| 4-5 | Plans de Vérification et de Validation | À produire | E2 |
| 6 | Spécification des Exigences du Logiciel (issu de ce document) | À produire | E2 |
| 7 | Spécification de Tests d'Ensemble | À produire | E2 |
| 9-11 | Architecture, Conception, Spécifications d'Interface | À produire | E3 |
| 12-13 | Spécifications de Tests d'Intégration (logiciel, logiciel/matériel) | À produire | E3 |
| 15-17 | Conception de composant + tests + rapport de vérification | À produire | E4 |
| 18-20 | Code source + documentation de support + rapport de vérification | À produire | E5-E7 |
| 21-25 | Rapports d'intégration, tests d'ensemble, validation | À produire | E7 |
| 26 | Rapport de validation des outils (Gradle, Flutter, scripts CI) | À produire | E1 |
| 27, 38 | Fiches de livraison | À produire | E8 |
| 28-35 | Exigences, plan, tests, architecture, code et vérification **des données d'application** | À produire | E2, E7 |
| 36-40 | Plan et manuel de déploiement, enregistrements, vérification | À produire | E8 |
| 41-44 | Plan de maintenance, registres de modifications, enregistrements, vérification | À produire | E8 |
| 45-46 | Plan et rapport d'évaluation | Selon besoin | E8 |

> **Groupement** : les §5.3.2.12 et §5.3.2.13 autorisent le regroupement de documents. Pour un
> logiciel de cette taille, un document unique « Dossier de conception » peut
> regrouper 9, 10, 11 et 15, avec renvois explicites. Le regroupement doit être
> **justifié dans le Plan d'Assurance Qualité**.

### 14.6 Traitement des données d'application (§8.4)

Le contenu des quiz est une **donnée d'application** : la norme impose un
processus dédié (§8.4.1), une spécification des exigences de l'application
(§8.4.2) et une vérification indépendante du contenu.

| Action | Contenu | Réf. |
|---|---|---|
| DA-01 | Schéma JSON formel (JSON Schema) versionné | §8.4.2 |
| DA-02 | Validateur exécutable en CI sur **tous** les fichiers de contenu | Tableau A.11 #1, #4 |
| DA-03 | Contrôle d'unicité des questions par thème et de non-régression du volume | §8.4.1.6 |
| DA-04 | Revue indépendante du contenu (exactitude pédagogique) + enregistrement | Tableau A.11 #5, #7 |
| DA-05 | Jeu de données de test séparé du contenu de production | §8.4.1.9 |
| DA-06 | Traçabilité `question → thème → niveau → fiche de validation` | §8.4.1.13 |

---

## 15. Plan de refonte

| Étape | Contenu | Critères de sortie |
|---|---|---|
| **E1 — Gel et configuration** | Baseline `legacy/` figée, inventaire des assets réels, plan AQ et plan de configuration, validation des outils | Baseline étiquetée ; écarts d'assets (ANO-19) tranchés |
| **E2 — Spécifications** | SRS (EF/ENF/RG formalisées, sans ambiguïté), spécification des tests d'ensemble, exigences de l'application (contenu) | 100 % des EF tracées ; ANO-15 tranchée |
| **E3 — Architecture et interfaces** | SW-ARCH, spécifications d'interface (10 IF avec pré/post/limites), conception détaillée, règles de codage RC-01..RC-14 | Revue d'architecture sans réserve |
| **E4 — Domaine** | `Question`, value objects, `ScoringRules`, `UnlockPolicy`, `LevelCatalogRules`, erreurs typées | Tests unitaires verts, 100 % décisions, aucune dépendance Flutter |
| **E5 — Infrastructure** | Dépôts (assets, préférences versionnées + CRC32), horloge injectée, aléa graine, journalisation | Tests avec doublures ; simulation de panne d'écriture |
| **E6 — Présentation** | View models à états scellés, 5 écrans sans logique, accessibilité, i18n | Tests de widgets ; navigation complète |
| **E7 — V&V** | CT-01 à CT-31, tests d'intégration, tests d'ensemble, analyse statique, mesure de couverture, revue de code | Rapports de vérification et de validation ; aucune anomalie B/M ouverte |
| **E8 — Livraison** | Build reproductible, signature de release, fiche de livraison, manuel de déploiement, plan de maintenance | APK signé, version tracée, fiche signée |

Chaque étape produit un livrable du Tableau A.1 et ne démarre qu'après revue de
l'étape précédente (cycle en V, §7.1.2.2).

---

## 16. Hypothèses et points à valider

| # | Hypothèse / question | Impact si différente |
|---|---|---|
| H1 | **SIL 2** retenu par décision de projet (D-001), aucune fonction de sécurité | Sans décision formelle, le niveau resterait à justifier par une analyse de risques EN 50126-1 ; l'indépendance V&V reste à satisfaire (§5.1.2.11) |
| H2 | Le produit reste **Android, hors ligne, mono-utilisateur** | Multi-plateforme ou synchronisation changeraient IF-05/IF-06 et la stratégie de stockage |
| H3 | Règle de déverrouillage = **achèvement**, sans seuil | Un seuil (ex. ≥ 70 %) modifie RG-03, EF-05, `UnlockPolicy` et CT-18/CT-19 |
| H4 | Score = **1 point par bonne réponse**, sans pondération | Une pondération par difficulté change `ScoringRules` et l'affichage |
| H5 | Abandon de session = **aucun enregistrement** | Une sauvegarde partielle changerait la machine à états (E8) et la persistance |
| H6 | `shared_preferences` conservé | Un stockage fichier versionné serait préférable pour l'atomicité et les tests (recommandé) |
| H7 | Contenu des quiz hors périmètre de code, traité en données d'application | Si le contenu doit être éditable à chaud, une interface d'édition devient nécessaire |
| H8 | Le dossier `assets/` complet sera fourni pour la refonte | Sans lui, seuls des jeux de test synthétiques seront utilisables |

---

## Annexe A — Index alphabétique des fonctions

| Fonction | ID | Emplacement |
|---|---|---|
| `_buildLevelList` | FON-P-11 | `level_map_screen.dart:108` |
| `_buildMessage` | FON-P-22 | `quiz_screen.dart:175` |
| `_buildQuiz` | FON-P-23 | `quiz_screen.dart:207` |
| `_confirmReset` | FON-P-10 | `level_map_screen.dart:76` |
| `_finishQuiz` | FON-P-20 | `quiz_screen.dart:130` |
| `_keyFor` | FON-S-05 | `level_manager.dart:4` |
| `_loadJson` | FON-S-02 | `question_loader.dart:25` |
| `_loadLevels` | FON-P-08 | `level_map_screen.dart:31` |
| `_loadQuestions` | FON-P-17 | `quiz_screen.dart:62` |
| `_loadScore` | FON-P-28 | `scores_screen.dart:23` |
| `_normalizedQuizType` | FON-S-01 | `question_loader.dart:17` |
| `_openCategory` | FON-P-04 | `quiz_type_selection_screen.dart:16` |
| `_openScores` | FON-P-03 | `quiz_type_selection_screen.dart:10` |
| `_resetScore` | FON-P-29 | `scores_screen.dart:41` |
| `_startCycle` | FON-P-35 | `cycling_background.dart:43` |
| `_startLevel` | FON-P-09 | `level_map_screen.dart:63` |
| `_startTimer` | FON-P-18 | `quiz_screen.dart:93` |
| `_submitAnswer` | FON-P-19 | `quiz_screen.dart:108` |
| `_title` (carte) | FON-P-06 | `level_map_screen.dart:23` |
| `_title` (quiz) | FON-P-14 | `quiz_screen.dart:41` |
| `build` (carte) | FON-P-12 | `level_map_screen.dart:205` |
| `build` (fond) | FON-P-37 | `cycling_background.dart:58` |
| `build` (quiz) | FON-P-24 | `quiz_screen.dart:304` |
| `build` (résultat) | FON-P-25 | `score_screen.dart:26` |
| `build` (scores) | FON-P-30 | `scores_screen.dart:74` |
| `build` (sélection) | FON-P-02 | `quiz_type_selection_screen.dart:25` |
| `build` (app) | FON-P-01 | `main.dart:13` |
| `calculateQuizAccuracy` | FON-D-12 | `quiz_scoring.dart:12` |
| `calculateQuizScore` | FON-D-11 | `quiz_scoring.dart:4` |
| `clearScore` | FON-S-13 | `profile_functions.dart:27` |
| `createState` (×4) | FON-P-05, 13, 26, 32 | écrans et fond |
| `didChangeAppLifecycleState` | FON-P-16 | `quiz_screen.dart:51` |
| `didUpdateWidget` | FON-P-34 | `cycling_background.dart:34` |
| `dispose` (×3) | FON-P-21, 36 (+ fond) | — |
| `getTotalScore` | FON-S-14 | `profile_functions.dart:32` |
| `getUnlockedLevels` | FON-S-08 | `level_manager.dart:97` |
| `initializeLevelsForQuiz` | FON-S-06 | `level_manager.dart:13` |
| `initState` (×4) | FON-P-07, 15, 27, 33 | — |
| `loadAvailableLevels` | FON-S-03 | `question_loader.dart:42` |
| `loadQuestions` | FON-S-04 | `question_loader.dart:78` |
| `main` (app) | FON-C-01 | `lib/main.dart:4` |
| `Question` | FON-D-01 | `question.dart:3` |
| `Question.fromJson` / `.toJson` | FON-D-02 / D-03 | `question.dart:45` / `:75` |
| `quizCategoryForId` | FON-D-05 | `quiz_category.dart:70` |
| `resetLevels` | FON-S-10 | `level_manager.dart:126` |
| `resetProgressForQuiz` | FON-S-09 | `level_manager.dart:110` |
| `resetScore` | FON-S-12 | `profile_functions.dart:22` |
| `unlockNextLevel` | FON-S-07 | `level_manager.dart:63` |
| `updateScore` | FON-S-11 | `profile_functions.dart:7` |
| `UserProfile` et membres | FON-D-06..D-10 | `user_profile.dart` |

## Annexe B — Correspondance écran ↔ exigences

| Écran | Fichier | Exigences | Fonctions |
|---|---|---|---|
| Sélection du thème | `quiz_type_selection_screen.dart` (126 l.) | EF-01, EF-02, EF-18 | FON-P-02..04, FON-D-05 |
| Carte des niveaux | `level_map_screen.dart` (249 l.) | EF-04, EF-05, EF-06, EF-19, EF-20 | FON-P-05..12, FON-S-03, S-06, S-08, S-09, S-10 |
| Quiz | `quiz_screen.dart` (320 l.) | EF-07..EF-14, EF-16, EF-19 | FON-P-13..24, FON-D-01..03, D-11, FON-S-01..04 |
| Résultat | `score_screen.dart` (138 l.) | EF-15, EF-18 | FON-P-25, FON-D-11 |
| Scores | `scores_screen.dart` (131 l.) | EF-02, EF-03 | FON-P-26..30, FON-S-12, S-14 |
| Fond animé | `animated_background.dart` + `cycling_background.dart` (110 l.) | EF-17 | FON-P-31..37 |

## Annexe C — Glossaire

| Terme | Définition |
|---|---|
| **SIL** | Safety Integrity Level — niveau d'intégrité de sécurité, de 0 (le plus bas) à 4 |
| **SRS** | Software Requirements Specification — Spécification des Exigences du Logiciel |
| **V&V** | Vérification et Validation |
| **Donnée d'application** | Donnée (ici, les JSON de questions) qui configure le comportement d'un logiciel générique ; traitée au §8.4 |
| **C1 / C2 / C3** | Criticité interne : cœur métier / support / présentation |
| **Classe d'équivalence** | Sous-ensemble d'entrées traitées de façon identique par le logiciel |
| **Valeur limite** | Valeur au seuil d'une classe d'équivalence (0, 1, n-1, n…) |
| **Port** | Interface abstraite séparant le domaine de l'infrastructure (architecture hexagonale) |

---

**Fin du document — AN-FON-001 v1.0**

*Prochaine étape proposée : validation des hypothèses H1 à H8 (§16), puis
rédaction de la Spécification des Exigences du Logiciel (SRS) et de la
Spécification de l'Architecture (SW-ARCH) avant toute écriture de code.*
