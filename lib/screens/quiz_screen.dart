import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:quiz_game7/models/question.dart';
import 'package:quiz_game7/models/quiz_category.dart';
import 'package:quiz_game7/screens/score_screen.dart';
import 'package:quiz_game7/services/level_manager.dart';
import 'package:quiz_game7/services/profile_functions.dart';
import 'package:quiz_game7/services/question_loader.dart';
import 'package:quiz_game7/services/quiz_scoring.dart';
import 'package:quiz_game7/widgets/animated_background.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({
    super.key,
    required this.niveau,
    required this.quizType,
    required this.availableLevels,
    this.secondsPerQuestion = 10,
  }) : assert(secondsPerQuestion > 0);

  final int niveau;
  final String quizType;
  final List<int> availableLevels;
  final int secondsPerQuestion;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  // Corrigé : audioplayers et les sons « correct.mp3 » / « wrong.mp3 »
  // étaient déclarés dans pubspec.yaml mais jamais utilisés par le code.
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<Question> _questions = <Question>[];
  List<String?> _answers = <String?>[];
  int _currentIndex = 0;
  late int _timeLeft = widget.secondsPerQuestion;
  Timer? _timer;
  bool _isLoading = true;
  bool _isFinishing = false;
  String? _errorMessage;

  String get _title => quizCategoryForId(widget.quizType)?.label ?? widget.quizType;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadQuestions();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      if (!_isLoading && _errorMessage == null && _questions.isNotEmpty && !_isFinishing) {
        _startTimer(reset: false);
      }
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  Future<void> _loadQuestions() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final questions = await QuestionLoader.loadQuestions(
        widget.quizType,
        widget.niveau,
      );
      if (!mounted) return;
      setState(() {
        _questions = questions;
        _answers = List<String?>.filled(questions.length, null);
        _currentIndex = 0;
        _timeLeft = widget.secondsPerQuestion;
        _isLoading = false;
      });
      _startTimer();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  void _startTimer({bool reset = true}) {
    _timer?.cancel();
    if (reset) _timeLeft = widget.secondsPerQuestion;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _isFinishing) return;
      if (_timeLeft <= 1) {
        _timer?.cancel();
        setState(() => _timeLeft = 0);
        _submitAnswer(null);
      } else {
        setState(() => _timeLeft--);
      }
    });
  }

  Future<void> _playFeedbackSound(bool isCorrect) async {
    try {
      await _audioPlayer.play(
        AssetSource(isCorrect ? 'sounds/correct.mp3' : 'sounds/wrong.mp3'),
      );
    } catch (error) {
      // Le son n'est qu'un retour optionnel : un fichier absent ou
      // illisible ne doit jamais interrompre le quiz.
      debugPrint('Son de retour non joué : $error');
    }
  }

  void _submitAnswer(String? answer) {
    if (_isFinishing || _isLoading || _questions.isEmpty) return;
    _timer?.cancel();

    // Temps écoulé (answer == null) compte comme une mauvaise réponse.
    final isCorrect =
        answer != null && answer == _questions[_currentIndex].correctAnswer;
    unawaited(_playFeedbackSound(isCorrect));

    final isLastQuestion = _currentIndex == _questions.length - 1;
    setState(() {
      _answers[_currentIndex] = answer;
      if (isLastQuestion) {
        _isFinishing = true;
      } else {
        _currentIndex++;
        _timeLeft = widget.secondsPerQuestion;
      }
    });

    if (isLastQuestion) {
      unawaited(_finishQuiz());
    } else {
      _startTimer();
    }
  }

  Future<void> _finishQuiz() async {
    final score = calculateQuizScore(_questions, _answers);
    int? unlockedNextLevel;
    final persistenceErrors = <String>[];

    try {
      await ProfileManager.updateScore(score);
    } catch (error) {
      persistenceErrors.add('Le score n’a pas pu être enregistré : $error');
    }
    try {
      unlockedNextLevel = await LevelManager.unlockNextLevel(
        widget.niveau,
        widget.quizType,
        availableLevels: widget.availableLevels,
      );
    } catch (error) {
      persistenceErrors.add('La progression n’a pas pu être enregistrée : $error');
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement<void, bool>(
      MaterialPageRoute<void>(
        builder: (_) => ScoreScreen(
          quizType: widget.quizType,
          niveau: widget.niveau,
          questions: List<Question>.unmodifiable(_questions),
          answers: List<String?>.unmodifiable(_answers),
          unlockedNextLevel: unlockedNextLevel,
          persistenceError: persistenceErrors.isEmpty
              ? null
              : persistenceErrors.join('\n'),
        ),
      ),
      result: true,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    unawaited(_audioPlayer.dispose());
    super.dispose();
  }

  Widget _buildMessage(String message, {required bool isError}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              isError ? Icons.error_outline : Icons.hourglass_top,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            if (isError) ...<Widget>[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: _loadQuestions,
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuiz() {
    final question = _questions[_currentIndex];
    final quizProgress = (_currentIndex + 1) / _questions.length;
    final timeProgress = _timeLeft / widget.secondsPerQuestion;
    final currentScore = calculateQuizScore(_questions, _answers);

    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            children: <Widget>[
              Text(
                'Question ${_currentIndex + 1} sur ${_questions.length}',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 6),
              LinearProgressIndicator(value: quizProgress),
              const SizedBox(height: 14),
              Row(
                children: <Widget>[
                  const Icon(Icons.emoji_events_outlined, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    'Score : $currentScore',
                    style: const TextStyle(color: Colors.white),
                  ),
                  const Spacer(),
                  Text(
                    '$_timeLeft s',
                    style: TextStyle(
                      color: _timeLeft <= 3 ? Colors.redAccent : Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Semantics(
                label: 'Temps restant',
                child: LinearProgressIndicator(
                  value: timeProgress.clamp(0.0, 1.0).toDouble(),
                  color: _timeLeft <= 3 ? Colors.redAccent : Colors.lightGreenAccent,
                  backgroundColor: Colors.white24,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Card(
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      question.question,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                for (final option in question.options) ...<Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: ElevatedButton(
                      onPressed: _isFinishing ? null : () => _submitAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF34266D),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                      child: Text(option, textAlign: TextAlign.center),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final body = _isLoading
        ? const Center(child: CircularProgressIndicator(color: Colors.white))
        : _errorMessage != null
            ? _buildMessage(_errorMessage!, isError: true)
            : _questions.isEmpty
                ? _buildMessage('Aucune question n’est disponible pour ce niveau.', isError: true)
                : _buildQuiz();

    return Scaffold(
      appBar: AppBar(title: Text('$_title — niveau ${widget.niveau}')),
      body: AnimatedBackground(
        child: SafeArea(child: body),
      ),
    );
  }
}
