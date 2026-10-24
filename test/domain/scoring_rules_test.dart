import 'package:flutter_test/flutter_test.dart';
import 'package:quiz_game/domain/entities/question.dart';
import 'package:quiz_game/domain/rules/scoring_rules.dart';

import '../support/fakes.dart';

void main() {
  final questions = <Question>[
    question('Q0'),
    question('Q1'),
    question('Q2'),
  ];

  group('ScoringRules (REQ-021, REQ-024)', () {
    test('score nul quand aucune réponse', () {
      final result = ScoringRules.compute(questions, <String?>[null, null, null]);
      expect(result.score, 0);
      expect(result.total, 3);
      expect(result.accuracy, 0);
      expect(result.hasLengthMismatch, isFalse);
    });

    test('score maximal quand toutes les réponses sont exactes', () {
      final result = ScoringRules.compute(
        questions,
        <String?>['B', 'B', 'B'],
      );
      expect(result.score, 3);
      expect(result.accuracy, 1);
    });

    test('score partiel et sensibilité à la casse', () {
      final result = ScoringRules.compute(
        questions,
        <String?>['B', 'b', 'A'],
      );
      expect(result.score, 1);
    });

    test('signale une incohérence de longueur sans masquer l\'écart (ANO-13)', () {
      final result = ScoringRules.compute(questions, <String?>['B', 'B']);
      expect(result.score, 2);
      expect(result.total, 3);
      expect(result.hasLengthMismatch, isTrue);
    });

    test('aucune division par zéro sur une liste vide', () {
      final result = ScoringRules.compute(const [], const <String?>[]);
      expect(result.accuracy, 0);
      expect(result.score, 0);
    });
  });
}
