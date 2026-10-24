import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/application/start_quiz_session.dart';
import 'package:quiz_game/domain/entities/level_catalog.dart';
import 'package:quiz_game/domain/entities/question.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/session/quiz_session.dart';
import 'package:quiz_game/domain/values/level_number.dart';
import 'package:quiz_game/domain/values/theme_id.dart';

import '../support/fakes.dart';
import '../support/repository_fakes.dart';

/// TC-APP-07, TC-APP-08 — démarrage de session (REQ-004, REQ-007, REQ-030).
void main() {
  final arabe = ThemeId.parse('arabe');
  final level1 = LevelNumber.parse(1);

  StartQuizSession build({
    List<int>? randomSequence,
    List<Question>? questions,
    Object? error,
    int nowMs = 0,
    Duration perQuestion = const Duration(seconds: 10),
  }) {
    final repository = FakeQuestionRepository(
      catalog: LevelCatalog.create(
        theme: arabe,
        levels: <LevelNumber>[level1],
      ),
      questions: questions ??
          <Question>[
            question(
              'Capitale du Maroc ?',
              correct: 'Rabat',
              options: <String>['Rabat', 'Fès', 'Tanger'],
            ),
            question('Deuxième ?', correct: 'B', options: <String>['A', 'B']),
          ],
      error: error,
    );
    final clock = FakeClock()..current = nowMs;
    return StartQuizSession(
      questions: repository,
      random: FakeRandom(randomSequence),
      clock: clock,
      perQuestion: perQuestion,
    );
  }

  test('charge les questions du thème et du niveau demandés', () async {
    final session = await build().call(theme: arabe, level: level1);
    expect(session.questions, hasLength(2));
    expect(session.index, 0);
    expect(session.isFinished, isFalse);
  });

  test('la première échéance est « maintenant + durée » (REQ-034)', () async {
    final session = await build(nowMs: 5000).call(theme: arabe, level: level1);
    expect(session.remainingMs(5000), 10000);
    expect(session.remainingMs(15000), 0);
  });

  test('le mélange ne perd ni n\'invente aucune option (REQ-007)', () async {
    final session = await build().call(theme: arabe, level: level1);
    for (final current in session.questions) {
      final origin = current.text == 'Capitale du Maroc ?'
          ? <String>['Rabat', 'Fès', 'Tanger']
          : <String>['A', 'B'];
      expect(current.options.toSet(), origin.toSet());
      expect(current.options, hasLength(origin.length));
    }
  });

  test('le mélange conserve la bonne réponse (REQ-007)', () async {
    final session = await build(randomSequence: <int>[2, 0])
        .call(theme: arabe, level: level1);
    for (final current in session.questions) {
      expect(current.options, contains(current.correctAnswer));
    }
  });

  test('le mélange est déterministe pour une même graine (REQ-078)', () async {
    final first =
        await build(randomSequence: <int>[1]).call(theme: arabe, level: level1);
    final second =
        await build(randomSequence: <int>[1]).call(theme: arabe, level: level1);
    expect(
      first.questions.map((Question q) => q.options.join(',')).toList(),
      second.questions.map((Question q) => q.options.join(',')).toList(),
    );
  });

  test('propage l\'erreur de contenu du dépôt (REQ-050)', () async {
    await expectLater(
      build(error: ContentNotFoundError('sira/level_9.json'))
          .call(theme: arabe, level: level1),
      throwsA(isA<ContentNotFoundError>()),
    );
  });

  test('une erreur de contenu ne crée aucune session', () async {
    QuizSession? session;
    try {
      session = await build(
        error: ContentSchemaError('sira/level_1.json', 'champ correct absent'),
      )
          .call(theme: arabe, level: level1);
    } on ContentError {
      // attendu
    }
    expect(session, isNull);
  });
}
