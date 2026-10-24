# Dossier documentaire — Quiz Game, SIL 2, NF EN 50128:2011

Ce dossier est le **dossier de conformité SIL 2** du logiciel `quiz_game`
(réfonte du projet « Quiz Game 7 »). Il est destiné à être remis à un
vérificateur, un validateur, un évaluateur ou un organisme certificateur.

> **Statut global : NON CONFORME À CE JOUR.** Le dossier est **complet en
> contenu**, mais trois points bloquent toute déclaration de conformité :
> C-03 (validation non exécutée), C-04 (tests non exécutés, aucune mesure de
> couverture) et C-05 (indépendance des rôles VER/VAL non assurée). Aucun
> résultat de test n'est rapporté comme exécuté : ce qui n'a pas tourné n'est
> pas déclaré conforme. Voir `09-MATRICE-CONFORMITE` §8.

---

## 1. Comment lire ce dossier

| Vous êtes… | Lisez dans cet ordre |
|---|---|
| **Décideur / donneur d'ordre** | `01` (fonctions) → `09` §1 (synthèse de conformité) → `09` §8 (écarts et plan de résorption) |
| **Développeur** | `02` (exigences) → `03` (architecture) → `04` (conception) → `16` (règles de codage) → `05` (tests) |
| **Vérificateur** | `02` → `04` → `05` → `07` (rapport de vérification) → `10` (traçabilité) |
| **Validateur** | `01` → `08` (validation, scénarios VAL-01..10) → `11` (données d'application) |
| **Évaluateur / certificateur** | `09` (matrice de conformité) → `10` (traçabilité) → `12` (assurance qualité) → `13` (configuration) → `14` (outils) |

Chaque document commence par un tableau d'identification : référence, version,
date, statut, référentiel normatif, niveau SIL, entrées, sorties couvertes
(Tableau A.1 de la norme).

---

## 2. Documents

| N° | Référence | Titre | Version | Lignes | Rôle dans le cycle de vie |
|---|---|---|---|---|---|
| 01 | `AN-FON-001` | Analyse fonctionnelle du logiciel | 1.1 | 1039 | Phase 1 : inventaire des 20 fonctions élémentaires (EF-01..EF-20), découpage en 8 groupes, exigences implicites et anomalies du code d'origine (ANO-01..23) |
| 02 | `SRS-001` | Spécification des exigences du logiciel | 1.0 | 314 | **58 exigences** (REQ-001..REQ-080, numérotation avec réserves), 10 interfaces (IF-01..IF-10), hypothèses H1..H8 |
| 03 | `ARCH-001` | Spécification de l'architecture | 1.1 | 420 | 4 couches, **45 composants**, hiérarchie de dépendances, ADR-01..05, stratégie d'intégration |
| 04 | `DD-001` | Spécification de la conception détaillée | 1.0 | 349 | Conception par composant : invariants, algorithmes, pré/post-conditions, cas limites |
| 05 | `SPEC-TESTS-001` | Spécification des tests | 1.0 | 214 | **114 cas spécifiés** : TC-DOM, TC-INF, TC-APP, TC-INT, TC-SYS, TC-PRS, TC-ARCH |
| 06 | `RAP-TESTS-001` | Rapport de tests | 1.0 | 137 | **106 cas automatisés** présents dans `test/`, **0 exécuté dans cet environnement** (SDK absent) ; couverture déclarée non mesurée |
| 07 | `RAP-VER-001` | Rapport de vérification | 1.0 | 167 | Vérification par exigence et par technique (Tableaux A.3, A.4, A.12, A.19, A.21), observations V-01..V-08, dispositions ANO |
| 08 | `RAP-VAL-001` | Plan et rapport de validation | 1.0 | 108 | 10 scénarios VAL-01..10 **non exécutés** ; verdict **NON VALIDÉ** |
| 09 | `MATRICE-CONFORMITE` | Matrice de conformité SIL 2 | 1.0 | 174 | **86 exigences normatives** : 59 conformes, 12 partielles, 13 non conformes, 2 sans objet ; registre C-01..C-13 |
| 10 | `TRACE-001` | Matrice de traçabilité | 1.0 | 198 | EF → REQ (58), REQ → composant → cas de test, ANO → preuve, contrôles automatisés |
| 11 | `APP-DATA-001` | Plan de préparation des données d'application | 1.0 | 163 | 8 thèmes, 40 questions, format, validation automatique, revue humaine obligatoire |
| 12 | `SQAP-001` | Plan d'assurance qualité | 1.0 | 196 | Rôles (Tableau B.1), listes de contrôle LC-01..05, classes d'anomalies, actions A-01..A-10 |
| 13 | `PLAN-CONF-001` | Plan de gestion de la configuration | 1.0 | 155 | Éléments de configuration EC-1..EC-6, baselines BL-0..BL-4, demandes de modification, convention de commit |
| 14 | `OUTILS-001` | Validation des outils | 1.0 | 89 | Classification T1/T2/T3, mesures de maîtrise, outils écartés |
| 15 | `MAINT-001` | Plan de maintenance | 1.0 | 111 | Types de maintenance, procédure, techniques du Tableau A.10, fin de vie |
| 16 | `STD-COD-001` | Norme de codage Dart | 1.0 | 148 | Justification du langage (Tableau A.15/D.54), règles RC-01..RC-20, application automatique, LC-03 |

**Documents de référence joints**

| Fichier | Contenu |
|---|---|
| `REF-NF-EN-50128-2011.pdf` | Texte de la norme (version française, octobre 2011) servant de base aux citations |
| `content_baseline.json` | Empreinte du contenu livré (8 thèmes, 40 questions) utilisée par `tool/validate_content.py --baseline` |

---

## 3. Correspondance avec les livrables exigés (Tableau A.1)

| # | Livrable normatif | Document |
|---|---|---|
| 1 | Plan d'assurance qualité du logiciel | `12-SQAP-001` |
| 2 | Plan de gestion de la configuration | `13-PLAN-CONF-001` |
| 4 | Plan de vérification | `07-RAP-VER-001` §1 |
| 6 | Plan de maintenance | `15-MAINT-001` |
| 7 | Spécification des exigences du logiciel | `02-SRS-001` |
| 9 | Spécification de l'architecture | `03-ARCH-001` |
| 10 | Spécification de la conception | `04-DD-001` |
| 11, 15 | Spécifications d'interface | `02-SRS-001` §6, `03-ARCH-001` §4.3 |
| 12, 13 | Spécifications de tests d'intégration | `05-SPEC-TESTS-001` §4, §5 |
| 14 | Rapport de vérification | `07-RAP-VER-001` |
| 16 | Spécification des tests de composant | `05-SPEC-TESTS-001` §3 |
| 17 | Rapport de tests de composant | `06-RAP-TESTS-001` |
| 19 | Rapport de validation | `08-RAP-VAL-001` |
| 20 | Plan de validation | `08-RAP-VAL-001` §2 |
| 21 | Norme de codage | `16-STD-COD-001` |
| 22 | Spécification des tests d'ensemble | `05-SPEC-TESTS-001` §6 |
| 25 | Plan de préparation des données d'application | `11-APP-DATA-001` |
| 26 | Rapport de validation des outils | `14-OUTILS-001` |
| 30 | Matrice de traçabilité | `10-TRACE-001` |

---

## 4. Ce que ce dossier ne prouve pas

Ce dossier **ne constitue pas une preuve de conformité**. Il documente un
travail de refonte et de mise en conformité ; il ne peut devenir une preuve
qu'après :

1. **exécution effective** de la chaîne d'intégration continue (analyse
   statique, 106 tests, mesure de couverture) dans un environnement disposant du
   SDK Flutter 3.29.2 — cf. C-04 ;
2. **désignation de rôles indépendants** de vérificateur et de validateur
   (§5.1.2.11 de la norme) — cf. C-05 ;
3. **exécution des 10 scénarios de validation** sur appareil réel — cf. C-03 ;
4. **génération et versionnement du projet Android** — cf. C-10.

Les 10 actions correspondantes sont listées dans `12-SQAP-001` §9
(A-01..A-10) avec responsable et critère de clôture.

---

## 5. Conventions

- **Langue** : français. Identifiants de code en anglais (`STD-COD-001` RC-20).
- **Identifiants** : `REQ-nnn` (exigence), `EF-nn` (fonction élémentaire),
  `TC-XXX-nn` (cas de test), `CMP-XXX-nn` (composant), `ANO-nn` (anomalie du
  code d'origine), `C-nn` (non-conformité normative), `V-nn` (observation de
  vérification), `A-nn` (action du SQAP), `DM-nnn` (demande de modification).
- **Numérotation des fichiers** : `NN-REF-version_titre.md`, NN figé une fois
  attribué (PLAN-CONF-001 §2, EC-5).
- **Auteur des documents** : l'agent de développement ; aucune signature de
  vérificateur indépendant n'est simulée.

**Fin du sommaire — dossier au 24 octobre 2026**
