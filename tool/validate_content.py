#!/usr/bin/env python3
"""Validateur des données d'application (NF EN 50128 §8.4, Tableau A.11).

Vérifie, pour chaque thème livré :
  * la présence et la validité de `levels.json` (REQ-002, REQ-003) ;
  * l'existence d'un `level_<n>.json` pour CHAQUE niveau déclaré (REQ-004) ;
  * la validité de chaque question : énoncé, bonne réponse, au moins deux
    options, options non vides, sans doublon, bonne réponse présente (REQ-005) ;
  * l'absence de fichier orphelin (niveau non déclaré dans `levels.json`) ;
  * la non-régression du volume (aucun niveau ne perd de questions).

Sortie : 0 si tout est conforme, 1 sinon. Utilisable en intégration continue
sans SDK Dart (APP-DATA-001 §6).

Usage :
    python3 tool/validate_content.py [--root assets/questions] [--baseline fichier.json]
"""

from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path

THEMES_ATTENDUS = {
    "arabe", "sira", "coran", "histoire", "sahaba", "hijra", "terme", "general",
}
NIVEAUX_MAX = 99
QUESTIONS_MAX_PAR_NIVEAU = 200
OPTIONS_MAX = 10
TEXTE_MAX = 500


class Rapport:
    def __init__(self) -> None:
        self.erreurs: list[str] = []
        self.avertissements: list[str] = []
        self.volumes: dict[str, dict[str, int]] = {}

    def erreur(self, message: str) -> None:
        self.erreurs.append(message)

    def avertissement(self, message: str) -> None:
        self.avertissements.append(message)


def lire_json(chemin: Path, rapport: Rapport) -> object | None:
    try:
        return json.loads(chemin.read_text(encoding="utf-8"))
    except FileNotFoundError:
        rapport.erreur(f"{chemin}: fichier absent")
    except json.JSONDecodeError as erreur:
        rapport.erreur(f"{chemin}: JSON invalide ({erreur.msg} ligne {erreur.lineno})")
    return None


def valider_catalogue(theme: str, chemin: Path, rapport: Rapport) -> list[int] | None:
    contenu = lire_json(chemin, rapport)
    if contenu is None:
        return None
    if not isinstance(contenu, dict):
        rapport.erreur(f"{chemin}: un objet JSON est attendu")
        return None
    brut = contenu.get("Levels", contenu.get("levels"))
    if not isinstance(brut, list):
        rapport.erreur(f"{chemin}: clé « Levels » absente ou non liste")
        return None
    niveaux: list[int] = []
    for valeur in brut:
        if isinstance(valeur, bool) or not isinstance(valeur, (int, str)):
            rapport.erreur(f"{chemin}: niveau non numérique ({valeur!r})")
            continue
        try:
            niveau = int(valeur)
        except (TypeError, ValueError):
            rapport.erreur(f"{chemin}: niveau non convertible ({valeur!r})")
            continue
        if niveau < 1 or niveau > NIVEAUX_MAX:
            rapport.erreur(f"{chemin}: niveau hors bornes 1..{NIVEAUX_MAX} ({niveau})")
            continue
        if niveau in niveaux:
            rapport.erreur(f"{chemin}: niveau {niveau} en double")
            continue
        niveaux.append(niveau)
    if not niveaux:
        rapport.erreur(f"{chemin}: aucun niveau configuré")
        return None
    if sorted(niveaux)[0] != 1:
        rapport.erreur(f"{chemin}: le premier niveau doit être 1")
    if len(niveaux) > NIVEAUX_MAX:
        rapport.erreur(f"{chemin}: plus de {NIVEAUX_MAX} niveaux")
    return sorted(niveaux)


def valider_niveau(theme: str, niveau: int, chemin: Path, rapport: Rapport) -> int:
    contenu = lire_json(chemin, rapport)
    if contenu is None:
        return 0
    if not isinstance(contenu, list):
        rapport.erreur(f"{chemin}: une liste JSON est attendue")
        return 0
    if not contenu:
        rapport.erreur(f"{chemin}: aucune question")
        return 0
    if len(contenu) > QUESTIONS_MAX_PAR_NIVEAU:
        rapport.erreur(f"{chemin}: plus de {QUESTIONS_MAX_PAR_NIVEAU} questions")

    enonces: set[str] = set()
    for index, question in enumerate(contenu, start=1):
        prefixe = f"{chemin}: question {index}"
        if not isinstance(question, dict):
            rapport.erreur(f"{prefixe}: objet attendu")
            continue
        enonce = question.get("question", question.get("arabe"))
        bonne = question.get("correct", question.get("correctAnswer"))
        options = question.get("options")

        if not isinstance(enonce, str) or not enonce.strip():
            rapport.erreur(f"{prefixe}: énoncé invalide")
            continue
        if len(enonce) > TEXTE_MAX:
            rapport.erreur(f"{prefixe}: énoncé de plus de {TEXTE_MAX} caractères")
        if enonce.strip() in enonces:
            rapport.avertissement(f"{prefixe}: énoncé en double dans le niveau")
        enonces.add(enonce.strip())

        if not isinstance(bonne, str) or not bonne.strip():
            rapport.erreur(f"{prefixe}: bonne réponse invalide")
            continue
        if not isinstance(options, list) or not all(
            isinstance(option, str) for option in options
        ):
            rapport.erreur(f"{prefixe}: « options » doit être une liste de textes")
            continue
        propres = [option.strip() for option in options]
        if len(propres) < 2:
            rapport.erreur(f"{prefixe}: au moins deux options sont requises")
        if len(propres) > OPTIONS_MAX:
            rapport.erreur(f"{prefixe}: plus de {OPTIONS_MAX} options")
        if any(option == "" for option in propres):
            rapport.erreur(f"{prefixe}: option vide")
        if len(set(propres)) != len(propres):
            rapport.erreur(f"{prefixe}: option en double")
        if bonne.strip() not in propres:
            rapport.erreur(f"{prefixe}: la bonne réponse est absente des options")

    return len(contenu)


def valider_racine(racine: Path, rapport: Rapport) -> None:
    if not racine.is_dir():
        rapport.erreur(f"{racine}: répertoire absent")
        return
    presents = {dossier.name for dossier in racine.iterdir() if dossier.is_dir()}
    for theme in sorted(THEMES_ATTENDUS - presents):
        rapport.erreur(f"{racine}: thème attendu absent ({theme})")
    for theme in sorted(presents - THEMES_ATTENDUS):
        rapport.avertissement(f"{racine}: thème non déclaré dans le logiciel ({theme})")

    for theme in sorted(presents & THEMES_ATTENDUS):
        dossier = racine / theme
        niveaux = valider_catalogue(theme, dossier / "levels.json", rapport)
        volumes: dict[str, int] = {}
        if niveaux is not None:
            for niveau in niveaux:
                chemin = dossier / f"level_{niveau}.json"
                if not chemin.exists():
                    rapport.erreur(
                        f"{chemin}: niveau déclaré mais fichier absent (REQ-004)"
                    )
                    continue
                volumes[str(niveau)] = valider_niveau(theme, niveau, chemin, rapport)
            declares = {f"level_{niveau}.json" for niveau in niveaux}
            for fichier in sorted(dossier.glob("level_*.json")):
                if fichier.name not in declares:
                    rapport.avertissement(
                        f"{fichier}: fichier orphelin (niveau non déclaré)"
                    )
        rapport.volumes[theme] = volumes


def comparer_baseline(rapport: Rapport, chemin: Path) -> None:
    try:
        baseline = json.loads(chemin.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError):
        rapport.avertissement(f"{chemin}: référence de volume absente ou illisible")
        return
    for theme, niveaux in rapport.volumes.items():
        reference = baseline.get(theme, {})
        for niveau, volume in niveaux.items():
            attendu = reference.get(niveau)
            if isinstance(attendu, int) and volume < attendu:
                rapport.erreur(
                    f"{theme}/niveau {niveau}: {volume} questions contre {attendu} "
                    "en référence (régression de contenu)"
                )


def main() -> int:
    parseur = argparse.ArgumentParser(description=__doc__)
    parseur.add_argument("--root", default="assets/questions")
    parseur.add_argument("--baseline", default=None)
    parseur.add_argument("--write-baseline", default=None)
    arguments = parseur.parse_args()

    rapport = Rapport()
    valider_racine(Path(arguments.root), rapport)

    if arguments.write_baseline:
        Path(arguments.write_baseline).write_text(
            json.dumps(rapport.volumes, ensure_ascii=False, indent=2, sort_keys=True)
            + "\n",
            encoding="utf-8",
        )
        print(f"Référence de volume écrite : {arguments.write_baseline}")
    elif arguments.baseline:
        comparer_baseline(rapport, Path(arguments.baseline))

    total = sum(sum(niveaux.values()) for niveaux in rapport.volumes.values())
    print(f"Thèmes vérifiés : {len(rapport.volumes)} — questions : {total}")
    for avertissement in rapport.avertissements:
        print(f"AVERTISSEMENT {avertissement}")
    for erreur in rapport.erreurs:
        print(f"ERREUR {erreur}")
    if rapport.erreurs:
        print(f"\n{len(rapport.erreurs)} erreur(s) — validation REFUSÉE")
        return 1
    print("\nValidation du contenu : CONFORME")
    return 0


if __name__ == "__main__":
    sys.exit(main())
