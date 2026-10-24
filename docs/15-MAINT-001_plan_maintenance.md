# MAINT-001 — Plan de Maintenance du Logiciel

| | |
|---|---|
| **Référence** | MAINT-001 |
| **Version** | 1.0 |
| **Date** | 24 octobre 2026 |
| **Référentiel** | NF EN 50128:2011 §9.2 ; Tableau A.10 ; Tableau A.1 #41 à #44 |
| **Niveau** | SIL 2 |

---

## 1. Objet

Définir comment le logiciel sera corrigé et fait évoluer **sans dégrader** la
conformité établie par ce dossier. La maintenance est le moment où les dossiers
de conformité se dégradent le plus vite : toute modification doit donc passer
par le circuit de PLAN-CONF-001 §5.

---

## 2. Types de maintenance

| Type | Déclencheur | Circuit |
|---|---|---|
| **Corrective** | anomalie détectée en usage | DM prioritaire ; analyse de cause racine obligatoire |
| **Évolutive** | nouvelle fonctionnalité, nouveau thème | DM + révision du SRS + analyse d'impact complète |
| **Adaptative** | nouvelle version d'Android, de Flutter | DM + OUTILS-001 + tests d'ensemble |
| **Préventive** | dette technique, montée de version de lint | DM + tests de non-régression |

---

## 3. Procédure de maintenance

```
1. Enregistrement de la demande (DM-xxx)
2. Analyse d'impact (PLAN-CONF-001 §5.2)
3. Reproduction du défaut par un test (obligatoire pour une corrective)
4. Correction
5. Exécution de la CI complète (analyse, tests, couverture, contenu)
6. Mise à jour de la documentation affectée et de TRACE-001
7. Vérification indépendante
8. Nouvelle baseline + fiche de livraison
```

**Règle d'or** : aucun correctif n'est accepté sans **test qui échouait avant et
réussit après**. Cette règle est ce qui empêche la régression silencieuse.

---

## 4. Techniques du Tableau A.10 (SIL 2)

| # | Technique | SIL 2 | Application |
|---|---|---|---|
| 1 | Analyse d'impact | **HR** | PLAN-CONF-001 §5.2, grille par répertoire |
| 2 | Test de non-régression | **HR** | 144 cas existants + cas ajouté pour chaque correctif |
| 3 | Analyse de cause racine | R | obligatoire pour toute anomalie B ou M |
| 4 | Revue de la modification | **HR** | LC-03 (STD-COD-001 §6) |
| 5 | Traçabilité des modifications | R | registre PLAN-CONF-001 §6 + historique Git |

---

## 5. Points de vigilance spécifiques

| Élément | Risque de régression | Garde-fou |
|---|---|---|
| Persistance | modification du format → perte de progression des utilisateurs | version dans l'enveloppe ; toute évolution de `data` **doit** incrémenter `v` et prévoir une migration testée (comme REQ-015) |
| Chronomètre | retour à un découpage par ticks | TC-DOM-21 et revue de RC-18 |
| Contenu | question erronée diffusée | `validate_content.py` + revue APP-DATA-001 §5 |
| Score | changement de règle non répercuté | REQ-021 + TC-DOM-27..30 |
| Messages | fuite technique vers l'utilisateur | TC-PRS-08 |
| Dépendances | mise à jour cassant la reproductibilité | OUTILS-001 §3 + `pubspec.lock` |

---

## 6. Gestion des versions et compatibilité

| Version | Incrément | Compatibilité de données |
|---|---|---|
| Majeure | rupture d'architecture ou de format d'état | migration obligatoire |
| Mineure | nouvelle fonctionnalité | compatible |
| Corrective | correction | compatible |

Le format d'état porte `v = 1`. Une v2 de format exigera un décodeur v1 dans le
dépôt (lecture des deux versions) et un test de migration dédié.

---

## 7. Fin de vie

| Étape | Contenu |
|---|---|
| Décision | PM + VAL ; conservation du dossier complet |
| Archivage | dépôt + baseline + APK signé + empreinte |
| Information | notification aux utilisateurs, date de fin de support |
| Données | aucune donnée personnelle à détruire (REQ-077) |

---

## 8. Responsabilités

| Activité | Rôle |
|---|---|
| Triage des anomalies | TST |
| Analyse d'impact | DES + IMP |
| Correction | IMP |
| Vérification | VER (indépendant) |
| Acceptation d'une version | VAL |
| Enregistrement | gestionnaire de configuration |

**Fin du document — MAINT-001 v1.0**
