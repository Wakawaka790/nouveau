#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
prepare_project.py — prépare le projet Flutter avant la compilation de l'APK.

Appelé par .github/workflows/build-apk.yml.

1. Localise la racine du projet Flutter :
     - le dépôt lui-même si lib/main.dart s'y trouve déjà ;
     - sinon une archive .zip déposée à la racine du dépôt (décompressée) ;
     - sinon un sous-dossier contenant pubspec.yaml + lib/main.dart.
2. Vérifie que le code source est bien présent. Sinon, s'arrête en expliquant
   précisément ce qui manque et comment le fournir.
3. Corrige une contrainte de SDK Dart qui interdit Dart 3
   (ex. « >=2.17.0 <3.0.0 » -> « >=3.0.0 <4.0.0 »).
4. Ajoute une version au pubspec si elle est absente (nécessaire pour l'APK).
5. Retire du pubspec.yaml les assets absents ou en double : flutter refuse de
   démarrer si une seule entrée d'asset n'existe pas sur le disque.
6. Écrit project_root / project_name / app_name dans $GITHUB_OUTPUT.
"""

from __future__ import annotations

import glob
import os
import re
import sys
import zipfile

WORKSPACE = os.path.abspath(os.environ.get("GITHUB_WORKSPACE") or os.getcwd())
EXTRACT_DIR = os.path.join(WORKSPACE, ".projet_extraite")

IGNORED_DIRS = {".git", ".github", ".dart_tool", "build", "node_modules", ".idea", "ios", "web", "windows", "linux", "macos"}
MAX_DEPTH = 3

# Point d'entrée réel d'une application Flutter : lib/main.dart.
# (un main.dart isolé à la racine du dépôt ne suffit pas : flutter ne l'utilise pas)
ENTRY_POINT = os.path.join("lib", "main.dart")

SDK_LINE = re.compile(r'^(?P<indent>[ \t]*)sdk:[ \t]*(?P<quote>["\']?)(?P<value>[^"\'\n#]*)(?P=quote)', re.M)
VERSION_LINE = re.compile(r'^version:[ \t]*\S', re.M)
ASSETS_KEY = re.compile(r'assets:[ \t]*$')
ASSET_ITEM = re.compile(r'-[ \t]+(?P<path>.+?)[ \t]*$')

EXPECTED_STRUCTURE = """\
quiz_game7/
├── lib/                 <- tout le code Dart (models, screens, services, widgets)
│   └── main.dart
├── assets/              <- questions JSON, sons, images, logo
├── pubspec.yaml
└── android/             <- optionnel : généré automatiquement s'il est absent
"""


def log(message: str) -> None:
    print(f"[prepare] {message}", flush=True)


def set_output(key: str, value: str) -> None:
    path = os.environ.get("GITHUB_OUTPUT")
    if path:
        with open(path, "a", encoding="utf-8") as handle:
            handle.write(f"{key}={value}\n")
    log(f"sortie : {key} = {value}")


def add_summary(markdown: str) -> None:
    path = os.environ.get("GITHUB_STEP_SUMMARY")
    if path:
        with open(path, "a", encoding="utf-8") as handle:
            handle.write(markdown + "\n")


def has_dart_source(root: str) -> bool:
    return os.path.isfile(os.path.join(root, ENTRY_POINT))


def looks_like_project(path: str) -> bool:
    return os.path.isfile(os.path.join(path, "pubspec.yaml")) and has_dart_source(path)


def has_stray_main() -> bool:
    """Un main.dart isolé à la racine : présent dans ce dépôt, inutilisable par Flutter."""
    return os.path.isfile(os.path.join(WORKSPACE, "main.dart")) and not has_dart_source(WORKSPACE)


def walk_projects(base: str):
    """Parcourt `base` (profondeur limitée) à la recherche d'un projet Flutter."""
    base = os.path.abspath(base)
    for current, dirs, _files in os.walk(base):
        depth = os.path.relpath(current, base).count(os.sep)
        dirs[:] = [d for d in dirs if d not in IGNORED_DIRS and not d.startswith(".")]
        if current != base and depth < MAX_DEPTH and looks_like_project(current):
            yield current
        if depth >= MAX_DEPTH:
            dirs[:] = []


def _safe_extract(zf: zipfile.ZipFile, target: str) -> None:
    """Extrait `zf` dans `target` en refusant les chemins qui en sortiraient.

    Corrigé : un appel direct à extractall() suit les entrées « ../.. »
    d'une archive malveillante et peut écrire hors du dossier cible
    (« Zip Slip », CWE-22).
    """
    target_abs = os.path.abspath(target)
    for member in zf.infolist():
        destination = os.path.abspath(os.path.join(target_abs, member.filename))
        if destination != target_abs and not destination.startswith(target_abs + os.sep):
            raise ValueError(f"chemin dangereux dans l'archive : {member.filename}")
    zf.extractall(target_abs)


def extract_archives() -> list[str]:
    """Décompresse les .zip déposés à la racine du dépôt."""
    zones: list[str] = []
    for archive in sorted(glob.glob(os.path.join(WORKSPACE, "*.zip"))):
        target = os.path.join(EXTRACT_DIR, os.path.splitext(os.path.basename(archive))[0])
        log(f"archive détectée : {os.path.basename(archive)} -> décompression dans « {os.path.relpath(target, WORKSPACE)} »")
        os.makedirs(target, exist_ok=True)
        try:
            with zipfile.ZipFile(archive) as zf:
                _safe_extract(zf, target)
        except (zipfile.BadZipFile, ValueError) as error:
            log(f"⚠️  {os.path.basename(archive)} ignorée (archive invalide : {error}).")
            continue
        zones.append(target)
    return zones


def locate_project() -> tuple[str | None, str]:
    if looks_like_project(WORKSPACE):
        return WORKSPACE, "racine du dépôt"
    for zone in extract_archives():
        if looks_like_project(zone):
            return zone, "archive .zip déposée à la racine"
        for candidate in walk_projects(zone):
            return candidate, "archive .zip déposée à la racine"
    for candidate in walk_projects(WORKSPACE):
        return candidate, "sous-dossier du dépôt"
    return None, ""


def _major(version: str) -> int | None:
    found = re.match(r"\s*(\d+)", version)
    return int(found.group(1)) if found else None


def fix_dart_constraint(text: str) -> tuple[str, str | None]:
    """Autorise Dart 3 quand le pubspec l'interdit encore."""
    for match in SDK_LINE.finditer(text):
        value = match.group("value").strip()
        if ">=" not in value or "flutter" in value:
            continue
        upper = re.search(r"<\s*([0-9][0-9.]*)", value)
        if upper is not None and _major(upper.group(1)) is not None and _major(upper.group(1)) >= 4:
            return text, None
        replacement = f'{match.group("indent")}sdk: ">=3.0.0 <4.0.0"'
        return text.replace(match.group(0), replacement, 1), value
    return text, None


def ensure_version(text: str) -> tuple[str, bool]:
    """Le build Android exige un numéro de version dans le pubspec."""
    if VERSION_LINE.search(text):
        return text, False
    lines = text.splitlines(keepends=True)
    insert_at = 1
    for index, line in enumerate(lines):
        if line.startswith("description:"):
            insert_at = index + 1
            break
    lines.insert(insert_at, "version: 1.0.0+1\n")
    return "".join(lines), True


def prune_assets(text: str, root: str) -> tuple[str, list[str], list[str]]:
    """Supprime les entrées d'assets absentes (flutter refuse de démarrer) et les doublons."""
    kept: list[str] = []
    missing: list[str] = []
    duplicates: list[str] = []
    seen: set[str] = set()
    in_assets = False
    assets_indent = 0

    for line in text.splitlines(keepends=True):
        stripped = line.strip()
        indent = len(line) - len(line.lstrip(" "))

        if not in_assets:
            if ASSETS_KEY.fullmatch(stripped):
                in_assets = True
                assets_indent = indent
            kept.append(line)
            continue

        if stripped == "" or stripped.startswith("#"):
            kept.append(line)
            continue

        item = ASSET_ITEM.fullmatch(stripped)
        if item and indent > assets_indent:
            entry = item.group("path").strip().strip("\"'")
            if entry in seen:
                duplicates.append(entry)
                continue
            seen.add(entry)
            if entry.endswith("/"):
                exists = os.path.isdir(os.path.join(root, entry))
            else:
                exists = os.path.exists(os.path.join(root, entry))
            if not exists:
                missing.append(entry)
                continue
            kept.append(line)
            continue

        in_assets = False
        kept.append(line)

    return "".join(kept), missing, duplicates


def read_field(text: str, field: str) -> str | None:
    match = re.search(rf"^{field}:[ \t]*(?P<value>.+?)[ \t]*$", text, re.M)
    return match.group("value").strip().strip("\"'") if match else None


def explain_missing() -> None:
    listing = []
    for entry in sorted(os.listdir(WORKSPACE)):
        if entry.startswith(".") and entry not in {".gitignore"}:
            continue
        full = os.path.join(WORKSPACE, entry)
        listing.append(f"  {'📁' if os.path.isdir(full) else '📄'} {entry}")
    found = "\n".join(listing) if listing else "  (dépôt vide)"

    hint = ""
    if has_stray_main():
        hint = (
            "\n⚠️  Un fichier « main.dart » isolé se trouve bien à la racine du dépôt, mais Flutter\n"
            "    n'utilise que « lib/main.dart ». Il faut donc créer le dossier lib/ contenant tout\n"
            "    le code source (models, screens, services, widgets).\n"
        )

    message = f"""Le code source de l'application est introuvable dans le dépôt.

Contenu trouvé à la racine du dépôt :
{found}

Structure attendue (celle de votre schéma d'application) :
{EXPECTED_STRUCTURE}{hint}
Comment fournir le code, au choix :
  1. pousser votre projet depuis votre PC : git add . && git commit -m "Ajout du projet" && git push
  2. glisser-déposer le contenu du projet (dossiers lib/, assets/, android/, pubspec.yaml)
     dans la page GitHub du dépôt -> bouton « Add file » -> « Upload files »
  3. déposer une archive .zip de votre projet à la racine du dépôt (elle sera décompressée
     automatiquement par ce workflow)
Dès que le code est présent, la compilation de l'APK se relance toute seule."""

    print("\n" + "=" * 78, flush=True)
    print(message, flush=True)
    print("=" * 78 + "\n", flush=True)
    print("::error::Code source introuvable (lib/main.dart absent) — voir le détail ci-dessus.", flush=True)

    add_summary(
        "## ❌ APK non généré : le code source est absent du dépôt\n\n"
        "Le dépôt ne contient que les fichiers de configuration `pubspec.yaml`, `main.dart` à la racine, etc.\n\n"
        "### Ce qui a été trouvé à la racine\n\n```\n" + found + "\n```\n\n"
        "### Structure attendue\n\n```\n" + EXPECTED_STRUCTURE + "```\n\n"
        "### Comment fournir le code\n\n"
        "1. **Depuis votre PC** : `git add .` puis `git commit -m \"Ajout du projet\"` puis `git push`\n"
        "2. **Via l'interface GitHub** : page du dépôt → *Add file* → *Upload files* (glissez les dossiers "
        "`lib/`, `assets/`, `android/` et le `pubspec.yaml`)\n"
        "3. **En déposant un .zip** du projet à la racine du dépôt : il sera décompressé automatiquement\n\n"
        "La compilation se relance automatiquement dès que le code est présent.\n"
    )


def main() -> int:
    log(f"espace de travail : {WORKSPACE}")
    root, origin = locate_project()

    if root is None:
        explain_missing()
        return 1

    log(f"projet Flutter trouvé : « {os.path.relpath(root, WORKSPACE)} » (via {origin})")

    pubspec_path = os.path.join(root, "pubspec.yaml")
    with open(pubspec_path, encoding="utf-8") as handle:
        original = handle.read()

    text = original

    text, old_constraint = fix_dart_constraint(text)
    if old_constraint:
        log(f"contrainte Dart corrigée : '{old_constraint}' -> '>=3.0.0 <4.0.0'")

    text, version_added = ensure_version(text)
    if version_added:
        log("aucune version déclarée : ajout de « version: 1.0.0+1 »")

    text, missing, duplicates = prune_assets(text, root)
    for entry in duplicates:
        log(f"asset en double retiré du pubspec : {entry}")
    for entry in missing:
        log(f"asset absent retiré du pubspec : {entry} (fichier introuvable sur le disque)")
    if not missing and not duplicates:
        log("tous les assets déclarés existent : rien à corriger")

    if text != original:
        with open(pubspec_path, "w", encoding="utf-8") as handle:
            handle.write(text)
        log("pubspec.yaml mis à jour")
    else:
        log("pubspec.yaml inchangé")

    name = read_field(text, "name") or "app"
    description = read_field(text, "description") or name
    if description.lower().startswith("a new flutter project"):
        description = name

    dart_files = sum(
        1 for _current, _dirs, files in os.walk(os.path.join(root, "lib")) for name_ in files if name_.endswith(".dart")
    ) if os.path.isdir(os.path.join(root, "lib")) else 0

    set_output("project_root", root)
    set_output("project_name", name)
    set_output("app_name", description)
    set_output("missing_assets", str(len(missing)))

    for folder in ("lib", "assets", "android"):
        present = os.path.isdir(os.path.join(root, folder))
        log(f"dossier {folder}/ : {'présent' if present else 'ABSENT'}")
    log(f"fichiers Dart dans lib/ : {dart_files}")

    if not os.path.isdir(os.path.join(root, "assets")):
        print("::warning::Le dossier assets/ est absent : l'application se compilera mais les questions/sons seront manquants.", flush=True)
    if not os.path.isdir(os.path.join(root, "android")):
        print("::notice::Le dossier android/ est absent : il sera généré automatiquement par 'flutter create'.", flush=True)

    add_summary(
        "## 🔧 Projet préparé pour la compilation\n\n"
        f"- Projet détecté : `{os.path.relpath(root, WORKSPACE)}` (via {origin})\n"
        f"- Nom du paquet : `{name}`\n"
        f"- Code Dart : {dart_files} fichier(s) dans `lib/`\n"
        f"- Assets absents retirés du pubspec : {len(missing)}\n"
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
