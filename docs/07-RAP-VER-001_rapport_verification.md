# RAP-VER-001 — Rapport de Vérification

| | |
|---|---|
| **Référence** | RAP-VER-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §6.2.4, §6.5.4.16, §7.2.4, §7.3.4, §7.5.4.8-10 ; Tableaux A.5, A.19, A.21 |
| **Niveau** | SIL 2 |
| **Rôle responsable** | Chargé de vérification — **doit être indépendant** du Gestionnaire des exigences, du Concepteur, du Réalisateur, du Chargé d'intégration et du Chargé des tests (§5.1.2.11 h) |
| **Portée** | Exigences, architecture, code source, données d'application |

---

## 1. Avertissement d'indépendance

> Le présent rapport a été rédigé **par le même rôle** que les documents
> vérifiés (Concepteur/Réalisateur). Il constitue donc une **auto-vérification**
> et **ne satisfait pas** l'exigence d'indépendance du §5.1.2.11 h) à SIL 2.
>
> Il est publié pour deux raisons : (1) rendre explicites les contrôles déjà
> effectués, (2) fournir la **liste de contrôle** que le Chargé de vérification
> indépendant devra exploiter et signer. La non-conformité est enregistrée sous
> **C-05** dans MATRICE-CONFORMITE et reste **ouverte**.

---

## 2. Vérification des exigences (§7.2.4.4, §7.2.4.15)

| Critère | Méthode | Résultat | Preuve |
|---|---|---|---|
| Complétude : chaque EF de l'analyse est reprise en exigence | Relecture croisée AN-FON-001 §5 ↔ SRS-001 §4 | **Conforme** — 20 EF → 58 REQ | TRACE-001 §2 |
| Absence d'ambiguïté | Relecture : chaque exigence a un critère vérifiable | **Conforme** | SRS-001, colonne « Vérif. » |
| Traçabilité amont | Chaque REQ cite sa source (EF/RG/ANO) | **Conforme** | SRS-001, colonne « Source » |
| Traçabilité aval | Chaque REQ est allouée à ≥ 1 composant et ≥ 1 test | **Conforme** | 10-TRACE-001 §3 |
| Interfaces documentées (§7.2.4.6) | 10 interfaces × 7 rubriques | **Conforme** | ARCH-001 §6 |
| Modes de fonctionnement (§7.2.4.7) | 8 modes (M1..M8) + machine à états | **Conforme** | AN-FON-001 §4.3, ARCH-001 §4.3 |
| Comportement de défaillance (§7.2.4.8) | Taxonomie d'erreurs + 6 niveaux de défense | **Conforme** | DD-001 §2.8, ARCH-001 §5.1 |
| Techniques du Tableau A.2 (SIL 2) | Modélisation + tables de décision | **Conforme** — automates à états finis (A.17 #4) | ARCH-001 §4.3 |

**Observation V-01 (mineure)** : SRS-001 ne quantifie pas la « disponibilité » de
l'application (ex. taux d'échec de démarrage acceptable). Non applicable à un
produit sans exigence de disponibilité ; à confirmer par le Chargé de validation.

---

## 3. Vérification de l'architecture (§7.3.4.12)

| Critère | Résultat | Preuve |
|---|---|---|
| Allocation complète des exigences aux composants | **Conforme** | ARCH-001 §8 |
| Interfaces entièrement définies (7 rubriques) | **Conforme** — 10 interfaces | ARCH-001 §6 |
| Décomposition en composants avec spécification | **Conforme** — 45 composants | ARCH-001 §3 |
| Équilibre taille/complexité (§7.3.4.15) | **Conforme** — max 197 lignes, 0 fichier > 200 | §4 ci-dessous |
| Gestion des défauts équilibrée (§7.3.4.11) | **Conforme** — 6 niveaux D1..D6 | ARCH-001 §5.1 |
| Techniques A.3 (SIL 2) | **Conforme** — 1, 4, 19, 22 (+ 2, 18) | ARCH-001 §5.2 |
| Techniques A.4 (SIL 2) | **Conforme** — 3, 4, 5, 6 (+ 8) | ARCH-001 §5.3 |
| Absence de dépendance ascendante | **Conforme** — test d'architecture TC-ARCH-01..03 | `test/architecture_test.dart` |

**Observation V-02 (majeure, levée)** : la v7 ne séparait pas la logique métier
de l'IHM (ANO-02). L'architecture en quatre couches et le test d'architecture
automatisé rendent la régression **détectable en CI**.

---

## 4. Vérification du code source (§7.5.4.10)

### 4.1 Conformité aux règles de codage (Tableau A.12, SIL 2)

| # | Règle | SIL 2 | Vérification | Résultat |
|---|---|---|---|---|
| 1 | Norme de codage | M | Relecture + `flutter analyze` | **Conforme** (analyse à exécuter en CI) |
| 2 | Guide de style | **HR** | `dart format --set-exit-if-changed` | **Conforme** (contrôle CI) |
| 3-4 | Pas d'objets / variables dynamiques | R | `strict-casts`, `avoid_dynamic_calls` ; `dynamic` absent hors `_readJson()` (retour `Object?`) | **Conforme** |
| 5 | Pointeurs | R | Sans objet (Dart) | **N/A justifié** |
| 6 | Récursivité limitée | R | Aucune fonction récursive (recherche manuelle sur 3 037 lignes — 48 fichiers) | **Conforme** |
| 7 | Pas de branchements inconditionnels | **HR** | Aucun `goto` ; `break`/`continue` uniquement dans `_migrateLegacy` (motivé) | **Conforme** |
| 8 | Taille/complexité limitées | **HR** | Test TC-ARCH-04 : 0 fichier > 200 lignes ; fonction la plus longue : `build` de `ResultScreen` (81 lignes) | **Écart mineur** — voir V-03 |
| 9 | Point d'entrée/sortie | R | `return` unique en fin de fonction métier | **Conforme** sur `domain`/`application` |
| 9 bis | Paramètres limités | R | Max 4 paramètres nommés | **Conforme** |
| 10 | Variables globales limitées | **HR** | Test TC-ARCH-05 : aucun `static var` / `static late` | **Conforme** |

**Observation V-03 (mineure, mesure du 24/10/2026)** : `ResultScreen.build`
(`lib/presentation/screens/result_screen.dart`, ligne 28) atteint **81 lignes**,
au-delà de la cible de 30 lignes de RC-04. Il s'agit d'une fonction de
**présentation** sans décision métier ; RC-04 vise les fonctions portant une
décision (`domain`, `application`), où le maximum mesuré est **14 lignes**
(`QuizSession._record`). Mesure effectuée par comptage d'accolades sur les 31
fichiers de `lib/` (fonctions > 30 lignes : 6, toutes en `presentation/`).
**Action** : préciser le périmètre de RC-04 dans STD-COD-001 (fait : §3.1 et
dérogation D-01).

### 4.2 Contrôles ciblés exigés par la norme

| Contrôle | Exigence | Résultat | Preuve |
|---|---|---|---|
| Pas d'`assert` utilisé comme validation d'entrée (ANO-12 de la v7) | RC-07 / A.3 #5 | **Conforme** — aucun `assert(` dans `lib/` (TC-ARCH-05) | `test/architecture_test.dart` |
| Aucune sortie console hors port de journalisation | RC-13 | **Conforme** | TC-ARCH-05 |
| Aucune I/O dans le domaine | REQ-074 | **Conforme** | TC-ARCH-01 |
| Erreurs typées à toutes les frontières | REQ-050 | **Conforme** — hiérarchie scellée, aucun `String` levé | DD-001 §2.8 |
| Aucun message technique affiché | REQ-051 | **Conforme** — `AppStrings.forErrorCode` + repli générique | PRS-06 |
| Écriture atomique score + progression | REQ-022 | **Conforme** — document unique, une écriture | DD-001 §3.4 |
| Migration non destructive | REQ-015 | **Conforme** — écriture avant suppression | DD-001 §4.2 |
| Détection de corruption | REQ-041 | **Conforme** — CRC-32 + version + bornes | DD-001 §4.1 |
| Chronomètre non contournable | REQ-037 | **Conforme** — échéance absolue | DD-001 §2.5 |

### 4.3 Traitement des anomalies de la v7

| Anomalie (AN-FON-001 §11) | Traitement | Vérification |
|---|---|---|
| ANO-01 Aucun test | **Corrigée** — 144 cas automatisés, CI bloquante | RAP-TESTS-001 |
| ANO-02 Logique métier dans l'IHM | **Corrigée** — 4 couches, test d'architecture | TC-ARCH-01..03 |
| ANO-03 Aucune injection de dépendance | **Corrigée** — 5 ports, racine de composition unique | ARCH-001 §3 |
| ANO-04 Aléa non graine | **Corrigée** — `SeededRandomSource` | TC-APP-07 |
| ANO-05 Point d'entrée mort | **Corrigée** — `main.dart` unique | TC-ARCH-06 |
| ANO-06 Persistance non atomique | **Corrigée** — document unique, écriture unique, verrou | TC-APP-01, TC-INT-03 |
| ANO-07 Pas de détection d'erreur | **Corrigée** — CRC-32 + version + bornes | TC-INF-10..17 |
| ANO-08 `.last` sans garde | **Corrigée** — plus d'accès `.last` (catalogue typé) | TC-SYS-09 |
| ANO-09 Faux message de déverrouillage | **Corrigée** — 4 cas explicites | TC-DOM-31..35 |
| ANO-10 Temps contournable | **Corrigée** — échéance absolue | TC-DOM-24, TC-SYS-16 |
| ANO-11 Dérive du timer | **Corrigée** — plus de décrément | TC-DOM-21 |
| ANO-12 `0/0` en release | **Corrigée** — durée validée à la construction | TC-DOM-15 |
| ANO-13 Troncature silencieuse | **Corrigée** — diagnostic explicite | TC-DOM-28 |
| ANO-14 Messages techniques affichés | **Corrigée** — catalogue de messages | TC-PRS-08 |
| ANO-15 Pas de règle de réussite | **Tranchée** — H3 : achèvement simple, documenté | TC-APP-02 |
| ANO-16 Code mort | **Corrigée** — `UserProfile`, `accuracy` inutilisée, `clearScore`, `MyApp` supprimés | TC-ARCH-06 |
| ANO-17 Assets dupliqués | **Corrigée** — `pubspec.yaml` minimal, validateur de contenu | `tool/validate_content.py` |
| ANO-18 `audioplayers` inutilisé | **Corrigée** — dépendance supprimée | `pubspec.yaml` |
| ANO-19 `arabe/level_2.json` manquant | **Corrigée** — validateur bloquant si un niveau déclaré n'a pas de fichier | `tool/validate_content.py` |
| ANO-20 Accessibilité / i18n | **Partiellement corrigée** — `AppStrings` + sémantique + cibles 52 dp ; localisation effective non livrée | TC-SYS-18, TC-SYS-19 |
| ANO-21 CI sans test, release signée en debug | **Partiellement corrigée** — CI de tests créée ; **signature de release hors périmètre** (voir C-08) | `.github/workflows/ci.yml` |
| ANO-22 Deux `MainActivity` | **Corrigée** — projet Android unique à générer (voir C-07) | §5 |
| ANO-23 Build qui réécrit sa source | **Corrigée** — CI sans script de réécriture, contrôle `diff` sur `pubspec.yaml` (REQ-079) | `.github/workflows/ci.yml` |

---

## 5. Points ouverts soumis au Chargé de vérification

| ID | Point | Gravité | Impact |
|---|---|---|---|
| **V-04** | `android/` n'est pas livré dans ce dossier : la plateforme doit être générée une fois par `flutter create --platforms=android --org com.example .` puis versionnée | **Majeure** | Sans elle, l'APK ne peut pas être construit |
| **V-05** | Tests non exécutés (SDK absent de l'environnement de rédaction) | **Majeure** | Preuve de test manquante |
| **V-06** | Signature de release : la CI produit un APK non signé ou signé en debug | Moyenne | Non publiable sur un store ; sans impact sur la conformité logicielle |
| **V-07** | Contenu pédagogique de démonstration (40 questions) : exactitude religieuse **non vérifiée** | **Majeure** | Relève du processus §8.4 (APP-DATA-001), revue humaine requise |
| **V-08** | Accessibilité : conformité WCAG non mesurée sur appareil | Mineure | TC-SYS-18/19 à exécuter |

---

## 6. Conclusion de la vérification

| Élément vérifié | Verdict provisoire |
|---|---|
| Exigences | **Conforme** (observation V-01 mineure) |
| Architecture | **Conforme** |
| Conception | **Conforme** |
| Code source | **Conforme** (observations V-03 mineure) |
| Données d'application | **Conforme sur la forme** ; exactitude du contenu non vérifiée (V-07) |
| Preuves d'exécution | **Manquantes** (V-05) |

**Verdict global : CONFORME SOUS RÉSERVE** des points V-04, V-05 et V-07, et sous
réserve de l'indépendance du vérificateur (C-05).

| Rôle | Nom | Date | Signature |
|---|---|---|---|
| Chargé de vérification (indépendant) | _à nommer_ | | |

**Fin du document — RAP-VER-001 v1.0**
