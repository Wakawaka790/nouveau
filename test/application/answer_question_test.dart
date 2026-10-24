import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/application/answer_question.dart';
import 'package:quiz_game/domain/entities/question.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';
import 'package:quiz_game/domain/session/quiz_session.dart';

import '../support/fakes.dart';

/// TC-APP-09, TC-APP-10 — réponse et expiration (REQ-032 à REQ-037).
void main() {
  QuizSession sessionWithTwoQuestions() => QuizSession.start(
        questions: <Question>[
          question('Q1', correct: 'B'),
          question('Q2', correct: 'B'),
        ],
        perQuestion: const Duration(seconds: 10),
        nowMs: 0,
      );

  test('une réponse valide est enregistrée et avance la question', () {
    final clock = FakeClock();
    final session = sessionWithTwoQuestions();
    final outcome = AnswerQuestion(clock: clock).call(
      session,
      questionIndex: 0,
      option: 'B',
    );
    expect(outcome, AnswerOutcome.accepted);
    expect(session.answers.first, 'B');
    expect(session.index, 1);
  });

  test('une réponse sur une question périmée est ignorée (REQ-033)', () {
    final clock = FakeClock();
    final session = sessionWithTwoQuestions();
    final useCase = AnswerQuestion(clock: clock);
    useCase.call(session, questionIndex: 0, option: 'B');
    final outcome = useCase.call(session, questionIndex: 0, option: 'A');
    expect(outcome, AnswerOutcome.ignoredStale);
    expect(session.answers.first, 'B', reason: 'la réponse initiale prime');
    expect(session.index, 1);
  });

  test('une option hors liste lève InvalidAnswerError (REQ-032)', () {
    final session = sessionWithTwoQuestions();
    expect(
      () => AnswerQuestion(clock: FakeClock())
          .call(session, questionIndex: 0, option: 'Z'),
      throwsA(isA<InvalidAnswerError>()),
    );
    expect(session.index, 0, reason: 'aucun effet sur la session');
  });

  test('expireIfDue est faux avant l\'échéance (REQ-035)', () {
    final clock = FakeClock();
    final session = sessionWithTwoQuestions();
    expect(AnswerQuestion(clock: clock).expireIfDue(session), isFalse);
    expect(session.index, 0);
  });

  test('expireIfDue enregistre une non-réponse à l\'échéance (REQ-035)', () {
    final clock = FakeClock();
    final session = sessionWithTwoQuestions();
    clock.advance(const Duration(seconds: 10));
    expect(AnswerQuestion(clock: clock).expireIfDue(session), isTrue);
    expect(session.answers.first, isNull);
    expect(session.index, 1);
    expect(session.scoreSoFar, 0);
  });

  test('les expirations enchaînées terminent la session', () {
    final clock = FakeClock();
    final session = sessionWithTwoQuestions();
    final useCase = AnswerQuestion(clock: clock);
    clock.advance(const Duration(seconds: 10));
    expect(useCase.expireIfDue(session), isTrue);
    clock.advance(const Duration(seconds: 10));
    expect(useCase.expireIfDue(session), isTrue);
    clock.advance(const Duration(seconds: 10));
    expect(useCase.expireIfDue(session), isFalse, reason: 'session terminée');
    expect(session.isFinished, isTrue);
  });
}
