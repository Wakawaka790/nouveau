import 'package:quiz_game7/models/question.dart';

/// Counts correct answers. A timed-out or unanswered question earns no point.
int calculateQuizScore(List<Question> questions, List<String?> answers) {
  var score = 0;
  for (var index = 0; index < questions.length && index < answers.length; index++) {
    if (answers[index] == questions[index].correctAnswer) score++;
  }
  return score;
}

double calculateQuizAccuracy(List<Question> questions, List<String?> answers) {
  if (questions.isEmpty) return 0;
  return calculateQuizScore(questions, answers) / questions.length;
} 
