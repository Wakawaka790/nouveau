# STD-COD-001 — Norme de Codage Dart du projet

| | |
|---|---|
| **Référence** | STD-COD-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §7.3.4.25 à 7.3.4.27 ; Tableau A.12 ; Tableau A.15 #9 (Dart : R à tous les SIL) |
| **Niveau** | SIL 2 |

---

## 1. Objet et champ d'application

Cette norme est **opposable** : elle s'applique à tout code Dart du dépôt
(`lib/`, `test/`), à l'exception de `legacy/` qui est une archive figée. Son
application est contrôlée automatiquement (§5) et par revue (§6).

---

## 2. Choix du langage (Tableau A.15)

Dart ne figure pas dans le Tableau A.15. La NOTE 2 de ce tableau précise qu'un
langage absent n'est pas exclu mais doit satisfaire la référence D.54
(« langages de programmation adaptés »). Justification retenue :

| Critère D.54 | Constat pour Dart |
|---|---|
| Typage fort | ✅ *sound null safety*, génériques, types scellés (`sealed`) |
| Vérification statique | ✅ `dart analyze`, inférence stricte activée |
| Absence de constructions dangereuses | ✅ pas d'arithmétique de pointeurs, pas de `goto`, accès mémoire contrôlé |
| Gestion des erreurs | ✅ exceptions typées + hiérarchie scellée |
| Modules et portée | ✅ bibliothèques, `part`, visibilité par `_` |
| Déterminisme | ✅ arithmétique entière définie ; pas de GC non déterministe au sens du résultat fonctionnel |
| Portabilité | ✅ exécution identique ARM/x86 via l'AOT Dart |

**Restriction complémentaire** : `dynamic` est interdit hors adaptateur JSON
(§4), ce qui rapproche l'usage de Dart de celui d'un langage fortement typé au
sens du Tableau A.4 #8 (**HR** à SIL 2).

---

## 3. Règles

### 3.1 Structure et format

| Règle | Contenu | Contrôle | Réf. A.12 |
|---|---|---|---|
| **RC-01** | `dart format` sans écart, largeur 80 par défaut | `dart format --set-exit-if-changed` | #1, #2 |
| **RC-02** | Analyse sans aucun avertissement | `flutter analyze --fatal-infos --fatal-warnings` | #1 |
| **RC-03** | Un fichier = un composant principal ; ≤ **200 lignes** | test TC-ARCH-04 | #8 |
| **RC-04** | Fonction métier (`domain`, `application`) ≤ **30 lignes**, ≤ 4 paramètres, complexité cyclomatique ≤ **10**. Les fonctions de **présentation** (widgets) sont exemptées de la limite de 30 lignes mais **pas** des autres | revue + test | #8, #9 |
| **RC-05** | Ordre des imports : `dart:` → `package:` → relatifs, alphabétique, sans import inutilisé | `directives_ordering`, `unused_import: error` | #1 |
| **RC-06** | Une déclaration par ligne ; pas de `TODO` sans ticket | revue | #1 |

> **Précision RC-04** (suite à l'observation V-03) : la limite de 30 lignes vise
> les fonctions portant une **décision** (domaine, cas d'usage). Un `build()`
> de widget, purement descriptif, est jugé sur la lisibilité et sur RC-03. La
> fonction métier la plus longue du dépôt mesure **14 lignes** (`QuizSession._record`).

### 3.2 Typage

| Règle | Contenu | Réf. |
|---|---|---|
| **RC-07** | `dynamic` interdit hors décodage JSON **immédiatement** validé (`Object?` préféré) | A.4 #8 |
| **RC-08** | `strict-casts`, `strict-inference`, `strict-raw-types` activés | A.4 #8 |
| **RC-09** | Tout état variable est `final` ou encapsulé ; collections exposées en lecture seule (`List.unmodifiable`) | A.4 #5 |
| **RC-10** | Aucun `static var` / `static late` : pas d'état global mutable | A.12 #10 |
| **RC-11** | `switch` sur type scellé **sans** `default` masquant l'exhaustivité | A.3 #2 |

### 3.3 Défense et erreurs

| Règle | Contenu | Réf. |
|---|---|---|
| **RC-12** | `assert` = documentation d'invariant, **jamais** validation d'entrée runtime (validation = exception typée) | A.3 #5 |
| **RC-13** | Toute erreur traversant une frontière est une sous-classe de `AppError`, jamais un `String` ni une exception du SDK | A.3 #2 |
| **RC-14** | Aucun `print` : journalisation via le port `Logger` | A.3 #2 |
| **RC-15** | Aucune I/O dans `domain/` ; horloge, aléa, stockage, contenu injectés | A.4 #4 |
| **RC-16** | Interdiction de la récursivité : itération bornée uniquement | A.12 #6 |

### 3.4 Documentation et traçabilité

| Règle | Contenu | Réf. |
|---|---|---|
| **RC-17** | Chaque fichier commence par un commentaire `///` d'une à trois lignes décrivant sa responsabilité | 5.3.2.7 |
| **RC-18** | Chaque règle métier non triviale cite l'exigence qu'elle réalise (`REQ-xxx`) **et** le motif quand il corrige une anomalie (`ANO-xx`) | A.5 #5 |
| **RC-19** | Chaque `catch` justifie sa portée : soit il convertit, soit il journalise, soit il replie — jamais un `catch` muet | A.3 #2 |
| **RC-20** | Langue : identifiants en anglais, documentation et messages en français | 5.3.2.7 |

---

## 4. Règles spécifiques au projet

| Sujet | Règle |
|---|---|
| Identifiants de thème | jamais une `String` nue dans `lib/` : toujours un `ThemeId` |
| Numéros de niveau | jamais un `int` nu hors des interfaces : `LevelNumber` |
| Temps | jamais `DateTime.now()` dans `domain`/`application` : `Clock` |
| Aléa | jamais `Random()` hors `SeededRandomSource` |
| Persistance | jamais `SharedPreferences` hors `PrefsStateRepository` |
| Chaînes d'interface | jamais de littéral dans un widget : `AppStrings` |
| Chemins d'assets | construits uniquement depuis un `ThemeId` et un `LevelNumber` validés |

---

## 5. Application automatique

| Règle | Outil | Bloquant |
|---|---|---|
| RC-01 | `dart format` | oui |
| RC-02 | `flutter analyze` | oui |
| RC-03 | `test/architecture_test.dart` (TC-ARCH-04) | oui |
| RC-07, RC-08 | `analysis_options.yaml` | oui |
| RC-10 | TC-ARCH-05 | oui |
| RC-12, RC-14 | TC-ARCH-05 | oui |
| RC-15 | TC-ARCH-01..03 | oui |
| RC-16 | revue | non |
| RC-17..20 | revue (LC-03) | non |

---

## 6. Liste de contrôle de revue de code (LC-03)

| # | Point | Conforme |
|---|---|---|
| 1 | Le fichier a une responsabilité unique et documentée | ☐ |
| 2 | Aucune règle métier dans `presentation/` | ☐ |
| 3 | Aucune dépendance interdite (vérifiée par test) | ☐ |
| 4 | Toutes les erreurs sont typées et converties aux frontières | ☐ |
| 5 | Les cas limites sont traités (bornes, null, vide, panne) | ☐ |
| 6 | Aucun `assert` de validation, aucun `print` | ☐ |
| 7 | Les collections exposées sont immuables | ☐ |
| 8 | Les exigences réalisées sont citées (`REQ-xxx`) | ☐ |
| 9 | Les tests correspondants existent et couvrent les branches | ☐ |
| 10 | Pas de code mort, pas de commentaire obsolète | ☐ |
| 11 | Taille et complexité dans les limites | ☐ |
| 12 | Aucun état global mutable | ☐ |

---

## 7. Dérogations

| ID | Règle | Justification | Validation |
|---|---|---|---|
| D-01 | RC-04 (30 lignes) | Fonctions `build()` de widgets descriptives (max **81 lignes** : `ResultScreen.build`, cf. V-03) | VER |
| D-02 | RC-07 (`dynamic`) | Aucune occurrence : le retour de `jsonDecode` est typé `Object?` | — |

**Fin du document — STD-COD-001 v1.0**
