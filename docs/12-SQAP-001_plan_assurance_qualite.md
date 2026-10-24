# SQAP-001 — Plan d'Assurance Qualité du Logiciel

| | |
|---|---|
| **Référence** | SQAP-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §6.5.4.4 à 6.5.4.13 ; Tableau A.9 ; Tableau A.1 #1 à #5 |
| **Niveau** | SIL 2 |

---

## 1. Objet et champ d'application

Ce plan définit les activités d'assurance qualité appliquées au logiciel
« Quiz Game 7 » refondu : organisation, revues, vérification, validation,
gestion de configuration, gestion des anomalies et des modifications.

Il est **spécifique au projet** (§6.5.4.4) et couvre les phases E1 à E8 du plan
de refonte (AN-FON-001 §15).

---

## 2. Politique qualité et référentiel

| Élément | Valeur |
|---|---|
| Référentiel principal | NF EN 50128:2011, SIL 2 |
| Système qualité | **Non certifié ISO 9001** — non-conformité **C-02** (MATRICE-CONFORMITE) |
| Politique appliquée | Cycle en V, séparation des rôles, traçabilité intégrale, automatisation maximale des contrôles |
| Principe directeur | Un contrôle qui peut être automatisé **doit** l'être ; ce qui ne peut pas l'être est documenté comme revue humaine |

Tableau A.9 : #2 (conformité ISO 9001, M) **non satisfait** ; #4 (système
qualité de l'entreprise, M) satisfait par le présent plan ; #5 (gestion de
configuration, M) satisfait par PLAN-CONF-001 ; #6 (listes de contrôle, **HR**)
satisfait §6 ; #7 (traçabilité, **HR**) satisfait par TRACE-001 ; #8
(enregistrement et analyse, **HR**) satisfait §7.

---

## 3. Organisation, rôles et indépendance (§5.1.2.11)

### 3.1 Rôles requis à SIL 2

| Rôle | Responsabilité principale | Indépendance exigée |
|---|---|---|
| Chef de projet (PM) | Planification, ressources, arbitrages | — |
| Gestionnaire des exigences (REQ) | SRS-001, traçabilité amont | — |
| Concepteur (DES) | ARCH-001, DD-001 | — |
| Réalisateur (IMP) | Code source, tests unitaires de développement | — |
| Chargé d'intégration (INT) | Intégration, TC-INT | Peut être Testeur |
| Chargé des tests (TST) | SPEC-TESTS-001, exécution, RAP-TESTS | **≠ REQ, DES, IMP du même composant** |
| Chargé de vérification (VER) | RAP-VER-001 | **≠ REQ, DES, IMP, INT, TST** |
| Chargé de validation (VAL) | RAP-VAL-001, accord sur version | **≠ REQ, DES, IMP, INT, TST** |
| Chargé d'évaluation (EVA) | Évaluation indépendante | **Indépendant de l'organisation projet** |

### 3.2 Affectation actuelle — écart déclaré

| Rôle | Titulaire | Situation |
|---|---|---|
| PM, REQ, DES, IMP, TST, VER | **rôle unique** (production de ce dossier) | **Écart §5.1.2.11 h) — C-05** |
| VAL | non nommé | **C-03** |
| EVA | non nommé | **C-11** |

**Conséquence assumée** : ce dossier est une **production technique complète**
qui ne peut pas être déclarée conforme à SIL 2 tant que les rôles VER et VAL ne
sont pas tenus par des personnes distinctes. Les documents sont écrits pour
être **revus** : chaque section de vérification est une liste de contrôle
exploitable par un tiers.

### 3.3 Regroupements autorisés (§5.1.2.11 a, d, j)

* REQ + DES + IMP peuvent être la même personne → **appliqué** ;
* INT + TST peuvent être la même personne → applicable ;
* VER + VAL peuvent être la même personne → applicable **à condition** qu'elle
  soit distincte de REQ/DES/IMP/INT/TST.

---

## 4. Activités qualité par phase

| Phase | Activité qualité | Enregistrement | Réf. |
|---|---|---|---|
| E1 | Revue de la baseline, inventaire des assets | PLAN-CONF-001 §3 | A.1 #3 |
| **E2** | Revue des exigences (complétude, ambiguïté, testabilité) | RAP-VER-001 §2 | §7.2.4.4 |
| **E3** | Revue d'architecture (allocation, interfaces, défense) | RAP-VER-001 §3 | §7.3.4.12 |
| **E4-E6** | Revue de code par échantillonnage + analyse statique | RAP-VER-001 §4 | A.19 #6 |
| **E7** | Exécution des tests, mesure de couverture | RAP-TESTS-001 | A.21 |
| **E8** | Revue de livraison, fiche de livraison | PLAN-CONF-001 §7 | A.1 #27 |

### 4.1 Listes de contrôle (Tableau A.9 #6, HR)

| Liste | Objet | Utilisée par |
|---|---|---|
| LC-01 | Revue d'exigence (10 critères) | RAP-VER-001 §2 |
| LC-02 | Revue d'architecture (7 critères) | RAP-VER-001 §3 |
| LC-03 | Revue de code Dart (12 critères : RAP-VER-001 §4.1) | RAP-VER-001 §4 |
| LC-04 | Revue de données d'application (8 critères) | APP-DATA-001 §3 |
| LC-05 | Revue de livraison (6 critères) | PLAN-CONF-001 §7 |

---

## 5. Vérification et validation

| Aspect | Vérification | Validation |
|---|---|---|
| Question posée | « a-t-on construit correctement ? » | « a-t-on construit le bon produit ? » |
| Référence | SRS-001, ARCH-001, DD-001 | besoin utilisateur, usage réel |
| Responsable | VER | VAL |
| Document | RAP-VER-001 | RAP-VAL-001 |
| Environnement | CI + revue | appareil réel, utilisateurs |
| Statut | 🟡 auto-vérification | ⛔ non réalisée |

---

## 6. Gestion des anomalies

### 6.1 Classification

| Classe | Définition | Délai de traitement |
|---|---|---|
| **B — Bloquante** | Empêche la conformité ou l'usage (perte de données, crash, exigence C1 non satisfaite) | Avant toute livraison ; aucun contournement admis |
| **M — Majeure** | Écart fonctionnel ou de robustesse sans perte de données | Avant livraison ou dérogation écrite du VAL |
| **m — Mineure** | Confort, style, documentation | Prochaine version |

### 6.2 Cycle de vie d'une anomalie

```
Détection ──► Enregistrement (ID, gravité, preuve) ──► Analyse (cause racine)
   ──► Correction ──► Test de non-régression ──► Vérification ──► Clôture
```

Toute anomalie **doit** être tracée dans TRACE-001 §4 avec sa preuve de
correction. Aucune anomalie ne peut être clôturée par la seule décision du
Réalisateur (séparation des rôles).

### 6.3 État actuel

23 anomalies de la v7 : **21 corrigées**, 2 partiellement (ANO-21 signature,
ANO-22 plateforme). 13 non-conformités normatives ouvertes (C-01 à C-13),
dont 4 bloquantes (C-03, C-04, C-05, et C-10 pour le build).

---

## 7. Enregistrements qualité (§6.5.4.12)

| Enregistrement | Support | Conservation |
|---|---|---|
| Documents du dossier | `docs/` versionné | Durée de vie du produit |
| Code source | dépôt Git, tags de version | Idem |
| Résultats d'analyse statique | artefact CI | 1 an ou 3 versions |
| Résultats de tests + couverture | artefact CI | Idem |
| Validations de contenu | fiches signées | Idem |
| Registre des modifications | PLAN-CONF-001 §6 | Idem |
| Ce plan et ses révisions | `docs/` | Idem |

---

## 8. Actions ouvertes

| ID | Action | Responsable | Échéance | Critère de clôture |
|---|---|---|---|---|
| **A-01** | Nommer VER et VAL indépendants | PM | E7 | Noms inscrits §3.2 |
| **A-02** | Exécuter la CI et compléter RAP-TESTS-001 | TST | E7 | 106 cas verts, couverture aux seuils |
| **A-03** | Compléter les citations `REQ-*` dans le code (17 exigences) | IMP | E7 | `grep` → 58 |
| **A-04** | Générer et versionner `android/` (C-10) | IMP | E7 | Build APK reproductible |
| **A-05** | Revue pédagogique du contenu (C-07) | expert désigné | E8 | Fiches de relecture signées |
| **A-06** | Fournir un keystore de release (C-08) | PM | E8 | APK signé |
| **A-07** | Rédiger plan de livraison et manuel de déploiement (C-09) | PM | E8 | Documents #36-#40 |
| **A-08** | Exécuter la validation sur appareil (RAP-VAL-001 §4) | VAL | E8 | 10 scénarios verts |
| **A-09** | Désigner un Chargé d'évaluation (C-11) | PM | E8 | Nom inscrit |
| **A-10** | Mesurer l'accessibilité (C-12) | TST | E8 | TC-SYS-18/19 verts |

---

## 9. Indicateurs

| Indicateur | Cible | Mesure actuelle |
|---|---|---|
| Exigences tracées | 100 % | 100 % (58/58) |
| Exigences C1 couvertes par un test | 100 % | 100 % (spécifié) |
| Tests exécutés / spécifiés | 100 % | 0 % (C-04) |
| Couverture instructions `domain` | 100 % | non mesurée |
| Fichiers > 200 lignes | 0 | 0 |
| Anomalies B ouvertes | 0 | 4 (C-03, C-04, C-05, C-10) |
| Documents du Tableau A.1 produits | 100 % | 62 % (voir INDEX) |

---

## 10. Révision du plan

| Version | Date | Motif | Auteur |
|---|---|---|---|
| 1.0 | 24/10/2026 | Création | rôle unique (voir §3.2) |

**Fin du document — SQAP-001 v1.0**
