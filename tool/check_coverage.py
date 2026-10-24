#!/usr/bin/env python3
"""Contrôle du seuil de couverture (REQ-075, Tableau A.21).

Le fichier `lcov.info` produit par `flutter test --coverage` est analysé :
  * `lib/domain/**`      : 100 % des lignes exigé ;
  * `lib/application/**` : 100 % des lignes exigé ;
  * `lib/infrastructure/**` : 90 % minimum.

Sortie 0 si les seuils sont atteints, 1 sinon.
"""

from __future__ import annotations

import sys
from pathlib import Path

SEUILS = {
    "lib/domain/": 100.0,
    "lib/application/": 100.0,
    "lib/infrastructure/": 90.0,
}


def lire_lcov(chemin: Path) -> dict[str, tuple[int, int]]:
    """Retourne {fichier: (lignes couvertes, lignes trouvées)}."""
    resultats: dict[str, tuple[int, int]] = {}
    fichier = None
    trouvees = couvertes = 0
    for ligne in chemin.read_text(encoding="utf-8").splitlines():
        if ligne.startswith("SF:"):
            fichier = ligne[3:].strip()
            trouvees = couvertes = 0
        elif ligne.startswith("LF:"):
            trouvees = int(ligne[3:] or 0)
        elif ligne.startswith("LH:"):
            couvertes = int(ligne[3:] or 0)
        elif ligne == "end_of_record" and fichier is not None:
            resultats[fichier] = (couvertes, trouvees)
            fichier = None
    return resultats


def main() -> int:
    if len(sys.argv) < 2:
        print("usage: check_coverage.py coverage/lcov.info", file=sys.stderr)
        return 2
    chemin = Path(sys.argv[1])
    if not chemin.exists():
        print(f"ERREUR {chemin} absent : aucune mesure de couverture (REQ-075)")
        return 1

    donnees = lire_lcov(chemin)
    echecs = 0
    for prefixe, seuil in SEUILS.items():
        fichiers = {nom: valeurs for nom, valeurs in donnees.items() if prefixe in nom}
        if not fichiers:
            print(f"ERREUR aucune mesure pour {prefixe} (couverture non démontrée)")
            echecs += 1
            continue
        trouvees = sum(valeurs[1] for valeurs in fichiers.values())
        couvertes = sum(valeurs[0] for valeurs in fichiers.values())
        if trouvees == 0:
            print(f"ERREUR {prefixe} : aucune ligne mesurée")
            echecs += 1
            continue
        pourcentage = 100.0 * couvertes / trouvees
        etat = "OK" if pourcentage >= seuil else "ÉCHEC"
        print(
            f"{etat:5s} {prefixe:24s} {pourcentage:6.2f} % "
            f"(seuil {seuil:.0f} %, {couvertes}/{trouvees} lignes)"
        )
        if pourcentage < seuil:
            echecs += 1
    return 1 if echecs else 0


if __name__ == "__main__":
    sys.exit(main())
