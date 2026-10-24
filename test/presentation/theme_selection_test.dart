import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/app.dart';
import 'package:quiz_game/presentation/app_dependencies.dart';
import 'package:quiz_game/presentation/screens/level_map_screen.dart';

import '../support/fakes.dart';

void main() {
  AppDependencies deps() => AppDependencies.create(
        store: InMemoryStore(),
        reader: FakeAssetReader(<String, String>{
          'assets/questions/arabe/levels.json': '{"Levels":[1,2]}',
          'assets/questions/arabe/level_1.json': levelJson(2),
          'assets/questions/arabe/level_2.json': levelJson(2),
        }),
        clock: FakeClock(),
        random: FakeRandom(),
        logger: RecordingLogger(),
      );

  testWidgets('affiche les 8 thèmes (REQ-061)', (tester) async {
    await tester.pumpWidget(QuizApp(deps: deps()));
    await tester.pump();

    for (final label in <String>[
      'Arabe',
      'Sira',
      'Coran',
      'Histoire',
      'Sahaba',
      'Hijra',
      'Termes',
      'Général',
    ]) {
      expect(find.text(label), findsOneWidget, reason: 'thème $label');
    }
  });

  testWidgets('ouvre la carte des niveaux et verrouille le niveau 2 (REQ-062)',
      (tester) async {
    await tester.pumpWidget(QuizApp(deps: deps()));
    await tester.pump();

    await tester.tap(find.text('Arabe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(LevelMapScreen), findsOneWidget);
    expect(find.text('1 / 2 niveaux débloqués'), findsOneWidget);
    expect(find.text('Niveau 1'), findsOneWidget);
    expect(find.text('Niveau 2'), findsOneWidget);
    expect(find.text('Terminez le niveau précédent'), findsOneWidget);
  });

  testWidgets('affiche un échec lisible quand le contenu est absent (REQ-060)',
      (tester) async {
    final broken = AppDependencies.create(
      store: InMemoryStore(),
      reader: FakeAssetReader(<String, String>{}),
      clock: FakeClock(),
      random: FakeRandom(),
      logger: RecordingLogger(),
    );
    await tester.pumpWidget(QuizApp(deps: broken));
    await tester.pump();
    await tester.tap(find.text('Arabe'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Le contenu de ce thème est introuvable.'), findsOneWidget);
    expect(find.text('Réessayer'), findsOneWidget);
  });
}
