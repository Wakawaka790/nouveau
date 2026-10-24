import 'package:flutter/material.dart';

import '../app_dependencies.dart';
import '../app_strings.dart';
import '../error_code.dart';
import '../widgets/async_view.dart';
import '../widgets/cycling_background.dart';

/// Écran 5 — score total (REQ-023, REQ-065).
class ScoresScreen extends StatefulWidget {
  const ScoresScreen({required this.deps, super.key});

  final AppDependencies deps;

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  ScreenState<int> _state = const ScreenLoading<int>();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _state = const ScreenLoading<int>());
    try {
      final score = await widget.deps.readTotalScore();
      if (!mounted) {
        return;
      }
      setState(() => _state = ScreenReady<int>(score));
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _state = ScreenFailure<int>(errorCodeOf(error)),
      );
    }
  }

  Future<void> _reset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.resetScoreTitle),
        content: const Text(AppStrings.resetScoreBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.erase),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await widget.deps.resetTotalScore();
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(
        () => _state = ScreenFailure<int>(errorCodeOf(error)),
      );
      return;
    }
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(AppStrings.scoresTitle)),
        body: AppBackground(
          child: AsyncView<int>(
            state: _state,
            onRetry: _load,
            builder: (context, score) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.emoji_events, color: Colors.amber, size: 72),
                    const SizedBox(height: 12),
                    const Text(
                      AppStrings.scoresTitle,
                      style: TextStyle(color: Colors.white, fontSize: 20),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      AppStrings.scoresPoints.replaceFirst('%d', '$score'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (score > 0) ...<Widget>[
                      const SizedBox(height: 20),
                      OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.delete_outline),
                        label: const Text(AppStrings.resetScoreLabel),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
