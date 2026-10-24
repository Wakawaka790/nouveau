import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/domain/entities/question.dart';
import 'package:quiz_game/domain/session/quiz_session.dart';
import 'package:quiz_game/presentation/widgets/quiz_board.dart';

import '../support/fakes.dart';

void main() {
  final questions = <Question>[question('Capitale du Maroc ?')];

  QuizSession session() => QuizSession.start(
        questions: questions,
        perQuestion: const Duration(seconds: 10),
        nowMs: 0,
      );

  testWidgets('affiche l\'énoncé, les options et le compteur (REQ-063)',
      (tester) async {
    final clock = FakeClock();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuizBoard(
            session: session(),
            clock: clock,
            onAnswer: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('Capitale du Maroc ?'), findsOneWidget);
    expect(find.text('Question 1 sur 1'), findsOneWidget);
    expect(find.text('10 s'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('notifie la réponse choisie', (tester) async {
    String? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuizBoard(
            session: session(),
            clock: FakeClock(),
            onAnswer: (option) => received = option,
          ),
        ),
      ),
    );

    await tester.tap(find.text('B'));
    expect(received, 'B');
  });

  testWidgets('le temps affiché suit l\'horloge, pas les rafraîchissements',
      (tester) async {
    final clock = FakeClock();
    final current = session();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: QuizBoard(session: current, clock: clock, onAnswer: (_) {}),
        ),
      ),
    );

    clock.advance(const Duration(seconds: 4));
    await tester.pump();

    expect(find.text('6 s'), findsOneWidget);
  });
}
