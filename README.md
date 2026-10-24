# Quiz Game — refonte méthodologique NF EN 50128:2011 (SIL 2)

Refonte complète de l'application Flutter « Quiz Game 7 » : analyse
fonctionnelle, exigences, architecture, conception détaillée, code, tests,
dossier d'assurance qualité et dossier de conformité.

> ⚠️ **Réserve d'applicabilité.** La NF EN 50128:2011 vise les logiciels de
> commande et de protection ferroviaires participant à des fonctions de
> sécurité. Un quiz n'exerce **aucune** fonction de sécurité : la norme est
> appliquée ici **volontairement, comme référentiel méthodologique**, avec un
> niveau **SIL 2** retenu par décision de projet (D-001, `docs/01-AN-FON-001`
> §1.3). Aucune allégation de certification n'est faite.
>
> ⚠️ **Réserve de preuve.** Dans l'environnement de rédaction, le SDK Flutter
> n'était pas disponible : **aucun test n'a été exécuté** et **aucune couverture
> n'a été mesurée**. Les documents de test et de validation le déclarent
> explicitement. Voir `docs/09-MATRICE-CONFORMITE.md` §8.

---

## 1. Ce que contient le dépôt

| Chemin | Contenu |
|---|---|
| `docs/` | **Dossier documentaire complet** (16 documents numérotés + sommaire) — commencer par `docs/README.md` |
| `lib/` | Code applicatif : 48 fichiers, 3 037 lignes, 4 couches (domaine, application, infrastructure, présentation) |
| `test/` | 144 cas de test automatisés, dont 9 contrôles d'architecture |
| `assets/` | Contenu pédagogique : 8 thèmes, 40 questions, 3 fonds animés |
| `tool/` | `validate_content.py` (contrôle du contenu), `check_coverage.py` (seuils de couverture) |
| `.github/workflows/ci.yml` | Chaîne d'intégration continue bloquante (6 étapes) |
| `legacy/baseline_v7/` | Code d'origine, conservé **à titre de preuve** des anomalies ANO-01..23 ; non compilé, exclu de l'analyse |

---

## 2. Démarche (cycle de vie EN 50128)

| Étape | Livrables | Document |
|---|---|---|
| Analyse des exigences du logiciel | 20 fonctions élémentaires, 23 anomalies du code d'origine | `01-AN-FON-001` |
| Spécification des exigences | 58 exigences, 10 interfaces | `02-SRS-001` |
| Architecture | 45 composants, 4 couches, ADR | `03-ARCH-001` |
| Conception détaillée | invariants, algorithmes, cas limites | `04-DD-001` |
| Codage | norme RC-01..RC-20, code livré | `16-STD-COD-001`, `lib/` |
| Vérification | listes de contrôle, observations V-01..V-08 | `07-RAP-VER-001` |
| Tests | 114 cas spécifiés, 144 automatisés | `05-SPEC-TESTS-001`, `06-RAP-TESTS-001` |
| Intégration / ensemble | scénarios sur appareil | `05` §6, `08-RAP-VAL-001` |
| Validation | 10 scénarios VAL-01..10 | `08-RAP-VAL-001` |
| Assurance qualité | SQAP, rôles, actions A-01..A-10 | `12-SQAP-001` |
| Gestion de configuration | EC, baselines BL-0..BL-4 | `13-PLAN-CONF-001` |
| Outils, maintenance | classification T1/T2/T3, procédure de correction | `14-OUTILS-001`, `15-MAINT-001` |
| Conformité | 86 exigences normatives, écarts C-01..C-13 | `09-MATRICE-CONFORMITE` |

---

## 3. Architecture en un coup d'œil

```
presentation/   écrans, widgets, chaînes     ──► application/ (cas d'usage)
application/    6 cas d'usage + 5 ports      ──► domain/ (règles pures)
infrastructure/ contenu, état, temps, aléa   ──► implémente les ports
domain/         entités, valeurs, règles     ──► aucune dépendance externe
```

Règles tenues par les tests (`test/architecture_test.dart`) :

- `domain/` n'importe ni Flutter, ni plugin, ni `dart:io`, ni `dart:math` ;
- `application/` n'importe ni Flutter ni l'infrastructure ;
- `presentation/` ne connaît l'infrastructure que dans `app_dependencies.dart` ;
- aucun fichier > 200 lignes, aucun `print`, aucun état global mutable,
  aucun `assert` de validation d'entrée, un seul point d'entrée.

---

## 4. Choix techniques structurants

| Sujet | Choix | Motif |
|---|---|---|
| Chronomètre | **échéance absolue** (`deadline`) et non décrément par ticks | un passage en arrière-plan ne rend pas de temps ; testable sans attente |
| Persistance | enveloppe `{v, crc, data}` + CRC-32 | détection de corruption, repli sûr sur état par défaut |
| Temps, aléa, stockage | injectés par ports | déterminisme des tests, absence d'effet de bord |
| Contenu | assets versionnés validés par script | REQ-004 : un contenu incomplet casse la CI, pas l'utilisateur |
| Fin de session | transaction unique (score + déverrouillage + écriture) | jamais de score sans progression ni l'inverse |
| Erreurs | hiérarchie scellée `AppError`, codes stables | messages traduits, jamais de fuite technique |

---

## 5. Exécuter

```bash
flutter pub get
flutter analyze --fatal-infos --fatal-warnings
dart format --output=none --set-exit-if-changed lib test
flutter test --coverage
python3 tool/check_coverage.py coverage/lcov.info
python3 tool/validate_content.py --baseline docs/content_baseline.json
flutter build apk --release          # nécessite android/ (point ouvert C-10)
```

La même séquence est exécutée par `.github/workflows/ci.yml` à chaque envoi ;
toute étape en échec bloque la fusion.

---

## 6. État réel, sans embellissement

| Élément | État |
|---|---|
| Analyse fonctionnelle | ✅ livrée et stable |
| Dossier documentaire | ✅ complet (16 documents) |
| Code | ✅ écrit, non compilé dans l'environnement de rédaction |
| Tests | ✅ 144 cas écrits — ⛔ **0 exécuté** |
| Couverture | ⛔ **non mesurée** |
| Validation | ⛔ **non effectuée** (10 scénarios prêts) |
| Projet Android | ⛔ **absent** (`flutter build` impossible en l'état) |
| Indépendance VER / VAL | ⛔ **non assurée** (une seule personne) |

**Conclusion** : dossier complet, **conformité non démontrée**. Les actions
prioritaires du plan d'assurance qualité (A-01 à A-04 : désignation des rôles
indépendants, exécution de la CI, complément des citations d'exigences,
génération du projet Android) sont décrites dans `docs/12-SQAP-001` §9 avec
leurs critères de clôture.
