# RAP-TESTS-001 — Rapport de Tests des Composants et d'Intégration

| | |
|---|---|
| **Référence** | RAP-TESTS-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §6.1.4.5, §7.5.4.5 à 7.5.4.7, §7.6.4 ; Tableaux A.5, A.6, A.21 |
| **Niveau** | SIL 2 |
| **Entrées** | SPEC-TESTS-001 v1.0, code source `lib/` |
| **Rôle responsable** | Chargé des tests (distinct du Réalisateur — §5.1.2.11 f) |

---

## 1. Statut d'exécution — déclaration obligatoire

> ⚠️ **Les tests n'ont pas été exécutés dans l'environnement de production de ce
> dossier.** Le SDK Dart/Flutter n'est pas disponible dans l'environnement de
> rédaction : aucune commande `flutter test` n'a pu y être lancée.
>
> Ce rapport est donc, en l'état, un **rapport de préparation** : il atteste de
> l'existence, de la spécification et de la traçabilité des cas, **pas** de leur
> réussite. Conformément au §6.1.4.5, il ne peut être accepté comme preuve de
> test qu'après exécution et signature des résultats (§6).
>
> La chaîne d'exécution est prête et bloquante : `.github/workflows/ci.yml`
> lance `flutter analyze`, `dart format --set-exit-if-changed`, `flutter test
> --coverage` puis `tool/check_coverage.py`. **Aucun artefact ne peut être
> produit si un test échoue ou si la couverture est insuffisante.**

---

## 2. Ce qui a été vérifié sans SDK

| Vérification | Méthode | Résultat |
|---|---|---|
| Validation des données d'application | `python3 tool/validate_content.py` (exécuté) | **CONFORME** — 8 thèmes, 40 questions, 0 erreur |
| Détection d'erreurs du validateur | Injection volontaire de 3 défauts (option dupliquée, bonne réponse absente, fichier de niveau manquant) | **3 erreurs détectées**, code de sortie 1 |
| Analyse de la structure du code | Revue fichier par fichier (RAP-VER-001 §3) | Conforme aux règles de DD-001 §6 |
| Volumétrie | `wc -l` sur `lib/` | 3 037 lignes — 48 fichiers, 0 fichier > 200 lignes |
| Imports interdits | Revue par script (voir TC-ARCH-01..03) | Aucune violation constatée à la lecture |

---

## 3. Inventaire des cas exécutables (144 cas)

| Fichier de test | Cas | Cas spécifiés couverts |
|---|---|---|
| `test/domain/values_test.dart` | 8 | TC-DOM-01..04, TC-DOM-10..12 |
| `test/domain/question_test.dart` | 11 | TC-DOM-05..09, TC-DOM-30 |
| `test/domain/scoring_rules_test.dart` | 5 | TC-DOM-27..29 |
| `test/domain/unlock_policy_test.dart` | 5 | TC-DOM-31..35 |
| `test/domain/quiz_session_test.dart` | 15 | TC-DOM-13..26 |
| `test/domain/quiz_theme_test.dart` | 5 | TC-DOM-36..40 |
| `test/infrastructure/asset_question_repository_test.dart` | 13 | TC-INF-01..09 |
| `test/infrastructure/state_codec_test.dart` | 12 | TC-INF-10..16 |
| `test/infrastructure/prefs_state_repository_test.dart` | 11 | TC-INF-17..20 |
| `test/application/start_quiz_session_test.dart` | 7 | TC-APP-07, TC-APP-08 |
| `test/application/answer_question_test.dart` | 6 | TC-APP-09, TC-APP-10 |
| `test/application/load_level_map_test.dart` | 6 | TC-APP-01 |
| `test/application/finish_quiz_session_test.dart` | 6 | TC-APP-02..06 |
| `test/application/reset_level_progress_test.dart` | 5 | TC-APP-03 (progression) |
| `test/application/manage_score_test.dart` | 6 | TC-APP-04, TC-APP-05 (score) |
| `test/presentation/quiz_board_test.dart` | 3 | TC-PRS-01..03 |
| `test/presentation/theme_selection_test.dart` | 3 | TC-PRS-04..06 |
| `test/integration/quiz_flow_test.dart` | 8 | TC-INT-01..08 |
| `test/architecture_test.dart` | 9 | TC-ARCH-01..06 |
| **Total** | **144** | 90 cas spécifiés couverts / 114 |

### 3.1 Couverture de la spécification de tests

| Catégorie | Cas spécifiés | Cas spécifiés couverts par un test | Cas automatisés |
|---|---|---|---|
| Composant domaine (TC-DOM) | 40 | **40** | 49 |
| Composant infrastructure (TC-INF) | 20 | **20** | 36 |
| Composant application (TC-APP) | 10 | **10** | 30 |
| Intégration (TC-INT) | 10 | **8** | 8 |
| Ensemble (TC-SYS) | 20 | 0 | — |
| Widgets (TC-PRS) | 8 | **6** | 6 |
| Architecture (TC-ARCH) | 6 | **6** | 9 |
| **Total** | **114** | **90 (79 %)** | **144** |

**Cas spécifiés non encore automatisés** (24) : TC-INT-09..10 (latence sur
horloge réelle, remise à zéro du score via l'écran), TC-SYS-01..20 (appareil
requis) et TC-PRS-07..08 (messages d'erreur affichés). Ces cas sont exécutables
en E2/E3.

**Lecture honnête de ce tableau** : 144 cas automatisés pour 90 cas spécifiés
couverts signifie que plusieurs assertions servent un même cas spécifié. Le
chiffre à suivre est la colonne « cas spécifiés couverts » (79 %), pas le nombre
d'assertions. La couverture de **code** n'est pas mesurée ici.

---

## 4. Résultats par composant — à compléter après exécution

| Composant | Cas | Exécutés | Réussis | Échoués | Couverture lignes | Couverture branchements | Verdict |
|---|---|---|---|---|---|---|---|
| DOM-01 `ThemeId` | 4 | — | — | — | — | — | ☐ |
| DOM-02 `LevelNumber` | 4 | — | — | — | — | — | ☐ |
| DOM-03 `Question` | 8 | — | — | — | — | — | ☐ |
| DOM-04 `LevelCatalog` | 4 | — | — | — | — | — | ☐ |
| DOM-05 `QuizSession` | 15 | — | — | — | — | — | ☐ |
| DOM-06 `ScoringRules` | 5 | — | — | — | — | — | ☐ |
| DOM-07 `UnlockPolicy` | 5 | — | — | — | — | — | ☐ |
| DOM-08 Erreurs | couvert indirectement | — | — | — | — | — | ☐ |
| DOM-09 `QuizTheme` | 5 | — | — | — | — | — | ☐ |
| APP-01..06 (cas d'usage) | 30 | — | — | — | — | — | ☐ |
| INF-01 Contenu | 13 | — | — | — | — | — | ☐ |
| INF-02/03 Codec + CRC | 12 | — | — | — | — | — | ☐ |
| INF-04 Dépôt d'état | 11 | — | — | — | — | — | ☐ |
| PRS Widgets | 6 | — | — | — | — | — | ☐ |
| Architecture | 9 | — | — | — | — | — | ☐ |

**Seuils exigés** (SPEC-TESTS-001 §9) : 100 % des instructions et branchements
sur `domain` et `application`, ≥ 90 % sur `infrastructure`. Le non-respect d'un
seuil fait échouer la CI (`tool/check_coverage.py`).

---

## 5. Analyse des risques de non-exécution

| Risque | Probabilité | Impact | Mesure |
|---|---|---|---|
| Erreur de compilation Dart non détectée ici | Moyenne | Élevé | `flutter analyze --fatal-infos` bloquant en CI ; aucune signature d'API exotique utilisée |
| Écart d'API entre `flutter_test` et l'usage fait | Faible | Moyen | APIs stables (`test`, `testWidgets`, `expect`, `findsOneWidget`) |
| Test de widget instable (timers du fond animé) | Faible | Faible | `CyclingBackground` annule son timer dans `dispose` ; les tests de quiz évitent `pumpAndSettle` |
| Couverture inférieure aux seuils | Moyenne | Moyen | Des cas dédiés couvrent chaque branche des fonctions C1 ; ajustement attendu à la marge |

---

## 6. Procédure d'exécution et de signature

```bash
flutter pub get
flutter analyze --fatal-infos --fatal-warnings
dart format --output=none --set-exit-if-changed lib test
flutter test --coverage --reporter expanded
python3 tool/check_coverage.py coverage/lcov.info
python3 tool/validate_content.py --baseline docs/content_baseline.json
```

| Rôle | Nom | Date | Résultat | Signature |
|---|---|---|---|---|
| Chargé des tests | _à nommer_ | | ☐ Conforme ☐ Non conforme | |
| Chargé de vérification | _à nommer_ (indépendant) | | ☐ Accepté ☐ Refusé | |
| Chargé de validation | _à nommer_ | | ☐ Accepté ☐ Refusé | |

---

## 7. Conclusion

| | |
|---|---|
| **Cas spécifiés** | 114 (SPEC-TESTS-001) |
| **Cas automatisés** | 144 cas de test dans 19 fichiers (`test/**`) |
| **Cas exécutés** | **0** — SDK absent de l'environnement de rédaction |
| **Couverture de code mesurée** | **non mesurée** (exige `flutter test --coverage`) |
| **Verdict** | **NON CONCLUANT** — preuve de test à produire |

Ce rapport **ne démontre pas** la conformité du logiciel : il démontre que la
stratégie de test est complète, traçable et outillée. L'exécution en intégration
continue est la condition d'acceptation de l'étape E7 (plan de refonte).

**Fin du document — RAP-TESTS-001 v1.0**
