import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Tests d'architecture — ils rendent REQ-074 et REQ-073 **vérifiables
/// automatiquement** (Tableau A.19 : analyse statique en intégration continue).
void main() {
  final libDir = Directory('lib');
  final dartFiles = libDir
      .listSync(recursive: true)
      .whereType<File>()
      .where((file) => file.path.endsWith('.dart'))
      .toList();

  Iterable<File> filesIn(String folder) =>
      dartFiles.where((file) => file.path.startsWith('lib/$folder'));

  List<String> importsOf(File file) => file
      .readAsLinesSync()
      .where((line) => line.startsWith('import '))
      .toList(growable: false);

  group('Isolation du domaine (REQ-074)', () {
    test('le domaine n\'importe ni Flutter, ni plugin, ni IO, ni math', () {
      const forbidden = <String>[
        'package:flutter',
        'shared_preferences',
        'dart:io',
        'dart:math',
        'dart:ui',
      ];
      final violations = <String>[];
      for (final file in filesIn('domain')) {
        for (final line in importsOf(file)) {
          for (final pattern in forbidden) {
            if (line.contains(pattern)) {
              violations.add('${file.path}: $line');
            }
          }
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('le domaine n\'importe aucune autre couche', () {
      const forbidden = <String>[
        "import '../application",
        "import '../infrastructure",
        "import '../presentation",
        'package:quiz_game/application',
        'package:quiz_game/infrastructure',
        'package:quiz_game/presentation',
      ];
      final violations = <String>[];
      for (final file in filesIn('domain')) {
        for (final line in importsOf(file)) {
          if (forbidden.any(line.contains)) {
            violations.add('${file.path}: $line');
          }
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('l\'application n\'importe ni Flutter ni l\'infrastructure', () {
      const forbidden = <String>['package:flutter', 'package:quiz_game/infrastructure'];
      final violations = <String>[];
      for (final file in filesIn('application')) {
        for (final line in importsOf(file)) {
          if (forbidden.any(line.contains)) {
            violations.add('${file.path}: $line');
          }
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('la présentation n\'importe pas l\'infrastructure (sauf composition)', () {
      final violations = <String>[];
      for (final file in filesIn('presentation')) {
        for (final line in importsOf(file)) {
          if (line.contains('infrastructure/') &&
              !file.path.endsWith('app_dependencies.dart')) {
            violations.add('${file.path}: $line');
          }
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });

  group('Règles de codage (REQ-073 / STD-COD-001)', () {
    test('aucun fichier ne dépasse 200 lignes', () {
      final oversized = <String>[];
      for (final file in dartFiles) {
        final lines = file.readAsLinesSync().length;
        if (lines > 200) {
          oversized.add('${file.path} ($lines lignes)');
        }
      }
      expect(oversized, isEmpty, reason: oversized.join('\n'));
    });

    test('aucun `assert(` utilisé comme validation d\'entrée (RC-12)', () {
      final violations = <String>[];
      for (final file in dartFiles) {
        for (final line in file.readAsLinesSync()) {
          final trimmed = line.trim();
          if (trimmed.startsWith('//')) {
            continue;
          }
          if (RegExp(r'\bassert\(').hasMatch(trimmed)) {
            violations.add('${file.path}: $trimmed');
          }
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('aucun `print(` ni `debugPrint(` hors du port de journalisation (RC-14)', () {
      final violations = <String>[];
      for (final file in dartFiles) {
        if (file.path.endsWith('logging/debug_logger.dart')) {
          continue;
        }
        for (final line in file.readAsLinesSync()) {
          final trimmed = line.trim();
          if (trimmed.startsWith('//')) {
            continue;
          }
          if (trimmed.contains('print(')) {
            violations.add('${file.path}: $trimmed');
          }
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });

    test('aucun état global mutable : pas de `static var` ni `static late`', () {
      final violations = <String>[];
      for (final file in dartFiles) {
        for (final line in file.readAsLinesSync()) {
          if (RegExp(r'static\s+(var|late)\s').hasMatch(line)) {
            violations.add('${file.path}: ${line.trim()}');
          }
        }
      }
      expect(violations, isEmpty, reason: violations.join('\n'));
    });
  });

  group('Absence de code mort (ANO-16)', () {
    test('le point d\'entrée est unique', () {
      final mains = dartFiles
          .where((file) => file.readAsLinesSync().any(
                (line) => line.trim() == 'Future<void> main() async {',
              ))
          .toList();
      expect(mains, hasLength(1));
    });
  });
}
