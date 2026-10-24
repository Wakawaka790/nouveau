#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
fix_android_config.py — aligne android/app/build.gradle(.kts) sur les besoins des plugins.

Le plugin audioplayers exige un minSdk plus élevé que le défaut de Flutter
(minSdk 23 contre 21). Ce script remonte donc la valeur si nécessaire, sans
jamais la baisser, aussi bien dans la syntaxe Groovy que dans la syntaxe
Kotlin DSL utilisée par les projets Flutter récents.

Usage :
    fix_android_config.py [--min-sdk 23] [--compile-sdk 36] [--root <projet>]
"""

from __future__ import annotations

import argparse
import os
import re
import sys

# Corrigé : la clé doit être ancrée en début de ligne. Sans cette ancre,
# l'expression trouvait aussi « minSdkVersion » dans les commentaires
# (ci-dessus, par exemple) et « corrigeait » le texte du commentaire au
# lieu du réglage Gradle.
SETTING = re.compile(
    r"(?P<indent>^[ \t]*)"
    r"(?P<key>minSdk(?:Version)?|compileSdk(?:Version)?)"
    r"(?P<sep>\s*=\s*|\s+)"
    r"(?P<value>flutter\.(?:minSdkVersion|compileSdkVersion)|\d+)",
    re.M,
)


def normalize(key: str) -> str:
    return key.removesuffix("Version").lower()


def find_gradle_file(root: str) -> str | None:
    for relative in ("android/app/build.gradle.kts", "android/app/build.gradle"):
        candidate = os.path.join(root, relative)
        if os.path.isfile(candidate):
            return candidate
    return None


def patch(path: str, targets: dict[str, int]) -> list[str]:
    with open(path, encoding="utf-8") as handle:
        text = handle.read()

    kts = path.endswith(".kts")
    changes: list[str] = []

    def replace(match: re.Match) -> str:
        key = match.group("key")
        key_norm = normalize(key)
        if key_norm not in targets:
            return match.group(0)

        raw_value = match.group("value")
        wanted = targets[key_norm]

        if not raw_value.startswith("flutter."):
            current = int(raw_value)
            if current >= wanted:
                return match.group(0)

        separator = match.group("sep")
        if kts and not separator.strip():
            separator = " = "
        elif not separator.strip():
            separator = " "

        changes.append(f"{key}: {raw_value} -> {wanted}")
        return f"{match.group('indent')}{key}{separator}{wanted}"

    updated = SETTING.sub(replace, text)

    if updated != text:
        with open(path, "w", encoding="utf-8") as handle:
            handle.write(updated)

    return changes


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", default=os.environ.get("GITHUB_WORKSPACE", os.getcwd()))
    parser.add_argument("--min-sdk", type=int, default=None)
    parser.add_argument("--compile-sdk", type=int, default=None)
    args = parser.parse_args()

    targets: dict[str, int] = {}
    if args.min_sdk:
        targets["minsdk"] = args.min_sdk
    if args.compile_sdk:
        targets["compilesdk"] = args.compile_sdk

    if not targets:
        print("[android] aucun ajustement demandé")
        return 0

    gradle_file = find_gradle_file(args.root)
    if gradle_file is None:
        print("::warning::android/app/build.gradle(.kts) introuvable — ajustement ignoré.")
        return 0

    changes = patch(gradle_file, targets)
    relative = os.path.relpath(gradle_file, args.root)
    if changes:
        for change in changes:
            print(f"[android] {relative} — {change}")
    else:
        print(f"[android] {relative} — déjà conforme ({targets})")
    return 0


if __name__ == "__main__":
    sys.exit(main())
