import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/domain/entities/question.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/session/quiz_session.dart';

import '../support/fakes.dart';

void main() {
  const duration = Duration(seconds: 10);
  const durationMs = 10000;

  final questions = <Question>[question('Q0'), question('Q1'), question('Q2')];

  QuizSession start({int nowMs = 0, List<Question>? content}) =>
      QuizSession.start(
        questions: content ?? questions,
        perQuestion: duration,
        nowMs: nowMs,
      );

  group('Création (REQ-030)', () {
    test('refuse une liste vide', () {
      expect(
        () => QuizSession.start(
          questions: const <Question>[],
          perQuestion: duration,
          nowMs: 0,
        ),
        throwsA(isA<InvalidSessionError>()),
      );
    });

    test('refuse une durée nulle ou négative, même hors mode debug', () {
      for (final value in <Duration>[Duration.zero, const Duration(seconds: -1)]) {
        expect(
          () => QuizSession.start(
            questions: questions,
            perQuestion: value,
            nowMs: 0,
          ),
          throwsA(isA<InvalidDurationError>()),
        );
      }
    });

    test('initialise un état conforme', () {
      final session = start();
      expect(session.index, 0);
      expect(session.answers, <String?>[null, null, null]);
      expect(session.isFinished, isFalse);
      expect(session.status, isA<SessionAnswering>());
    });
  });

  group('Séquencement (REQ-031, REQ-033)', () {
    test('progresse d\'une question à l\'autre et se termine', () {
      final session = start();
      session.answer(questionIndex: 0, option: 'B', nowMs: 1000);
      expect(session.index, 1);
      session.answer(questionIndex: 1, option: 'A', nowMs: 2000);
      expect(session.index, 2);
      session.answer(questionIndex: 2, option: 'B', nowMs: 3000);
      expect(session.isFinished, isTrue);
      expect(session.index, 3);
    });

    test('ignore une réponse en retard (double appui)', () {
      final session = start();
      session.answer(questionIndex: 0, option: 'B', nowMs: 0);
      session.answer(questionIndex: 0, option: 'A', nowMs: 10);
      expect(session.answers.first, 'B');
      expect(session.index, 1);
    });

    test('une réponse n\'est jamais modifiée une fois enregistrée', () {
      final session = start();
      session.answer(questionIndex: 0, option: 'B', nowMs: 0);
      session.answer(questionIndex: 1, option: 'B', nowMs: 0);
      expect(session.answers.sublist(0, 2), <String?>['B', 'B']);
    });

    test('refuse une option absente de la question (REQ-032)', () {
      final session = start();
      expect(
        () => session.answer(questionIndex: 0, option: 'Z', nowMs: 0),
        throwsA(isA<InvalidAnswerError>()),
      );
      expect(session.answers.first, isNull);
      expect(session.index, 0);
    });

    test('toute opération après la fin est sans effet (REQ-036)', () {
      final session = start(content: <Question>[question('Q0')]);
      session.answer(questionIndex: 0, option: 'B', nowMs: 0);
      expect(session.isFinished, isTrue);
      session.answer(questionIndex: 0, option: 'A', nowMs: 0);
      expect(session.expireIfDue(999999), isFalse);
      expect(session.answers, <String?>['B']);
    });
  });

  group('Chronomètre — échéance absolue (REQ-034, REQ-037)', () {
    test('le temps restant décroît avec l\'horloge, pas avec les ticks', () {
      final session = start(nowMs: 1000);
      expect(session.remainingMs(1000), durationMs);
      expect(session.remainingMs(4000), 7000);
      expect(session.remainingMs(11000), 0);
    });

    test('le temps restant est borné à la durée de la question', () {
      final session = start(nowMs: 5000);
      expect(session.remainingMs(0), durationMs);
    });

    test('expire à l\'échéance et enregistre une absence de réponse', () {
      final session = start();
      expect(session.expireIfDue(durationMs - 1), isFalse);
      expect(session.expireIfDue(durationMs), isTrue);
      expect(session.answers.first, isNull);
      expect(session.index, 1);
    });

    test('un long passage en arrière-plan ne permet pas de gagner du temps', () {
      final session = start(nowMs: 0);
      // 60 s d'absence : la question devait expirer depuis longtemps.
      expect(session.expireIfDue(60000), isTrue);
      expect(session.answers.first, isNull);
    });

    test('expiration de la dernière question : session terminée', () {
      final session = start(content: <Question>[question('Q0')]);
      expect(session.expireIfDue(durationMs), isTrue);
      expect(session.isFinished, isTrue);
    });

    test('chaque nouvelle question repart de la durée pleine', () {
      final session = start();
      session.answer(questionIndex: 0, option: 'B', nowMs: 1500);
      expect(session.remainingMs(1500), durationMs);
      expect(session.remainingMs(4500), 7000);
    });
  });

  group('Score courant (REQ-021)', () {
    test('compte les bonnes réponses déjà données', () {
      final session = start();
      expect(session.scoreSoFar, 0);
      session.answer(questionIndex: 0, option: 'B', nowMs: 0);
      expect(session.scoreSoFar, 1);
      session.answer(questionIndex: 1, option: 'A', nowMs: 0);
      expect(session.scoreSoFar, 1);
      expect(session.answeredCount, 2);
    });
  });
}
