# APP-DATA-001 — Plan de Préparation des Données d'Application

| | |
|---|---|
| **Référence** | APP-DATA-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §8.4.1 à §8.4.8 ; Tableau A.11 ; Tableau A.1 #28 à #35 |
| **Niveau** | SIL 2 |
| **Objet** | Traiter le **contenu des quiz** comme une donnée d'application soumise à un processus qualité, et non comme une simple ressource |
| **Portée** | `assets/questions/**` (8 thèmes, 2 niveaux, 40 questions de démonstration) |

---

## 1. Pourquoi ce document

La v7 livrait son contenu sans aucun contrôle : un JSON mal formé faisait échouer
le chargement à l'exécution, un niveau déclaré sans fichier provoquait une erreur
au lancement, et deux entrées d'assets étaient dupliquées dans `pubspec.yaml`
(ANO-17, ANO-19).

La norme impose, pour un logiciel **générique configuré par des données**
(§8.4.8), un processus distinct : exigences de l'application, vérification,
validation, tests, traçabilité. Ce document l'établit.

---

## 2. Séparation logiciel générique / données (§8.4.8.4)

| Règle | Mise en œuvre |
|---|---|
| Aucun contenu en dur dans le code | Les questions ne figurent que dans `assets/questions/` ; `lib/` ne contient que la liste des 8 identifiants de thèmes (`quiz_theme.dart`), qui est une donnée de référence stable |
| Le logiciel détecte les données invalides (§8.4.8.7) | 3 niveaux : validation CI (`tool/validate_content.py`), validation à la lecture (`AssetQuestionRepository`), invariants du domaine (`Question`, `LevelCatalog`) |
| Une donnée invalide n'empêche pas l'usage des autres thèmes | Le chargement est paresseux et cloisonné par thème : un thème en erreur affiche un message, les autres restent jouables |
| Modification de données sans modification de code | Le contenu est versionné indépendamment (PLAN-CONF-001 §5) |

---

## 3. Spécification des exigences de l'application (§8.4.2)

| ID | Exigence | Vérification |
|---|---|---|
| **APP-01** | Le catalogue d'un thème liste au moins le niveau 1, au plus 99 niveaux, sans doublon, en entiers ≥ 1. | validateur + TC-INF-06 |
| **APP-02** | Chaque niveau listé possède un fichier `level_<n>.json` non vide (≤ 200 questions). | validateur (bloquant) |
| **APP-03** | Chaque question comporte un énoncé (≤ 500 caractères), une bonne réponse, et entre 2 et 10 options non vides, sans doublon, la bonne réponse y figurant exactement. | validateur + TC-DOM-05..09 |
| **APP-04** | Une question n'apparaît qu'une fois par niveau (énoncé identique interdit). | validateur (avertissement bloquant en revue) |
| **APP-05** | Le contenu est exact d'un point de vue pédagogique et religieux. | revue humaine (§5) |
| **APP-06** | Le contenu est en français, sans caractère de contrôle, encodé UTF-8. | validateur |
| **APP-07** | Aucun niveau ne perd de questions entre deux versions (non-régression). | `--baseline` du validateur |
| **APP-08** | Aucune donnée personnelle, aucun élément identifiant dans le contenu. | revue |

---

## 4. Vérification automatisée (§8.4.1.6)

### 4.1 Outil

`tool/validate_content.py` — Python 3, sans dépendance, exécutable **sans SDK
Dart** : il peut tourner avant tout build.

| Contrôle | Code de sortie |
|---|---|
| Structure du catalogue | 1 si erreur |
| Existence du fichier de chaque niveau déclaré | 1 si erreur |
| Schéma et invariants de chaque question | 1 si erreur |
| Fichiers orphelins (niveau non déclaré) | avertissement |
| Énoncés en double | avertissement |
| Régression de volume vs `docs/content_baseline.json` | 1 si erreur |

### 4.2 Résultat de l'exécution

```
Thèmes vérifiés : 8 — questions : 40
Validation du contenu : CONFORME
```

Test de robustesse de l'outil (injection de 3 défauts) : option dupliquée, bonne
réponse absente, fichier de niveau manquant → **3 erreurs détectées**, sortie 1.

### 4.3 Intégration continue

Le validateur est la **première étape** de `.github/workflows/ci.yml` : aucun
test, aucune analyse, aucun build n'est lancé si le contenu est invalide.

---

## 5. Validation du contenu (§8.4.3) — revue humaine obligatoire

> ⚠️ **Non réalisée.** Les 40 questions livrées sont un **contenu de
> démonstration**, rédigé pour rendre l'application exécutable et testable. Leur
> exactitude n'a pas été vérifiée par une autorité compétente (C-07).

Procédure exigée avant diffusion :

| Étape | Acteur | Enregistrement |
|---|---|---|
| 1. Relecture thématique (arabe, sira, coran, histoire, sahaba, hijra, termes) | relecteur compétent par domaine | fiche de relecture signée par thème |
| 2. Vérification des sources (références coraniques, dates) | relecteur | tableau `question → source` |
| 3. Contrôle de niveau (adapté à l'âge) | responsable pédagogique | avis signé |
| 4. Validation | Chargé de validation | visa sur la Fiche de livraison |

Le Tableau A.11 exige à SIL 2 la combinaison **1 (spécification en tableaux) +
4 (tests fonctionnels)** : la spécification est le §3 ci-dessus, les tests sont
les contrôles §4. Les techniques #5 (listes de contrôle, « M » à SIL 2) et #7
(examens formels de la conception, **HR**) sont satisfaites par la procédure §5
et par la fiche de relecture.

---

## 6. Tests d'application (§8.4.1.6, Tableau A.1 #30, #33)

| ID | Objet | Méthode | Résultat |
|---|---|---|---|
| **TC-APP-DATA-01** | Les 8 thèmes se chargent | exécution du validateur | conforme |
| **TC-APP-DATA-02** | Chaque question est jouable | widget test avec le contenu réel | partiel (contenu de test synthétique) |
| **TC-APP-DATA-03** | Un contenu invalide est refusé | injection de 3 défauts | conforme |
| **TC-APP-DATA-04** | Non-régression de volume | `--baseline` | conforme |
| **TC-APP-DATA-05** | Un thème en erreur n'empêche pas les autres | scénario TC-SYS-12 | à exécuter sur appareil |

---

## 7. Analyse du risque du processus de préparation (§8.4.1.8)

| Risque | Gravité | Parade |
|---|---|---|
| Question fausse diffusée | **Élevée** | Revue humaine §5 (obligatoire, non faite) |
| JSON invalide livré | Moyenne | Validateur bloquant en CI |
| Niveau déclaré sans fichier | Moyenne | Validateur bloquant |
| Régression de contenu (perte de questions) | Moyenne | Comparaison à une référence de volume |
| Contenu dupliqué entre deux niveaux | Faible | Avertissement + revue |
| Caractères corrompus (encodage) | Faible | Contrôle UTF-8 |
| Taille excessive (mémoire) | Faible | Bornes 200 questions × 10 options |

---

## 8. Traçabilité des données (§8.4.1.13)

| Élément | Emplacement |
|---|---|
| Contenu livré | `assets/questions/<theme>/levels.json`, `level_<n>.json` |
| Référence de volume | `docs/content_baseline.json` |
| Exigences de l'application | ce document §3 |
| Outil de vérification | `tool/validate_content.py` |
| Rapport de vérification | ce document §4 |
| Rapport de tests | RAP-TESTS-001 §3 |
| Enregistrement de revue | fiches de relecture (à produire, §5) |

---

## 9. Livrables du Tableau A.1 couverts

| # | Document | Statut |
|---|---|---|
| 28 | Spécification des Exigences de l'Application | ✅ §3 |
| 29 | Plan de Préparation de l'Application | ✅ ce document |
| 30 | Spécification de Tests de l'Application | ✅ §6 |
| 31 | Architecture et Conception de l'Application | ✅ §2 (séparation) |
| 32 | Rapport de Vérification de la Préparation | 🟡 §4 (automatique) ; revue humaine §5 manquante |
| 33 | Rapport de Tests d'Application | 🟡 §6 |
| 34 | Code source des données | ✅ `assets/` |
| 35 | Rapport de vérification des données | 🟡 §4 |

**Fin du document — APP-DATA-001 v1.0**
