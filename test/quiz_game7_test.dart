// Tests unitaires ajoutés lors de la correction du projet.
// Ils couvrent la logique pure (modèles et calcul du score), testable
// sans lancer l'application : « flutter test ».

import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game7/models/question.dart';
import 'package:quiz_game7/models/user_profile.dart';
import 'package:quiz_game7/services/quiz_scoring.dart';

void main() {
  group('Question', () {
    test('fromJson mélange les options sans perdre la bonne réponse', () {
      final question = Question.fromJson(<String, dynamic>{
        'question': 'Capitale de la France ?',
        'correct': 'Paris',
        'options': <String>['Paris', 'Lyon', 'Nice'],
      });

      expect(question.question, 'Capitale de la France ?');
      expect(question.correctAnswer, 'Paris');
      expect(question.options.toSet(), <String>{'Paris', 'Lyon', 'Nice'});
    });

    test('rejette une bonne réponse absente des options', () {
      expect(
        () => Question(
          question: 'Q ?',
          correctAnswer: 'X',
          options: <String>['A', 'B'],
        ),
        throwsArgumentError,
      );
    });

    test('rejette les options en double (après suppression des espaces)', () {
      expect(
        () => Question(
          question: 'Q ?',
          correctAnswer: 'A',
          options: <String>['A', ' A '],
        ),
        throwsArgumentError,
      );
    });

    test('rejette un JSON sans question', () {
      expect(
        () => Question.fromJson(<String, dynamic>{
          'correct': 'A',
          'options': <String>['A', 'B'],
        }),
        throwsFormatException,
      );
    });
  });

  group('calculateQuizScore / calculateQuizAccuracy', () {
    final questions = <Question>[
      Question(
        question: 'Q1',
        correctAnswer: 'A',
        options: <String>['A', 'B'],
      ),
      Question(
        question: 'Q2',
        correctAnswer: 'B',
        options: <String>['A', 'B'],
      ),
    ];

    test('une question sans réponse (temps écoulé) ne rapporte rien', () {
      expect(calculateQuizScore(questions, <String?>['A', null]), 1);
    });

    test('la précision vaut 1 quand tout est juste, 0 sans question', () {
      expect(calculateQuizAccuracy(questions, <String?>['A', 'B']), 1.0);
      expect(calculateQuizAccuracy(const <Question>[], const <String?>[]), 0);
    });
  });

  group('UserProfile', () {
    test('fromJson tolère les valeurs absentes ou invalides', () {
      final profile = UserProfile.fromJson(<String, dynamic>{'score': '-5'});

      expect(profile.name, '');
      expect(profile.avatar, '🙂');
      expect(profile.score, 0);
    });

    test('aller-retour toJson/fromJson', () {
      final profile = UserProfile(name: 'Lina', avatar: '🦊', score: 12);
      final restored = UserProfile.fromJson(profile.toJson());

      expect(restored, profile);
      expect(restored.score, 12);
    });
  });
}
