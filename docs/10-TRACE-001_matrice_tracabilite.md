# TRACE-001 — Matrice de Traçabilité

| | |
|---|---|
| **Référence** | TRACE-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §5.3.2.7-5.3.2.10, §6.5.4.14-17 ; Tableau A.5 #5 (**HR** à SIL 2), Tableau A.9 #7 |
| **Objet** | Démontrer la chaîne `Besoin → Exigence → Composant → Test → Preuve` et la chaîne inverse |

---

## 1. Chaîne documentaire

```
AN-FON-001 (analyse, 20 EF / 12 RG / 12 ENF / 23 ANO)
     │
     ├──► SRS-001 (44 REQ)
     │         │
     │         ├──► ARCH-001 (45 composants, 10 interfaces)
     │         │         │
     │         │         └──► DD-001 (conception interne)
     │         │                   │
     │         │                   └──► lib/** (code, 3 037 lignes — 48 fichiers)
     │         │
     │         └──► SPEC-TESTS-001 (114 cas spécifiés)
     │                   │
     │                   └──► test/** (144 cas automatisés) ──► RAP-TESTS-001
     │
     └──► MATRICE-CONFORMITE (86 exigences normatives, 13 non-conformités)
```

Chaque flèche est matérialisée ci-dessous par une ligne de matrice.

---

## 2. Besoin → Exigence

| Analyse (AN-FON-001) | Exigences SRS-001 | Remarque |
|---|---|---|
| EF-01 thèmes en grille | REQ-061 | — |
| EF-02 score total | REQ-020, REQ-024 | — |
| EF-03 remise à zéro du score | REQ-023, REQ-065 | — |
| EF-04 liste des niveaux | REQ-010, REQ-017, REQ-062 | — |
| EF-05 déverrouillage | REQ-012, REQ-013, REQ-014, REQ-022 | Durci : 4 cas explicites (ANO-09) |
| EF-06 reset progression | REQ-016, REQ-065 | — |
| EF-07 chargement du contenu | REQ-001, REQ-004, REQ-008 | — |
| EF-08 validation des questions | REQ-005, REQ-006 | — |
| EF-09 ordre aléatoire | REQ-007, REQ-078 | Rendu déterministe (ANO-04) |
| EF-10 déroulé séquentiel | REQ-031, REQ-036, REQ-063 | — |
| EF-11 chronomètre | REQ-030, REQ-034, REQ-063 | Échéance absolue (ANO-11) |
| EF-12 réponse définitive | REQ-032, REQ-033 | Validation d'appartenance ajoutée |
| EF-13 calcul du score | REQ-021 | Diagnostic d'incohérence (ANO-13) |
| EF-14 cumul du score | REQ-022, REQ-042 | Transaction unique (ANO-06) |
| EF-15 écran de résultat | REQ-038, REQ-064 | Bandeau conditionnel (ANO-09) |
| EF-16 cycle de vie | REQ-037 | Temps réel (ANO-10) |
| EF-17 fond animé | REQ-047 (via IF-09), REQ-060 | — |
| EF-18 navigation | REQ-060, REQ-064 | — |
| EF-19 gestion d'erreur | REQ-050, REQ-051, REQ-060, REQ-072 | Messages catalogués (ANO-14) |
| EF-20 persistance et migration | REQ-011, REQ-015, REQ-040, REQ-041 | Non destructive (ANO-06) |
| RG-01 invariants question | REQ-005 | — |
| RG-02 niveau 1 toujours débloqué | REQ-010 | — |
| RG-03/04/05/06 règles de jeu | REQ-012, REQ-014, REQ-032, REQ-033, REQ-035, REQ-021 | — |
| RG-07 score croissant | REQ-020, REQ-023 | — |
| RG-08 durée par question | REQ-030 | — |
| RG-09 identifiant de thème | REQ-006 | Validation avant I/O |
| RG-10/11 clés et catalogue | REQ-003, REQ-040, REQ-011 | Document unique |
| RG-12 niveaux issus du catalogue | REQ-004, REQ-008 | Validateur CI (ANO-19) |
| ENF-01 performance | REQ-070, REQ-071 | — |
| ENF-02 robustesse | REQ-072 | — |
| ENF-03 intégrité des données | REQ-040, REQ-041 | CRC + version |
| ENF-04 maintenabilité | REQ-073 | — |
| ENF-05 testabilité | REQ-074 | Test d'architecture |
| ENF-06 portabilité | REQ-076 | — |
| ENF-07 accessibilité | REQ-067 | — |
| ENF-08 traçabilité | TRACE-001 (ce document) | — |
| ENF-09 déterminisme | REQ-078 | — |
| ENF-10 vie privée | REQ-077 | — |
| ENF-11 observabilité | REQ-052 | — |
| ENF-12 capacité | REQ-003 | — |

---

## 3. Exigence → Composant → Test

| Exigence | Composants | Cas de test | Statut test |
|---|---|---|---|
| REQ-001 | DOM-01, DOM-09, INF-01 | TC-DOM-36, TC-DOM-39, TC-DOM-40 ; TC-INF-01, TC-INF-03 | automatisé |
| REQ-002 | DOM-09, INF-01 | TC-DOM-37, TC-DOM-38 ; TC-INF-02, TC-INF-05 | automatisé |
| REQ-003 | DOM-02, DOM-04, INF-01 | TC-DOM-03, 04, 10, 11, 12 ; TC-INF-06 | automatisé |
| REQ-004 | INF-01 | TC-INF-07 | automatisé |
| REQ-005 | DOM-03, INF-01 | TC-DOM-05..09 ; TC-INF-08, 09 | automatisé |
| REQ-006 | DOM-01 | TC-DOM-01, 02 | automatisé |
| REQ-007 | APP-02 | TC-APP-07, 08 | **à automatiser** |
| REQ-008 | INF-01 | TC-INF-03..05 | automatisé |
| REQ-010 | APP-01, DOM-04 | TC-SYS-02 | widget |
| REQ-011 | INF-02, INF-04 | TC-INF-14, 19, 20 | automatisé |
| REQ-012 | DOM-07 | TC-DOM-31, 33 ; TC-APP-02, 05 | automatisé |
| REQ-013 | DOM-07 | TC-DOM-32 ; TC-APP-04 | automatisé |
| REQ-014 | DOM-07 | TC-DOM-34, 35 ; TC-APP-06 | automatisé |
| REQ-015 | INF-04 | TC-INF-19, 20 | automatisé |
| REQ-016 | APP-05 | TC-APP-09 ; TC-SYS-09 | partiel |
| REQ-017 | DOM-04, APP-01 | TC-SYS-02 | widget |
| REQ-020 | APP-06 | TC-SYS-10 | widget |
| REQ-021 | DOM-06 | TC-DOM-27, 28, 30 | automatisé |
| REQ-022 | APP-04 | TC-APP-01 | automatisé |
| REQ-023 | APP-07 | TC-APP-10 ; TC-SYS-10 | partiel |
| REQ-024 | DOM-06 | TC-DOM-29 | automatisé |
| REQ-030 | DOM-05 | TC-DOM-14, 15 | automatisé |
| REQ-031 | DOM-05 | TC-DOM-17 | automatisé |
| REQ-032 | DOM-05 | TC-DOM-19 | automatisé |
| REQ-033 | DOM-05 | TC-DOM-18 | automatisé |
| REQ-034 | DOM-05 | TC-DOM-21, 22, 26 ; TC-PRS-03 | automatisé |
| REQ-035 | DOM-05 | TC-DOM-23, 25 | automatisé |
| REQ-036 | DOM-05 | TC-DOM-16, 20 | automatisé |
| REQ-037 | DOM-05, PRS-03 | TC-DOM-24 ; TC-SYS-16 | partiel |
| REQ-038 | APP-04, PRS-04 | TC-SYS-04, 06 | widget/appareil |
| REQ-040 | INF-02, INF-03 | TC-INF-10, 11, 16 | automatisé |
| REQ-041 | INF-02, INF-04 | TC-INF-12..15, 17 | automatisé |
| REQ-042 | INF-04 | test de concurrence (dépôt) | automatisé |
| REQ-043 | APP-04, APP-05, APP-07 | TC-APP-04 | automatisé |
| REQ-044 | INF-04, APP-04 | TC-INF-18 ; TC-APP-03 | automatisé |
| REQ-050 | DOM-08 | TC-ARCH-02 | automatisé |
| REQ-051 | PRS-06 | TC-PRS-08 | **à automatiser** |
| REQ-052 | APP-12 | TC-APP-03 (journal) | automatisé |
| REQ-053 | PRS-01..05 | revue RAP-VER-001 §4.2 | revue |
| REQ-060 | PRS-07 | TC-INT-06 ; TC-PRS-06 | automatisé |
| REQ-061 | PRS-01, PRS-11 | TC-PRS-04 | automatisé |
| REQ-062 | PRS-02, PRS-08 | TC-PRS-07 | automatisé |
| REQ-063 | PRS-03, PRS-09 | TC-PRS-01, 02 | automatisé |
| REQ-064 | PRS-04 | TC-SYS-04, 05 | **à automatiser** |
| REQ-065 | PRS-02, PRS-05 | TC-SYS-08, 09 | appareil |
| REQ-066 | PRS-06 | revue RAP-VER-001 §4.2 | revue |
| REQ-067 | PRS-06..09 | TC-SYS-18, 19 | appareil |
| REQ-070 | transverse | TC-SYS-13 ; TC-INT-09 | appareil |
| REQ-071 | transverse | TC-SYS-14 | appareil |
| REQ-072 | INF-02, INF-04 | TC-INF-17 ; TC-SYS-17 | automatisé |
| REQ-073 | transverse | TC-ARCH-04, 05 | automatisé |
| REQ-074 | transverse | TC-ARCH-01..03 | automatisé |
| REQ-075 | transverse | `check_coverage.py` | CI |
| REQ-076 | PRS | TC-SYS-15 | appareil |
| REQ-077 | transverse | TC-SYS-20 | revue manifeste |
| REQ-078 | APP-02, INF-05 | TC-APP-07 | **à automatiser** |
| REQ-079 | CI | `ci.yml` (diff `pubspec.yaml`) | CI |
| REQ-080 | PRS-06 | revue | revue |

**Couverture** : 58 exigences sur 58 (100 %) ont au moins un composant et au
moins un cas de test identifiés. **Aucune exigence orpheline.**

---

## 4. Anomalie → Traitement → Preuve

| Anomalie (v7) | Traitement | Preuve |
|---|---|---|
| ANO-01 aucun test | 144 cas + CI bloquante | `test/**`, `ci.yml` |
| ANO-02 logique dans l'IHM | 4 couches, domaine pur | `test/architecture_test.dart` |
| ANO-03 pas d'injection | 5 ports + racine de composition | ARCH-001 §3 |
| ANO-04 aléa non graine | algèbre Fisher-Yates + `RandomSource` | TC-APP-07 |
| ANO-05 point d'entrée mort | `main.dart` unique | TC-ARCH-06 |
| ANO-06 persistance non atomique | document unique + verrou + ordre migration | TC-APP-01, TC-INF-19/20 |
| ANO-07 pas de contrôle d'intégrité | CRC-32 + version + bornes | TC-INF-10..17 |
| ANO-08 `.last` non gardé | catalogue typé, plus d'index brut | TC-SYS-09 |
| ANO-09 faux déverrouillage | `UnlockOutcome` à 4 cas | TC-DOM-31..35 |
| ANO-10 chrono contournable | échéance absolue | TC-DOM-24 |
| ANO-11 dérive | suppression du décrément | TC-DOM-21 |
| ANO-12 `0/0` en release | validation à la construction | TC-DOM-15 |
| ANO-13 troncature silencieuse | `hasLengthMismatch` journalisé | TC-DOM-28 |
| ANO-14 messages techniques | catalogue + repli générique | TC-PRS-08 |
| ANO-15 règle de réussite absente | H3 tranchée, documentée | TC-APP-02 |
| ANO-16 code mort | suppression | TC-ARCH-06 |
| ANO-17 assets dupliqués | `pubspec` minimal + validateur | `validate_content.py` |
| ANO-18 `audioplayers` inutile | dépendance retirée | `pubspec.yaml` |
| ANO-19 niveau sans fichier | validateur bloquant | `validate_content.py` |
| ANO-20 i18n/accessibilité | `AppStrings` + sémantique | TC-SYS-18/19 (à exécuter) |
| ANO-21 CI sans test / signature debug | CI créée ; signature **ouverte** (C-08) | `ci.yml` |
| ANO-22 deux `MainActivity` | projet Android unique (C-10) | — |
| ANO-23 build réécrivant la source | CI sans réécriture + contrôle `diff` | REQ-079 |

**Taux de traitement : 21 anomalies / 23 corrigées ; 2 partiellement
(ANO-21 signature, ANO-22 plateforme), tracées en C-08 et C-10.**

---

## 5. Vérification automatique de la traçabilité

La cohérence de cette matrice est contrôlée par deux moyens :

1. **Les identifiants** : la convention demande qu'une exigence soit citée dans
   le code qu'elle gouverne. État constaté :
   `grep -rho "REQ-[0-9]\+" lib | sort -u` → **41 exigences citées sur 58**.
   Les 17 autres sont des exigences de forme (schéma, alias de clés, bornes)
   vérifiées uniquement par les tests : l'absence de citation est **admise mais
   à combler** lors de la revue de code (action A-03, SQAP-001 §8) ;
2. **Les tests** : chaque exigence C1 possède au moins un cas automatisé dont le
   nom cite l'identifiant (convention de nommage de SPEC-TESTS-001).

**Fin du document — TRACE-001 v1.0**
