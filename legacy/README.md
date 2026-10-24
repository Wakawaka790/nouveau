# legacy/ — baseline « Quiz Game 7 » (avant refonte)

Ce dossier contient le code **existant** (v7), extrait du PDF
`code_complet_quiz_game7 (1).pdf` (58 pages, édition du 17/10/2026, branche
`arena/11f2f6d3-test`).

## Pourquoi ce dossier existe

La NF EN 50128:2011 exige une **gestion de configuration** (§6.5) : l'état de
référence avant modification doit être identifié, archivé et retrouvable. Cette
copie sert de :

1. **baseline de référence** pour la traçabilité des modifications ;
2. **source de vérité** pour l'analyse fonctionnelle (`docs/AN-FON-001_...md`) ;
3. **point de comparaison** lors de la revue de conformité de la nouvelle
   version.

## Contenu (39 fichiers, dont 16 fichiers Dart, 1 590 lignes de Dart)

```
lib/                    code applicatif Flutter (15 fichiers)
main.dart               second point d'entrée (non utilisé, cf. ANO-05)
pubspec.yaml            dépendances et assets
analysis_options.yaml   règles d'analyse statique
android/                projet Android (Gradle KTS, manifestes, MainActivity)
.github/                scripts Python de préparation + workflow de build APK
.gitignore
```

## Avertissements de reconstruction

* Le code a été **extrait d'un PDF** : les longues lignes repliées à
  l'impression ont été recombinées avec un espace. La sémantique est préservée,
  la mise en forme d'origine peut différer localement (retours à la ligne).
* Les **numéros de ligne** des fichiers de ce dossier correspondent à la
  numérotation marginale du PDF (vérifié fichier par fichier). Les références
  `fichier:ligne` du document d'analyse pointent donc sur ce dossier.
* Les **ressources** (`assets/**` : JSON de questions, images, sons) ne sont
  **pas** incluses : le PDF les exclut explicitement. Voir §11 de l'analyse
  (ANO-19) pour les fichiers manquants à confirmer.
* `android/local.properties` est volontairement absent (chemins machine).

## Statut

**Ne pas modifier ce dossier.** Toute évolution se fait dans la nouvelle
arborescence (`lib/` à la racine, cf. plan de refonte §15). Ce dossier est figé
et ne sert qu'à la traçabilité.
