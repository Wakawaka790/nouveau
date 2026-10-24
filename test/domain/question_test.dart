import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/domain/entities/question.dart';
import 'package:quiz_game/domain/errors/domain_errors.dart';

void main() {
  group('Question — invariants REQ-005', () {
    test('accepte une question valide à 2 options (borne basse)', () {
      final built = Question.create(
        text: '  Capitale ?  ',
        correctAnswer: ' Rabat ',
        options: <String>['Rabat', 'Fès'],
      );
      expect(built.text, 'Capitale ?');
      expect(built.correctAnswer, 'Rabat');
      expect(built.options, <String>['Rabat', 'Fès']);
    });

    test('refuse une question avec une seule option', () {
      expect(
        () => Question.create(
          text: 'Q',
          correctAnswer: 'A',
          options: <String>['A'],
        ),
        throwsA(isA<InvalidQuestionError>()),
      );
    });

    test('refuse un énoncé vide ou constitué d\'espaces', () {
      for (final text in <String>['', '   ']) {
        expect(
          () => Question.create(
            text: text,
            correctAnswer: 'A',
            options: <String>['A', 'B'],
          ),
          throwsA(isA<InvalidQuestionError>()),
        );
      }
    });

    test('refuse une bonne réponse vide', () {
      expect(
        () => Question.create(
          text: 'Q',
          correctAnswer: ' ',
          options: <String>['A', 'B'],
        ),
        throwsA(isA<InvalidQuestionError>()),
      );
    });

    test('refuse une option vide', () {
      expect(
        () => Question.create(
          text: 'Q',
          correctAnswer: 'A',
          options: <String>['A', ' '],
        ),
        throwsA(isA<InvalidQuestionError>()),
      );
    });

    test('refuse une option dupliquée', () {
      expect(
        () => Question.create(
          text: 'Q',
          correctAnswer: 'A',
          options: <String>['A', 'B', ' A '],
        ),
        throwsA(isA<InvalidQuestionError>()),
      );
    });

    test('refuse une bonne réponse absente des options', () {
      expect(
        () => Question.create(
          text: 'Q',
          correctAnswer: 'Z',
          options: <String>['A', 'B'],
        ),
        throwsA(isA<InvalidQuestionError>()),
      );
    });

    test('le message d\'erreur indique l\'index base 1', () {
      try {
        Question.create(
          text: 'Q',
          correctAnswer: 'Z',
          options: <String>['A', 'B'],
          index: 4,
        );
        fail('une erreur était attendue');
      } on InvalidQuestionError catch (error) {
        expect(error.detail, contains('question 5'));
      }
    });

    test('les options ne sont pas modifiables', () {
      final built = Question.create(
        text: 'Q',
        correctAnswer: 'A',
        options: <String>['A', 'B'],
      );
      expect(() => built.options.add('C'), throwsUnsupportedError);
    });
  });

  group('Question — comparaison (REQ-021)', () {
    final built = Question.create(
      text: 'Q',
      correctAnswer: 'Rabat',
      options: <String>['Rabat', 'Fès'],
    );

    test('comparaison stricte de la valeur', () {
      expect(built.isCorrect('Rabat'), isTrue);
      expect(built.isCorrect('rabat'), isFalse);
      expect(built.isCorrect('Rabat '), isFalse);
      expect(built.isCorrect(null), isFalse);
    });

    test('accepts() limite aux options proposées (REQ-032)', () {
      expect(built.accepts('Fès'), isTrue);
      expect(built.accepts('Tanger'), isFalse);
    });
  });
}
