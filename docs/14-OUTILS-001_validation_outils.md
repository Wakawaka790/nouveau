# OUTILS-001 — Validation des Outils

| | |
|---|---|
| **Référence** | OUTILS-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §6.7, Tableau A.1 #26 (Rapport de Validation des Outils) ; classification des outils (§3.1.34) |
| **Niveau** | SIL 2 |

---

## 1. Principe

La norme distingue trois classes d'outils selon leur influence sur le logiciel
livré :

| Classe | Définition | Exigence |
|---|---|---|
| **T1** | Peut introduire une erreur dans le logiciel exécutable sans qu'elle soit détectée | Validation poussée |
| **T2** | Peut manquer une erreur sans en introduire | Vérification de l'adéquation |
| **T3** | N'a pas d'influence sur le logiciel exécutable | Aucune exigence particulière |

---

## 2. Inventaire et classification

| Outil | Version | Usage | Classe | Justification |
|---|---|---|---|---|
| **Dart SDK** (compilateur) | 3.x | Compilation AOT | **T1** | Une erreur de compilation peut produire un binaire erroné ; couvert par la validation du fournisseur (Google) + tests d'ensemble |
| **Flutter SDK** | 3.29.2 | Framework d'interface, build APK | **T1** | Idem ; choix du framework figé par `pubspec.lock` |
| **shared_preferences** | ^2.2.2 | Persistance | **T1** | Utilisé en production ; protégé par CRC-32 applicatif et par la doublure `KeyValueStore` en test |
| **flutter_test** | sdk | Exécution des tests | **T3** | N'influence pas le binaire livré |
| **flutter_lints** | ^3.0.1 | Règles d'analyse | **T2** | Peut manquer un défaut, n'en introduit pas |
| **dart format** | sdk | Formatage | **T3** | Sans effet sémantique |
| **Gradle / AGP** | projet Android | Empaquetage APK | **T1** | Influence le binaire ; contrôlé par la reproductibilité (REQ-079) |
| **Python 3** | 3.10+ | `validate_content.py`, `check_coverage.py` | **T2** | Ne modifie pas le binaire ; produit des preuves. Erreur possible : faux négatif → contrôlé par test d'injection (§4) |
| **Git / GitHub Actions** | — | Gestion de configuration, CI | **T3** | N'influence pas le binaire, trace les états |

---

## 3. Mesures de maîtrise

| Outil | Mesure |
|---|---|
| Compilateur Dart/Flutter | Version **figée** (`FLUTTER_VERSION: 3.29.2` dans la CI), `pubspec.lock` versionné, interdiction de mise à jour implicite (contrôle `diff`) |
| `shared_preferences` | Isolation derrière le port `KeyValueStore` ; test de corruption et de panne d'écriture (TC-INF-17, 18) |
| Gradle/AGP | Versions figées dans le projet Android ; contrôle de reproductibilité |
| Scripts Python | Test d'injection : 3 défauts introduits volontairement, 3 défauts détectés (APP-DATA-001 §4.2) ; script de couverture vérifié sur un `lcov` de test |
| Règles de lint | Liste explicite dans `analysis_options.yaml`, révisable, versionnée |

---

## 4. Vérification des outils T1 (compilateur et framework)

La validation complète d'un compilateur est hors de portée d'un projet. La
norme permet de s'appuyer sur la validation du fournisseur, complétée par des
mesures de détection côté projet :

| Mesure | Mise en œuvre |
|---|---|
| Version unique et traçable | `FLUTTER_VERSION` + `pubspec.lock` |
| Absence de réécriture du code par l'outil | contrôle `diff` sur `pubspec.yaml` (REQ-079) ; aucun script de réécriture de source (contrairement à la v7, ANO-23) |
| Détection d'un binaire incohérent | tests d'ensemble sur appareil (TC-SYS) ; contrôle des comportements critiques (score, persistance) |
| Diversité de vérification | le domaine est testé **sans** le framework (Dart pur) : un défaut du framework ne peut pas masquer un défaut du domaine |
| Absence d'optimisation dangereuse | la CI compile en `release` sans option d'optimisation agressive non documentée |

---

## 5. Outils écartés

| Outil | Motif |
|---|---|
| `audioplayers` | Déclaré en v7, jamais utilisé (ANO-18) → **retiré** : un outil non utilisé est une surface de risque et un élément de configuration à maintenir inutilement |
| `prepare_project.py`, `fix_android_config.py` (v7) | Réécrivaient la source pendant le build (ANO-23) → **supprimés** ; remplacés par un projet Android versionné (C-10) |

---

## 6. Conclusion

| | |
|---|---|
| Outils identifiés | 9 |
| Classés T1 | 3 (Dart, Flutter, Gradle) + 1 dépendance (`shared_preferences`) |
| Mesures de maîtrise | §3, §4 |
| Point ouvert | **C-10** : le projet Android n'étant pas encore généré/versionné, la chaîne Gradle ne peut pas être vérifiée en l'état |
| Verdict | **Conforme sous réserve de C-10** |

**Fin du document — OUTILS-001 v1.0**
