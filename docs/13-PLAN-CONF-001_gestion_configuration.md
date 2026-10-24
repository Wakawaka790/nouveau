# PLAN-CONF-001 — Plan de Gestion de la Configuration du Logiciel

| | |
|---|---|
| **Référence** | PLAN-CONF-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §6.5.4.7 à 6.5.4.11 ; Tableau A.1 #3, #27, #38, #39 ; Tableau A.9 #5 |
| **Niveau** | SIL 2 |

---

## 1. Objet

Identifier, contrôler et tracer **tous les éléments** du logiciel et de sa
documentation, depuis la baseline de la v7 jusqu'aux livrables, conformément au
§6.5.4.7 (identification, contrôle, enregistrement des états, audits).

---

## 2. Éléments de configuration (CI)

| Classe | Éléments | Nommage | Propriétaire |
|---|---|---|---|
| **EC-1 Sources** | `lib/**/*.dart` (34 fichiers), `test/**/*.dart` (13) | chemin dans l'arborescence | IMP |
| **EC-2 Données d'application** | `assets/questions/**` (24 fichiers JSON), `assets/backgrounds/**` (3) | `<theme>/level_<n>.json` | REQ + expert contenu |
| **EC-3 Configuration de build** | `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `android/**`, `.github/workflows/ci.yml` | — | IMP |
| **EC-4 Outils** | `tool/validate_content.py`, `tool/check_coverage.py` | — | IMP |
| **EC-5 Documentation** | `docs/**` (16 documents + sommaire `README.md` + PDF de référence) | `NN-REF-version_titre.md` | selon document |
| **EC-6 Baseline historique** | `legacy/baseline_v7/**` (39 fichiers) | **figée, immuable** | archiviste |

### 2.1 Règle sur `legacy/`

`legacy/baseline_v7/` est **en lecture seule**. Toute modification y est
interdite : il constitue la preuve de l'état initial (§6.5.4.10). Une évolution
se fait dans `lib/`.

---

## 3. Baseline de référence

| Baseline | Contenu | Identifiant | Date |
|---|---|---|---|
| **BL-0** | Code v7 extrait du PDF (39 fichiers, 1 610 lignes Dart) | `legacy/baseline_v7` | 17/10/2026 |
| **BL-1** | Analyse fonctionnelle validée | AN-FON-001 v1.1 | 24/10/2026 |
| **BL-2** | Spécifications (SRS, architecture, conception, tests) | SRS/ARCH/DD/SPEC-TESTS v1.0 | 24/10/2026 |
| **BL-3** | Code refondu + tests | `lib/`, `test/` v2.0.0 | 24/10/2026 |
| **BL-4** | Livraison | APK + fiche de livraison | à produire |

**Version applicative** : `2.0.0+20` (`pubspec.yaml`), majeure 2 pour rupture
d'architecture, mineure 0 pour première livraison de la refonte.

---

## 4. Identification et versionnement

| Règle | Application |
|---|---|
| Tout élément porte un identifiant unique | Chemins d'arborescence + identifiants documentaires (`SRS-001`, `REQ-021`, `TC-DOM-07`) |
| Une version = un état cohérent | Tag Git `v2.0.0` sur l'ensemble des EC |
| Aucun élément non versionné n'entre dans un build | `.gitignore` exclut les artefacts ; la CI construit depuis l'état commité |
| Les identifiants sont stables | Un `REQ` ne change jamais de numéro ; une exigence retirée reste documentée comme « écartée » (SRS-001 §8) |

**Convention de commit** : `<type>: <objet> [<réf.>]` où `type` ∈ {docs, feat,
fix, test, ci, refactor}. La référence est l'identifiant d'exigence ou
d'anomalie traitée, ce qui rend le registre des modifications extractible de
l'historique Git (`git log --grep`).

---

## 5. Contrôle des modifications

### 5.1 Circuit

```
Demande de modification (DM)
   │  identifiant DM-xxx, justification, éléments concernés
   ▼
Analyse d'impact (exigences, composants, tests, données)
   │  produit par DES + IMP
   ▼
Décision (PM ; VAL si impact sur une exigence de sécurité/qualité)
   │
   ▼
Mise en œuvre (IMP) ──► Tests de non-régression ──► Vérification (VER) ──► Clôture
```

### 5.2 Règles d'impact obligatoire

| Élément modifié | Analyse d'impact minimale |
|---|---|
| `assets/questions/**` | validateur + volume de référence + revue de contenu |
| `lib/domain/**` | tests de composant + TRACE-001 §3 + revue VER |
| `lib/application/**` | TC-APP + TC-INT |
| `lib/infrastructure/**` | TC-INF + test de corruption + test de concurrence |
| `lib/presentation/**` | TC-PRS + TC-SYS |
| `pubspec.yaml` (dépendance) | OUTILS-001 + REQ-079 (reproductibilité) |
| Document de spécification | révision de version + mise à jour de TRACE-001 |

### 5.3 Contenu de données : versionnement indépendant

Le contenu peut évoluer sans changer le code. Il porte donc sa propre référence
de volume (`docs/content_baseline.json`), comparée à chaque CI : une baisse du
nombre de questions est un **échec de build**.

---

## 6. Registre des modifications

| ID | Date | Objet | Éléments | Analyse d'impact | Vérif. |
|---|---|---|---|---|---|
| DM-001 | 24/10/2026 | Refonte complète SIL 2 | tous | AN-FON-001 → nouveau dossier | RAP-VER-001 |
| DM-002 | 24/10/2026 | Suppression de la dépendance `audioplayers` (ANO-18) | `pubspec.yaml` | aucun code ne l'utilisait | RAP-VER-001 §4.3 |
| DM-003 | 24/10/2026 | Remplacement des deux clés de persistance par un document unique (ANO-06/07) | INF-02/04 | TC-INF-10..20, TC-APP-01 | RAP-TESTS-001 |
| DM-004 | 24/10/2026 | Passage du décrément de timer à l'échéance absolue (ANO-10/11) | DOM-05 | TC-DOM-21..26 | RAP-TESTS-001 |
| DM-005 | 24/10/2026 | Introduction du validateur de contenu (ANO-17/19) | `tool/` | CI bloquante | APP-DATA-001 §4 |
| DM-006 | 24/10/2026 | Introduction de la séparation des rôles documentée (C-05) | SQAP-001 | aucune (documentaire) | revue |

---

## 7. Livraison (§6.5, Tableau A.1 #27, #38)

Une livraison comprend :

| Élément | Contenu |
|---|---|
| Fiche de livraison | version, date, empreinte du commit, liste des EC livrés, réserves |
| Binaire | `app-release.apk` (signé — **C-08 ouvert**) |
| Documentation | ce dossier (16 documents numérotés + sommaire) |
| Enregistrement | procès-verbal de remise, accusé de réception |

**Empreinte** : `sha256sum` de l'APK, consigné dans la fiche et dans
l'artefact CI (traçabilité binaire ↔ source).

---

## 8. Audits de configuration

| Audit | Fréquence | Contenu | Preuve |
|---|---|---|---|
| Configuration | avant chaque livraison | tous les EC présents, versionnés, cohérents | fiche de livraison |
| Fonctionnel | avant chaque livraison | le binaire correspond à la baseline documentée | `git describe` + empreinte APK |
| Reproductibilité | chaque CI | `pubspec.yaml` inchangé après `pub get` | étape CI dédiée (REQ-079) |

---

## 9. Sauvegarde et pérennité

| Risque | Mesure |
|---|---|
| Perte du dépôt | miroir distant + baseline `legacy/` figée dans le dépôt |
| Perte de la référence normative | `docs/REF-NF-EN-50128-2011.pdf` versionné |
| Divergence contenu/code | comparaison automatique de volume à chaque CI |

**Fin du document — PLAN-CONF-001 v1.0**
