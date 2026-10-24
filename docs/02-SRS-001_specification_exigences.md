# SRS-001 — Spécification des Exigences du Logiciel

| | |
|---|---|
| **Référence** | SRS-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Statut** | Soumis à revue (rôle : Gestionnaire des exigences) |
| **Référentiel** | NF EN 50128:2011, §7.2.4 ; Tableau A.2 ; Tableau A.1 items 6, 7, 8 |
| **Niveau d'intégrité** | **SIL 2** (décision de projet, cf. §3) |
| **Documents d'entrée** | AN-FON-001 v1.1 (analyse fonctionnelle) ; décision de projet D-001 (SIL 2) ; `legacy/baseline_v7` |
| **Documents de sortie associés** | SPEC-TESTS-ENS-001 (§7.2.4.16), RAP-VER-001 §2 (#8) |
| **Traçabilité amont** | AN-FON-001 §5 (EF-01..20, RG-01..12, ENF-01..12), §11 (ANO-01..23) |
| **Traçabilité aval** | ARCH-001, DD-001, SPEC-TESTS-001, RAP-TESTS-001 |

---

## 1. Objet et périmètre

### 1.1 Objet

Ce document spécifie **les propriétés requises du logiciel** à développer, au
sens du §7.2.4.2 de la NF EN 50128 : fonctionnalité, robustesse,
maintenabilité, efficacité, utilisabilité, portabilité, sécurité.

Il constitue le document d'entrée unique de la conception (ARCH-001, DD-001) et
des tests (SPEC-TESTS-ENS-001, SPEC-TESTS-001). **Aucune exigence n'est ajoutée
par la conception** : toute exigence nouvelle découverte en aval fait l'objet
d'une demande de modification (SQAP-001 §10) et d'une révision de ce document.

### 1.2 Périmètre

**Inclus** : application mobile Flutter « Quiz Game 7 » refondue — chargement du
contenu, catalogue de niveaux, progression, session de quiz chronométrée,
calcul du score, persistance locale, présentation, gestion des erreurs.

**Exclu** : le **contenu pédagogique** (JSON de questions, images, sons), traité
comme donnée d'application au titre du §8.4 — voir APP-DATA-001. Les exigences
portant sur le *traitement* de ce contenu sont, elles, dans le présent document.

**Exclu** : les composants tiers (Flutter SDK, `shared_preferences`), dont la
validation relève du fournisseur ; ils font l'objet d'une analyse d'impact dans
OUTILS-001.

### 1.3 Vocabulaire normatif

Conformément à la NF EN 50128 (§3.2) et à l'ISO/CEI 29148 :

| Terme | Signification |
|---|---|
| **doit** | Exigence obligatoire ; la non-satisfaction est une non-conformité |
| **ne doit pas** | Interdiction |
| **devrait** | Recommandation ; l'écart doit être justifié |
| **peut** | Facultatif |

Chaque exigence porte : un identifiant **stable**, une **méthode de vérification**
(T = test, A = analyse, R = revue, D = démonstration) et une **criticité**
(1 = cœur métier, 2 = support, 3 = présentation).

---

## 2. Contexte du logiciel et interfaces

### 2.1 Contexte

Application Android **hors ligne**, mono-utilisateur, sans authentification,
sans donnée personnelle, sans accès réseau. Le logiciel est **générique** au
sens du §8.4.8 : son comportement est configuré par les données d'application
(catalogue et questions).

### 2.2 Interfaces

Les interfaces reprennent les identifiants IF-01 à IF-10 d'AN-FON-001 §9 ; leurs
spécifications détaillées (préconditions, postconditions, valeurs limites,
comportement hors limites) sont en **ARCH-001 §6** (exigence §7.3.4.18-19).

| ID | Interface | Nature | Exigences applicables |
|---|---|---|---|
| IF-01..04 | Tactile (thèmes, niveaux, options, dialogues) | Humain → logiciel | REQ-061..065 |
| IF-05 | Assets (`rootBundle`) | Logiciel → données d'application | REQ-001..008 |
| IF-06 | Stockage local (`shared_preferences`) | Logiciel ↔ persistance | REQ-030..033 |
| IF-07 | Horloge système | Système → logiciel | REQ-034, REQ-037 |
| IF-08 | Cycle de vie Android | Système → logiciel | REQ-037 |
| IF-09 | Mémoire / images | Système → logiciel | REQ-060, REQ-072 |
| IF-10 | Accessibilité (lecteur d'écran) | Logiciel → système | REQ-067 |

---

## 3. Allocation du niveau d'intégrité de sécurité

### 3.1 Décision

| | |
|---|---|
| **Niveau retenu** | **SIL 2** |
| **Référence de décision** | D-001 (décision de projet, 24/10/2026) |
| **Périmètre d'application** | L'ensemble du logiciel applicatif (`lib/`) |
| **Justification** | Volonté du maître d'ouvrage d'appliquer un référentiel exigeant et réutilisable ; le logiciel ne participe à aucune fonction de sécurité ferroviaire |

### 3.2 Réserve de traçabilité (obligatoire)

Conformément au §4.1 de la norme, l'allocation d'un SIL découle normalement
d'une **analyse de risques système** (EN 50126-1) et d'une allocation
système → matériel/logiciel documentée. Cette analyse **n'existe pas** pour ce
produit et n'entre pas dans le périmètre du présent dossier.

En conséquence :

* le SIL 2 est une **hypothèse de projet déclarée**, pas un niveau dérivé ;
* le dossier démontre la **conformité aux exigences SIL 2 de l'EN 50128** pour
  les processus, techniques et mesures applicables ;
* **il ne démontre pas** que le SIL 2 est le niveau approprié au produit ; cette
  démonstration relève de l'EN 50126-1 et n'est pas revendiquée ;
* toutes les exigences **SIL 0, SIL 1 et SIL 2** sont appliquées lorsqu'elles
  sont cumulatives (ex. : « HR » à SIL 2 vaut aussi pour les niveaux inférieurs).

### 3.3 Conséquences sur les exigences

| Domaine | Exigence induite par SIL 2 | Référence |
|---|---|---|
| Indépendance V&V | Le Chargé de vérification et le Chargé de validation ne doivent être ni Gestionnaire des exigences, ni Concepteur, ni Réalisateur, ni Chargé d'intégration, ni Chargé des tests | §5.1.2.11 h) |
| Indépendance tests | Le Chargé des tests ne doit être ni Gestionnaire des exigences, ni Concepteur, ni Réalisateur du composant testé | §5.1.2.11 f), g) |
| Techniques | Programmation défensive, interface entièrement définie, méthodologie structurée (HR) ; encapsulation (HR) ; codes de détection d'erreurs (R) | Tableaux A.3, A.4 |
| Couverture | Couverture des instructions mesurée et exigée (HR) ; branchement, conditions composées, flux de données, chemin (R) | Tableau A.21 |
| Analyse statique | Flux de contrôle et flux de données (HR), revues de conception (HR) | Tableau A.19 |
| Données d'application | Spécification en tableaux + tests fonctionnels (combinaison approuvée) et simulation (HR) | Tableau A.11 |
| Rôles | Séparation effective à démontrer par nommage | SQAP-001 §4 |

> **Point de vigilance majeur** : la séparation des rôles (§5.1.2.11 h) est une
> exigence **organisationnelle** que le code ne peut pas satisfaire. Elle est
> identifiée comme **NON SATISFAITE** dans MATRICE-CONFORMITE (ligne C-05) tant
> qu'un Chargé de vérification distinct n'est pas nommé. Le présent dossier est
> produit par un rôle unique (Concepteur/Réalisateur) et constitue donc, en
> l'état, un dossier **techniquement complet mais organisationnellement
> incomplet**.

---

## 4. Exigences fonctionnelles

### 4.1 Chargement et validation du contenu

| ID | Exigence | Vérif. | Crit. | Source |
|---|---|---|---|---|
| **REQ-001** | Le logiciel **doit** charger le catalogue d'un thème depuis l'asset `assets/questions/<theme>/levels.json`. L'identifiant `<theme>` est normalisé (REQ-006) avant construction du chemin ; **aucune** concaténation de chaîne non validée ne doit atteindre le chargeur d'assets. | T | 1 | EF-07, ANO-02 |
| **REQ-002** | Le catalogue **doit** accepter la clé `Levels` ou `levels`. Il **doit** être un objet JSON dont cette clé est une liste. Tout autre type est une erreur `ContentSchemaError`. | T | 1 | RG-11 |
| **REQ-003** | Chaque élément du catalogue **doit** être un entier ≥ 1 (ou une chaîne décimale convertible). Les doublons **doivent** être refusés. Après tri croissant, le premier élément **doit** être 1. Le nombre d'éléments **doit** être ≤ 99. | T | 1 | RG-11, ENF-12 |
| **REQ-004** | Le logiciel **doit** charger les questions d'un niveau depuis `assets/questions/<theme>/level_<n>.json`, où `n` est un entier ≥ 1. Le fichier **doit** contenir une liste non vide d'objets. | T | 1 | EF-07, RG-12 |
| **REQ-005** | Chaque question **doit** satisfaire : énoncé non vide après `trim` ; bonne réponse non vide après `trim` ; au moins 2 options ; aucune option vide ; aucune option dupliquée ; la bonne réponse **doit** figurer parmi les options après `trim`. Une seule question invalide **doit** faire échouer le chargement **du niveau entier** avec un message identifiant l'index (base 1) et la cause. | T | 1 | RG-01, EF-08 |
| **REQ-006** | Un identifiant de thème est valide si, après `trim` et passage en minuscules, il correspond à `^[a-z0-9_-]{1,32}$`. Tout autre identifiant **doit** produire `InvalidThemeIdError` **avant** tout accès au stockage ou aux assets. | T | 1 | RG-09 |
| **REQ-007** | L'ordre des options **doit** être aléatoire à chaque chargement, au moyen d'une source d'aléa **injectée**. À graine fixée, l'ordre **doit** être reproductible (déterminisme). La bonne réponse **doit** rester identifiée par sa valeur, jamais par sa position. | T | 2 | EF-09, ANO-04 |
| **REQ-008** | Les erreurs de contenu **doivent** être typées et distinguer : fichier absent (`ContentNotFoundError`), JSON illisible (`ContentParseError`), schéma non conforme (`ContentSchemaError`), niveau vide (`EmptyLevelError`). Chaque erreur **doit** porter le chemin de l'asset concerné. | T | 1 | ANO-14 |

### 4.2 Catalogue et progression

| ID | Exigence | Vérif. | Crit. | Source |
|---|---|---|---|---|
| **REQ-010** | Le niveau 1 **doit** toujours être considéré comme déverrouillé, quel que soit l'état persisté. | T | 1 | RG-02 |
| **REQ-011** | L'ensemble des niveaux déverrouillés d'un thème **doit** être persisté sous forme d'entiers triés, sans doublon, bornés au catalogue. Toute valeur hors bornes **doit** être ignorée à la lecture (et journalisée), jamais propagée. | T | 1 | RG-11, ENF-03 |
| **REQ-012** | À la fin d'un niveau, le logiciel **doit** déverrouiller le **niveau configuré immédiatement supérieur** du catalogue, sans condition de score. Un niveau absent du catalogue **ne doit pas** être déverrouillé. | T | 1 | EF-05, RG-03 |
| **REQ-013** | Le résultat d'un déverrouillage **doit** distinguer explicitement quatre cas : `newlyUnlocked(level)`, `alreadyUnlocked(level)`, `noNextLevel`, `notEligible`. L'IHM **ne doit** annoncer un déverrouillage que dans le cas `newlyUnlocked`. | T | 1 | ANO-09 |
| **REQ-014** | Le déverrouillage **ne doit** s'appliquer que si le niveau terminé est lui-même déverrouillé ; sinon le résultat est `notEligible` et la progression est inchangée. | T | 1 | RG-03 |
| **REQ-015** | Le logiciel **doit** migrer la progression écrite par les versions antérieures sous les clés `levels__<type>` et `levels__<Type>` (capitalisation initiale). La migration **doit** fusionner les valeurs, écrire l'état courant, puis seulement ensuite supprimer l'ancienne clé. Un échec d'écriture **ne doit pas** entraîner de suppression. | T | 1 | EF-20, ANO-06 |
| **REQ-016** | La réinitialisation de la progression d'un thème **doit** ramener l'état à `{1}` en **une seule écriture**, sans passage par un état intermédiaire persisté. | T | 2 | EF-06 |
| **REQ-017** | Le compteur affiché « X / Y niveaux débloqués » **doit** compter l'intersection des niveaux déverrouillés et des niveaux réellement présents dans le catalogue. | T | 3 | EF-04 |

### 4.3 Score

| ID | Exigence | Vérif. | Crit. | Source |
|---|---|---|---|---|
| **REQ-020** | Le score total **doit** être lu depuis l'état persistant ; en l'absence de valeur, il vaut 0. Il **ne doit jamais** être négatif. | T | 1 | EF-02, RG-07 |
| **REQ-021** | Le score d'une session **doit** être égal au nombre de réponses strictement égales à la bonne réponse de la question correspondante. Il **doit** être borné par `min(nb questions, nb réponses)`. Une incohérence de longueur entre les listes **doit** produire une erreur de diagnostic journalisée, et non une troncature silencieuse. | T | 1 | RG-06, ANO-13 |
| **REQ-022** | À la fin d'une session, le score total et la progression **doivent** être enregistrés en **une seule opération d'écriture** (document d'état unique). Aucun état intermédiaire où le score serait enregistré sans la progression (ou l'inverse) ne doit être observable. | T | 1 | ANO-06 |
| **REQ-023** | La remise à zéro du score **doit** écrire 0 en une seule opération et **ne doit pas** modifier la progression. | T | 2 | EF-03 |
| **REQ-024** | Le taux de réussite **doit** être calculé comme `score / nombre de questions`, et valoir 0 si le nombre de questions est nul. | T | 3 | FON-D-12 |

### 4.4 Session de quiz

| ID | Exigence | Vérif. | Crit. | Source |
|---|---|---|---|---|
| **REQ-030** | Une session **doit** être créée à partir d'une liste non vide de questions et d'une durée par question strictement positive (10 s par défaut). Une durée ≤ 0 **doit** être refusée par une exception typée, y compris en mode release (aucune dépendance à `assert`). | T | 1 | ANO-12 |
| **REQ-031** | La session **doit** présenter les questions séquentiellement, une seule à la fois, de l'indice 0 à n-1. L'utilisateur **ne doit pas** pouvoir revenir à une question précédente. | T | 1 | EF-10 |
| **REQ-032** | Une réponse **doit** être acceptée uniquement dans l'état `answering`, et uniquement si sa valeur appartient aux options de la question courante. Une valeur hors options **doit** être refusée par `InvalidAnswerError` sans modifier l'état. | T | 1 | IF-03, RG-04 |
| **REQ-033** | Chaque question **doit** recevoir **exactement une** réponse (valeur ou `null` pour expiration). Une seconde réponse sur la même question **doit** être ignorée sans effet. | T | 1 | RG-04 |
| **REQ-034** | L'expiration **doit** être décidée par comparaison à une **échéance absolue** (`deadline = début + durée`), et non par décrément d'un compteur. Le temps restant **doit** être `max(0, deadline - now)`. | T | 1 | ANO-11 |
| **REQ-035** | À l'expiration, la réponse courante **doit** valoir `null` et la session **doit** passer à la question suivante, ou se terminer si c'était la dernière. | T | 1 | RG-05 |
| **REQ-036** | La session **doit** exposer une machine à états explicite et exhaustive : `answering(index)` → `finished`. La transition `finished` **doit** être effectuée exactement une fois ; toute opération après `finished` **doit** être sans effet. | T | 1 | EF-10, ANO-02 |
| **REQ-037** | La suspension de l'application **ne doit pas** suspendre le temps : au retour, le temps restant **doit** refléter le temps réel écoulé, et la question **doit** expirer immédiatement si l'échéance est dépassée. Aucun contournement du chronomètre n'est possible. | T | 1 | ANO-10 |
| **REQ-038** | À la fin de la session, le résultat **doit** comporter : score, nombre de questions, niveau débloqué (le cas échéant, cf. REQ-013) et un éventuel échec de persistance, sans jamais masquer ce dernier. | T | 2 | EF-15 |

### 4.5 Persistance

| ID | Exigence | Vérif. | Crit. | Source |
|---|---|---|---|---|
| **REQ-040** | L'état **doit** être persisté sous **une clé unique** `quizgame.state.v1`, contenant une enveloppe JSON `{"v":1,"crc":"<8 hex>","data":{...}}` où `crc` est un CRC-32 du JSON canonique de `data` (clés triées). | T | 1 | ANO-07 |
| **REQ-041** | À la lecture, un document **doit** être refusé (`CorruptedStateError`) si : JSON invalide, version inconnue, enveloppe incomplète, CRC non concordant, ou type de champ inattendu. Un refus **doit** ramener l'état aux valeurs par défaut (`score = 0`, progression vide) **sans** lever d'exception vers l'IHM, et **doit** être journalisé avec un code d'erreur. | T | 1 | ANO-07, ENF-02 |
| **REQ-042** | Toute écriture **doit** porter sur le document complet (lecture-modification-écriture) et être unique. Deux mutations concurrentes **ne doivent pas** pouvoir produire un document incohérent : les écritures **doivent** être sérialisées par un verrou logique. | T | 1 | ANO-06 |
| **REQ-043** | Une écriture **ne doit pas** être effectuée si l'état est identique à l'état lu (idempotence, pas de bruit d'écriture). | T | 2 | ANO-06 |
| **REQ-044** | Un échec d'écriture **doit** remonter une erreur typée `StateWriteError` et **ne doit pas** laisser l'IHM dans un état de succès. | T | 1 | EF-15 |

### 4.6 Erreurs et observabilité

| ID | Exigence | Vérif. | Crit. | Source |
|---|---|---|---|---|
| **REQ-050** | Toute erreur traversant une frontière **doit** être une instance d'une hiérarchie scellée (`DomainError`, `ContentError`, `StateError_`*), et **jamais** une exception du framework, un `String` ou un `dynamic`. | A | 1 | ANO-14 |
| **REQ-051** | L'IHM **doit** afficher un message issu d'un **catalogue de messages** indexé par code d'erreur. Aucun `toString()` d'exception, aucun nom de fichier technique, aucune trace **ne doit** être affiché à l'utilisateur. | T | 1 | ANO-14 |
| **REQ-052** | Le détail technique **doit** être journalisé via un port de journalisation (niveau, code, contexte), sans donnée personnelle. Le port **doit** être remplaçable en test par une doublure. | T | 2 | ENF-11 |
| **REQ-053** | Aucune future non attendue **ne doit** propager une erreur non gérée : chaque appel asynchrone depuis l'IHM **doit** être protégé par `try/catch` sur `Object` et produire un état d'échec. | A | 1 | ANO-14 |

\* Nom concret : `StateStoreError` (cf. DD-001 §5.8) — la notation `StateError_` évite toute confusion avec `StateError` du SDK Dart.

### 4.7 Présentation

| ID | Exigence | Vérif. | Crit. | Source |
|---|---|---|---|---|
| **REQ-060** | Chaque écran **doit** modéliser son état par une union scellée `Loading | Ready<T> | Failure(code)` et afficher respectivement : indicateur de chargement, contenu, message + action « Réessayer ». | T | 2 | EF-19 |
| **REQ-061** | L'écran de sélection **doit** présenter les 8 thèmes en grille : 2 colonnes si la largeur < 700 dp, 4 colonnes au-delà. | T | 3 | EF-01 |
| **REQ-062** | L'écran des niveaux **doit** afficher, pour chaque niveau du catalogue, son numéro, son état verrouillé/déverrouillé, et désactiver toute interaction sur un niveau verrouillé. | T | 2 | EF-04 |
| **REQ-063** | L'écran de quiz **doit** afficher : « Question i sur n », le score courant, le temps restant en secondes, une barre de progression du temps, et les options sous forme de boutons désactivés dès qu'une réponse est enregistrée. | T | 2 | EF-10, EF-11 |
| **REQ-064** | L'écran de résultat **doit** afficher le score `s / n`, le thème, le niveau, un bandeau « Niveau X débloqué » uniquement si REQ-013 = `newlyUnlocked`, un avertissement visible en cas d'échec de persistance, et la revue question par question (votre réponse / bonne réponse). | T | 2 | EF-15 |
| **REQ-065** | Toute action destructive (réinitialisation du score, réinitialisation d'une progression) **doit** être précédée d'un dialogue de confirmation avec libellés explicites ; l'annulation **ne doit** produire aucun effet. | T | 2 | EF-03, EF-06 |
| **REQ-066** | Aucune chaîne destinée à l'utilisateur **ne doit** être codée en dur dans un widget : toutes **doivent** provenir du catalogue de messages `AppStrings` (préparation à la localisation). | A | 3 | ANO-20 |
| **REQ-067** | L'accessibilité **doit** être assurée : libellés sémantiques sur le temps restant, la progression, le score et chaque option ; cibles tactiles ≥ 48 dp ; contraste texte/fond ≥ 4,5:1 ; aucune information portée par la seule couleur. | T | 2 | ANO-20, ENF-07 |

---

## 5. Exigences non fonctionnelles

| ID | Exigence | Vérif. | Crit. | Source |
|---|---|---|---|---|
| **REQ-070** | **Performance** : démarrage à froid ≤ 2 s sur l'appareil de référence (Android API 30, 4 Go) ; changement de question ≤ 100 ms ; transition d'écran ≤ 300 ms ; écart du chronomètre ≤ 50 ms sur 10 s. | T | 2 | ENF-01 |
| **REQ-071** | **Empreinte** : ≤ 120 Mo de mémoire résidente en session ; aucun timer ni souscription actif après `dispose`. | T/A | 2 | ENF-01 |
| **REQ-072** | **Robustesse** : aucune exception non capturée ne doit atteindre la boucle d'événements Flutter, quel que soit le contenu des assets ou de l'état persisté (y compris corrompu, tronqué, typé anormalement). | T | 1 | ENF-02 |
| **REQ-073** | **Maintenabilité** : fichier ≤ 200 lignes ; fonction ≤ 30 lignes ; ≤ 4 paramètres ; complexité cyclomatique ≤ 10 ; aucune récursion ; aucun `dynamic` hors adaptateur JSON ; aucun `static` mutable. | A | 1 | ENF-04 |
| **REQ-074** | **Testabilité** : le paquet `domain` **ne doit** dépendre ni de `package:flutter`, ni de `shared_preferences`, ni de `dart:io`, ni de `dart:math`. L'horloge, l'aléa, le stockage et le contenu **doivent** être injectés via des ports. Cette règle **doit** être vérifiée automatiquement (test d'architecture). | T | 1 | ENF-05, ANO-03 |
| **REQ-075** | **Couverture** : 100 % des instructions et 100 % des branchements sur `domain` et `application` ; ≥ 90 % des instructions sur `infrastructure`. La mesure **doit** être produite par l'outil et archivée avec le rapport de tests. | T | 1 | Tableau A.21 |
| **REQ-076** | **Portabilité** : Android API ≥ 23 ; rendu correct de 320 à 1024 dp de large, en portrait et en paysage ; aucune orientation imposée. | T | 2 | ENF-06 |
| **REQ-077** | **Sécurité et vie privée** : aucune permission réseau ; aucune donnée personnelle collectée, stockée ou transmise ; aucune télémétrie. | A | 1 | ENF-10 |
| **REQ-078** | **Déterminisme** : pour un même état initial, une même graine et une même séquence d'entrées, la session produit exactement la même suite d'états et le même score. | T | 1 | ENF-09 |
| **REQ-079** | **Reproductibilité du build** : le binaire **doit** être produit à partir de l'état exact du dépôt (`pubspec.lock` versionné, aucune réécriture de source par la CI). | A | 1 | ANO-23 |
| **REQ-080** | **Internationalisation** : toutes les chaînes **doivent** être centralisées et le formatage des nombres/dates passer par `intl` ; seule la locale `fr` est livrée. | A | 3 | ANO-20 |

---

## 6. Exigences relatives aux interfaces (rappel normatif)

Conformément au §7.3.4.19, chaque interface doit spécifier : préconditions et
postconditions, valeurs limites, comportement à la limite et au-delà, gestion
des exceptions, mémoire allouée aux tampons, mécanismes de synchronisation.

Le tableau complet est en **ARCH-001 §6**. Les exigences de comportement
associées sont, dans le présent document : REQ-001..008 (IF-05), REQ-040..044
(IF-06), REQ-034, REQ-037 (IF-07/08), REQ-067 (IF-10), REQ-032 (IF-03).

---

## 7. Hypothèses et dépendances

| ID | Hypothèse | Impact si invalidée |
|---|---|---|
| **H1** | SIL 2 est une décision de projet, non dérivée d'une analyse de risques (§3.2) | Le dossier devrait être réévalué sur la base de l'EN 50126-1 |
| **H2** | Le produit reste Android, hors ligne, mono-utilisateur | IF-05/IF-06 et la stratégie de stockage changeraient |
| **H3** | Aucun seuil de réussite n'est requis pour déverrouiller (REQ-012) | `UnlockPolicy` et les tests TC-APP-03/04 changeraient |
| **H4** | Le score vaut 1 point par bonne réponse, sans pondération | `ScoringRules` et l'affichage changeraient |
| **H5** | Une session abandonnée n'est pas enregistrée | La machine à états et la persistance changeraient |
| **H6** | Le contenu réel (`assets/`) sera fourni avant la validation | Les tests d'ensemble utiliseraient des jeux de test |
| **H7** | `shared_preferences` reste le support de persistance | Un stockage fichier serait préférable pour l'atomicité |

---

## 8. Exigences écartées et justifications

| Exigence potentielle | Décision | Justification |
|---|---|---|
| Synchronisation en ligne, comptes utilisateurs | Écartée | Hors périmètre (H2) ; introduirait des données personnelles (REQ-077) |
| Sons et effets audio | Écartée | Fonctionnalité présente dans la v7 mais **jamais implémentée** (ANO-18) ; supprimée pour réduire la surface |
| Mode multijoueur / classement | Écartée | Hors périmètre fonctionnel |
| Édition du contenu dans l'application | Écartée | Le contenu relève du §8.4 et est livré avec le produit (APP-DATA-001) |

---

## 9. Traçabilité vers les tests

| Exigence | Cas de test | Type |
|---|---|---|
| REQ-001..008 | TC-INF-01..08, TC-DOM-01..09 | Composant |
| REQ-010..017 | TC-DOM-10..13, TC-APP-01..06, TC-INT-02 | Composant / intégration |
| REQ-020..024 | TC-DOM-14..17, TC-APP-05, TC-INT-03 | Composant / intégration |
| REQ-030..038 | TC-DOM-18..26, TC-APP-07..10 | Composant |
| REQ-040..044 | TC-INF-09..16 | Composant |
| REQ-050..053 | TC-INT-04..06 | Intégration |
| REQ-060..067 | TC-SYS-01..12 | Ensemble |
| REQ-070..080 | TC-SYS-13..20, TC-ARCH-01..03 | Ensemble / architecture |

La matrice complète (exigence ↔ composant ↔ test ↔ anomalie) est tenue dans
**TRACE-001**.

---

## 10. Revue et approbation

| Rôle | Nom | Date | Signature | Décision |
|---|---|---|---|---|
| Gestionnaire des exigences | _à nommer_ | | | ☐ Accepté ☐ Refusé |
| Chargé de vérification (indépendant) | _à nommer_ | | | ☐ Accepté ☐ Refusé |
| Chargé de validation | _à nommer_ | | | ☐ Accepté ☐ Refusé |
| Chef de projet | _à nommer_ | | | ☐ Accepté ☐ Refusé |

> Conformément à §5.1.2.11 h), le Chargé de vérification et le Chargé de
> validation ne peuvent pas être le rédacteur de ce document. Ces signatures
> sont **requises** avant le début de la conception ; leur absence est consignée
> comme non-conformité organisationnelle ouverte dans MATRICE-CONFORMITE (C-05).

**Fin du document — SRS-001 v1.0**
