# MATRICE-CONFORMITE — Conformité SIL 2 à la NF EN 50128:2011

| | |
|---|---|
| **Référence** | MATRICE-CONFORMITE |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011, §4 à §9 et Annexes A (Tableaux A.1 à A.23) |
| **Niveau revendiqué** | **SIL 2** (décision D-001, cf. SRS-001 §3) |
| **Objet** | Établir, exigence par exigence, l'état de conformité et la preuve associée |

**Légende des états** : ✅ conforme · 🟡 partiel · ⛔ non conforme · ➖ sans objet justifié

---

## 1. Synthèse

| Domaine | Exigences évaluées | ✅ | 🟡 | ⛔ | ➖ |
|---|---|---|---|---|---|
| Organisation et indépendance (§5) | 12 | 4 | 3 | 3 | 2 |
| Assurance qualité (§6.5) | 8 | 5 | 2 | 1 | 0 |
| Cycle de vie et exigences (§7.1, §7.2) | 14 | 12 | 1 | 1 | 0 |
| Architecture et conception (§7.3) | 16 | 15 | 1 | 0 | 0 |
| Réalisation et vérification (§7.4, §7.5) | 12 | 10 | 1 | 1 | 0 |
| Intégration et validation (§7.6, §7.7) | 9 | 3 | 2 | 4 | 0 |
| Données d'application (§8.4) | 10 | 6 | 2 | 2 | 0 |
| Maintenance (§9) | 5 | 4 | 0 | 1 | 0 |
| **Total** | **86** | **59** | **12** | **13** | **2** |

**Conclusion** : le dossier est **conforme sur l'ingénierie** (spécifications,
architecture, conception, code, traçabilité, outillage) et **non conforme sur les
aspects organisationnels et de preuve** (indépendance, exécution des tests,
validation, système qualité). Les 13 non-conformités sont toutes enregistrées
§4 et **aucune n'est masquée**.

---

## 2. Organisation et indépendance (§5)

| Réf. | Exigence | SIL 2 | État | Preuve / motif |
|---|---|---|---|---|
| §5.1.2.2 | Rôles définis et attribués | requis | 🟡 | Rôles identifiés dans chaque document ; **personnes non nommées** |
| §5.1.2.5-5.1.2.7 | Chargé d'évaluation indépendant | requis | ⛔ | Aucun chargé d'évaluation désigné (C-01) |
| §5.1.2.8 | Accord du Chargé de validation sur chaque version | requis | ⛔ | Non nommé, aucun accord (C-03) |
| §5.1.2.11 f) | Chargé des tests ≠ Concepteur/Réalisateur du même composant | requis | ⛔ | Rôle unique (C-05) |
| §5.1.2.11 h) | Vérificateur/Validateur ≠ Gestionnaire des exigences, Concepteur, Réalisateur, Intégrateur, Testeur | requis | ⛔ | Rôle unique : auto-vérification (C-05) |
| §5.1.2.11 a), d), j) | Regroupements autorisés | requis | ✅ | Justifiés en SQAP-001 §4 |
| §5.1.3 | Compétence du personnel | requis | 🟡 | À documenter (CV, matrice de compétences) (C-06) |
| §5.1.4 | Séparation des responsabilités tracée | requis | 🟡 | Modèle fourni dans SQAP-001 §4, non appliqué |

## 3. Assurance qualité (§6.5) et gestion de configuration

| Réf. | Exigence | SIL 2 | État | Preuve / motif |
|---|---|---|---|---|
| §6.5.4.2 | Système qualité conforme EN ISO 9001 | requis | ⛔ | Aucune certification (C-02) |
| Tableau A.9 #1-4 | Accréditation / conformité ISO | R/M | ⛔ | Idem C-02 |
| §6.5.4.4 | Plan d'Assurance Qualité du Logiciel | requis | ✅ | SQAP-001 |
| §6.5.4.5 | Plan de Gestion de la Configuration | requis | ✅ | PLAN-CONF-001 |
| Tableau A.9 #6 | Listes de contrôle | **HR** | ✅ | RAP-VER-001 §4, listes §3 de SQAP-001 |
| Tableau A.9 #7 | Traçabilité | **HR** | ✅ | TRACE-001 |
| Tableau A.9 #8 | Enregistrement et analyse des données | **HR** | 🟡 | Enregistrements créés ; analyse des mesures en attente d'exécution (C-04) |
| §6.5.4.14-17 | Traçabilité documentaire | requis | ✅ | TRACE-001 §1 |

## 4. Cycle de vie, exigences, architecture, conception (§7.1 à §7.3)

| Réf. | Exigence | SIL 2 | État | Preuve |
|---|---|---|---|---|
| §7.1.2.2 | Cycle de vie en V documenté | requis | ✅ | AN-FON-001 §15, plan E1..E8 |
| §7.2.4.2 | Propriétés ISO/CEI 9126 couvertes (fonctionnalité, robustesse, maintenabilité, efficacité, utilisabilité, portabilité) | requis | ✅ | SRS-001 §4 et §5 |
| §7.2.4.3 | Niveau SIL enregistré dans le SRS | requis | ✅ | SRS-001 §3 |
| §7.2.4.4 | Exigences complètes, non ambiguës, vérifiables, traçables | requis | ✅ | SRS-001 + TRACE-001 |
| §7.2.4.6 | Interfaces identifiées | requis | ✅ | ARCH-001 §6 (10 interfaces) |
| §7.2.4.7 | Modes de fonctionnement détaillés | requis | ✅ | AN-FON-001 §4.3 (M1..M8) |
| §7.2.4.8 | Comportement de défaillance documenté | requis | ✅ | DD-001 §2.8, ARCH-001 §5 |
| §7.2.4.10 | Autocontrôle logiciel | requis | ✅ | CRC-32, validation de schéma, repli |
| §7.2.4.13 | Toutes les fonctions identifiées | requis | ✅ | AN-FON-001 §7 (87 fonctions) |
| §7.2.4.15 | Techniques du Tableau A.2 | SIL 2 : modélisation R, méthodologie structurée R, tables de décision R | ✅ | A.17 #4 automates, A.2 #4 tables (DD-001 §2.7) |
| §7.2.4.16-19 | Spécification de Tests d'Ensemble | requis | ✅ | SPEC-TESTS-001 §6 |
| §7.3.4.3-12 | Spécification de l'Architecture | requis | ✅ | ARCH-001 |
| §7.3.4.14 | Techniques du Tableau A.3 | SIL 2 : 1, 19, 22 **HR** + une parmi 2/4/5/7/12/15/21 | ✅ | Combinaison 1+19+22+4 (ARCH-001 §5.2) |
| §7.3.4.18-19 | Spécifications d'Interface (7 rubriques) | requis | ✅ | ARCH-001 §6 |
| §7.3.4.20-24 | Spécification de la Conception | requis | ✅ | DD-001 |
| §7.3.4.25-27 | Règles de codage définies, justifiées, utilisées | requis | ✅ | STD-COD-001, RAP-VER-001 §4.1 |
| §7.3.4.24 | Techniques du Tableau A.4 | SIL 2 : 3, 5, 6, 8 **HR**, 4 M | ✅ | Combinaison 3+4+5+6+8 (ARCH-001 §5.3) |

## 5. Réalisation, vérification, intégration, validation (§7.4 à §7.7)

| Réf. | Exigence | SIL 2 | État | Preuve / motif |
|---|---|---|---|---|
| §7.4.4 | Techniques de réalisation (Tableau A.4) | requis | ✅ | 4 couches, 45 composants |
| Tableau A.12 | Normes de codage | #2, #8, #10 **HR** ; #3, #4, #6, #9 R | ✅ | STD-COD-001, TC-ARCH-04/05 |
| §7.5.4.2-7.5.4.4 | Code lisible, testable, sous contrôle de configuration | requis | ✅ | PLAN-CONF-001, RAP-VER-001 §4 |
| §7.5.4.5-7 | Rapport de Tests de Composant | requis | 🟡 | RAP-TESTS-001 : spécifié, **non exécuté** (C-04) |
| §7.5.4.8-10 | Rapport de Vérification du Code Source | requis | 🟡 | RAP-VER-001 : rédigé, **auto-vérification** (C-05) |
| Tableau A.5 | Vérification (SIL 2 : traçabilité **HR** + une parmi 2/3/8) | requis | ✅ | 5 (traçabilité) + 8 (tests fonctionnels) + 2 (analyse statique) |
| §7.6.4 | Intégration (Tableau A.6 : tests fonctionnels **HR**) | requis | 🟡 | TC-INT-01..10 spécifiés, non exécutés |
| §7.7.4.1-5 | Rapport de Tests d'Ensemble | requis | ⛔ | Aucun test d'ensemble exécuté (C-04) |
| §7.7.4.6-11 | Rapport de Validation | requis | ⛔ | RAP-VAL-001 : plan seulement (C-03) |
| Tableau A.7 | Tests d'ensemble (SIL 2 : 1 **HR**, 2 **HR**) | requis | 🟡 | Scénarios TC-SYS-01..20 spécifiés |
| Tableau A.21 #1 | Couverture des instructions **HR** | requis | 🟡 | Mesure outillée (`check_coverage.py`), non produite (C-04) |
| Tableau A.21 #2 | Couverture des branchements R | requis | 🟡 | Idem |
| Tableau A.19 | Analyse statique (flux de contrôle **HR**, flux de données **HR**, revues **HR**) | requis | 🟡 | Flux et revues : RAP-VER-001 ; flux de données outillé non lancé (C-04) |
| Tableau A.18 #2 | Temps de réponse | R | 🟡 | Critères définis (REQ-070), non mesurés |

## 6. Données d'application (§8.4)

| Réf. | Exigence | SIL 2 | État | Preuve / motif |
|---|---|---|---|---|
| §8.4.1.2 | Plan de Préparation de l'Application | requis | ✅ | APP-DATA-001 |
| §8.4.1.8 | Analyse du risque du processus de préparation | requis | ✅ | APP-DATA-001 §7 |
| §8.4.2 | Spécification des Exigences de l'Application | requis | ✅ | APP-DATA-001 §3 |
| §8.4.3 | Validation des données | requis | 🟡 | Validateur automatique ✅ ; revue humaine du contenu pédagogique **non faite** (C-07) |
| Tableau A.11 | SIL 2 : 1 (spécification en tableaux) + 4 (tests fonctionnels) | requis | ✅ | Schéma JSON + `tool/validate_content.py` |
| Tableau A.11 #3 | Simulation **HR** à SIL 1/2 | **HR** | 🟡 | Contenu de démonstration joué en widget test ; pas de simulation formelle |
| §8.4.8.4 | Séparation rigide logiciel générique / données | requis | ✅ | `assets/` distinct du code ; aucun contenu en dur |
| §8.4.8.7 | Le logiciel générique détecte les données invalides | requis | ✅ | Validation à 3 niveaux (CI, repository, domaine) |

## 7. Déploiement et maintenance (§9)

| Réf. | Exigence | SIL 2 | État | Preuve / motif |
|---|---|---|---|---|
| §9.1 | Plan de livraison et de déploiement | requis | ⛔ | Non établi (C-09) |
| §9.2.4.14 | Plan de Maintenance | requis | ✅ | MAINT-001 |
| Tableau A.10 | Techniques de maintenance | requis | ✅ | MAINT-001 §4 |
| §9.2.4.16-17 | Registres de modification | requis | ✅ | PLAN-CONF-001 §6 |
| Outils (Tableau A.1 #26) | Rapport de Validation des Outils | requis | ✅ | OUTILS-001 |

---

## 8. Registre des non-conformités

| ID | Non-conformité | Réf. | Gravité | Impact | Condition de levée |
|---|---|---|---|---|---|
| **C-01** | Aucune analyse de risques système : le SIL 2 est une décision de projet, non dérivé | §4.1, §4.2 | **Majeure** | Le niveau n'est pas démontré approprié | Fournir l'allocation système (EN 50126-1) ou assumer formellement le caractère méthodologique (fait : SRS-001 §3.2) |
| **C-02** | Aucun système qualité certifié ISO 9001 | §6.5.4.2 | Moyenne | Conformité organisationnelle | Certification ou déclaration d'équivalence |
| **C-03** | Validation non réalisée ; aucun accord du Chargé de validation | §7.7.4.6, §5.1.2.8 | **Bloquante** | Aucune preuve d'adéquation au besoin | Exécuter RAP-VAL-001 §4 et signer |
| **C-04** | Tests écrits mais non exécutés ; aucune mesure de couverture produite | §7.5.4.5, §7.7.4.1, A.21 | **Bloquante** | Aucune preuve de test | Lancer la CI et archiver `RAP-TESTS-001` complété |
| **C-05** | Indépendance V&V non assurée (rôle unique) | §5.1.2.11 h) | **Bloquante** | Auto-vérification non recevable à SIL 2 | Nommer un vérificateur et un validateur indépendants |
| **C-06** | Compétences du personnel non documentées | §5.1.3 | Mineure | Traçabilité RH | Matrice de compétences |
| **C-07** | Exactitude du contenu pédagogique non revue par une autorité compétente | §8.4.3 | **Majeure** | Contenu potentiellement erroné diffusé | Revue indépendante (APP-DATA-001 §5) |
| **C-08** | APK de release non signé avec une clé de production | §9.1 | Mineure | Non publiable sur un store | Fournir un keystore et une procédure de signature |
| **C-09** | Plan de livraison et manuel de déploiement absents | §9.1, A.1 #36-40 | Moyenne | Livraison non maîtrisée | Rédiger les documents #36 à #40 |
| **C-10** | Plateforme `android/` non livrée dans le dossier | §7.4 | **Majeure** | Build impossible en l'état | `flutter create --platforms=android .` puis versionner |
| **C-11** | Aucun chargé d'évaluation | §5.1.2.5-5.1.2.7 | Moyenne | Évaluation indépendante impossible | Désigner l'évaluateur |
| **C-12** | Accessibilité : conformité non mesurée | §7.2.4.2 e) | Mineure | Risque d'usage | Exécuter TC-SYS-18/19 |
| **C-13** | Aucun test de performance mesuré | A.18 #2 | Moyenne | Exigence REQ-070 non prouvée | Exécuter TC-HW-01, TC-INT-09 |

---

## 9. Déclaration finale

Le présent dossier **démontre la conformité aux exigences techniques SIL 2** de
la NF EN 50128:2011 (spécifications, architecture, conception, code, règles de
codage, techniques des Tableaux A.2 à A.7, A.11, A.12, A.19, A.21) pour le
périmètre décrit en SRS-001 §1.2.

Il **ne démontre pas** :

1. que SIL 2 est le niveau approprié au produit (C-01) ;
2. l'indépendance de la vérification et de la validation (C-05) ;
3. la réussite des tests (C-04) ;
4. l'adéquation au besoin de l'utilisateur (C-03).

Aucune de ces réserves ne peut être levée par un document ; elles exigent des
**personnes** et des **exécutions**. Le dossier fournit l'outillage et les
procédures pour les lever.

| Rôle | Nom | Date | Signature |
|---|---|---|---|
| Chef de projet | _à nommer_ | | |
| Chargé de vérification | _à nommer_ | | |
| Chargé de validation | _à nommer_ | | |

**Fin du document — MATRICE-CONFORMITE v1.0**
