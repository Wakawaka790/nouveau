import 'dart:async';

import 'package:flutter/material.dart';

import '../../domain/entities/level_catalog.dart';
import '../../domain/entities/quiz_theme.dart';
import '../../domain/errors/domain_errors.dart';
import '../../domain/session/quiz_session.dart';
import '../../domain/values/level_number.dart';
import '../app_dependencies.dart';
import '../app_strings.dart';
import '../error_code.dart';
import '../widgets/cycling_background.dart';
import '../widgets/quiz_body.dart';
import 'result_screen.dart';

/// Écran 3 — session de quiz.
///
/// L'écran ne contient **aucune règle** : il interroge la machine à états du
/// domaine et rafraîchit l'affichage. Le chronomètre est une **échéance
/// absolue** (REQ-034) : une mise en arrière-plan ne permet donc pas de gagner
/// du temps (REQ-037).
class QuizScreen extends StatefulWidget {
  const QuizScreen({
    required this.deps,
    required this.theme,
    required this.level,
    required this.catalog,
    super.key,
  });

  final AppDependencies deps;
  final QuizTheme theme;
  final int level;
  final LevelCatalog catalog;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with WidgetsBindingObserver {
  static const Duration _tick = Duration(milliseconds: 200);

  QuizSession? _session;
  String? _errorCode;
  bool _isLoading = true;
  bool _isFinishing = false;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_load());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Le temps s'écoule réellement : au retour, on réévalue l'échéance (REQ-037).
    if (state == AppLifecycleState.resumed && mounted) {
      _onTick();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _errorCode = null;
      _isFinishing = false;
    });
    try {
      final session = await widget.deps.startQuizSession(
        theme: widget.theme.id,
        level: LevelNumber.parse(widget.level),
      );
      if (!mounted) return;
      setState(() {
        _session = session;
        _isLoading = false;
      });
      _ticker?.cancel();
      _ticker = Timer.periodic(_tick, (_) => _onTick());
    } on Object catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorCode = errorCodeOf(error);
      });
    }
  }

  void _onTick() {
    final session = _session;
    if (session == null || _isFinishing) {
      return;
    }
    widget.deps.answerQuestion.expireIfDue(session);
    if (!mounted) {
      return;
    }
    setState(() {});
    if (session.isFinished) {
      unawaited(_finish());
    }
  }

  void _onAnswer(String option) {
    final session = _session;
    if (session == null || session.isFinished) {
      return;
    }
    try {
      widget.deps.answerQuestion(
        session,
        questionIndex: session.index,
        option: option,
      );
    } on DomainError catch (error) {
      setState(() => _errorCode = error.code);
      return;
    }
    setState(() {});
    if (session.isFinished) {
      unawaited(_finish());
    }
  }

  Future<void> _finish() async {
    if (_isFinishing) {
      return;
    }
    _isFinishing = true;
    _ticker?.cancel();
    final session = _session;
    if (session == null) return;
    final result = await widget.deps.finishQuizSession(
      session: session,
      theme: widget.theme.id,
      level: LevelNumber.parse(widget.level),
      catalog: widget.catalog,
    );
    if (!mounted) return;
    await Navigator.of(context).pushReplacement<void, void>(
      MaterialPageRoute<void>(
        builder: (_) => ResultScreen(
          theme: widget.theme,
          level: widget.level,
          questions: session.questions,
          answers: session.answers,
          result: result,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.quizTitle
                .replaceFirst('%s', widget.theme.label)
                .replaceFirst('%d', '${widget.level}'),
          ),
        ),
        body: AppBackground(child: _buildBody()),
      );

  Widget _buildBody() => QuizBody(
        isLoading: _isLoading,
        errorCode: _errorCode,
        session: _session,
        clock: widget.deps.clock,
        onAnswer: _onAnswer,
        onRetry: _load,
      );
}
