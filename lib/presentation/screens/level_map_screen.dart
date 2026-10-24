import 'dart:async';

import 'package:flutter/material.dart';

import '../../application/load_level_map.dart';
import '../../domain/entities/quiz_theme.dart';
import '../../domain/values/level_number.dart';
import '../app_dependencies.dart';
import '../app_strings.dart';
import '../error_code.dart';
import '../widgets/async_view.dart';
import '../widgets/cycling_background.dart';
import '../widgets/level_list.dart';
import 'quiz_screen.dart';

/// Écran 2 — carte des niveaux d'un thème (REQ-060, REQ-062, REQ-065).
class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({required this.deps, required this.theme, super.key});

  final AppDependencies deps;
  final QuizTheme theme;

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  ScreenState<LevelMapView> _state = const ScreenLoading<LevelMapView>();

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    setState(() => _state = const ScreenLoading<LevelMapView>());
    try {
      final view = await widget.deps.loadLevelMap(widget.theme.id);
      if (!mounted) {
        return;
      }
      setState(() => _state = ScreenReady<LevelMapView>(view));
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      setState(() => _state = ScreenFailure<LevelMapView>(errorCodeOf(error)));
    }
  }


  Future<void> _openLevel(LevelNumber level) async {
    final current = _state;
    if (current is! ScreenReady<LevelMapView>) {
      return;
    }
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => QuizScreen(
          deps: widget.deps,
          theme: widget.theme,
          level: level.value,
          catalog: current.data.catalog,
        ),
      ),
    );
    if (mounted) {
      await _load();
    }
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.resetProgressTitle),
        content: Text(
          AppStrings.resetProgressBody.replaceFirst('%s', widget.theme.label),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(AppStrings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text(AppStrings.reset),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    try {
      await widget.deps.resetLevelProgress(widget.theme.id);
    } on Object catch (error) {
      if (mounted) {
        setState(() => _state = ScreenFailure<LevelMapView>(errorCodeOf(error)));
      }
      return;
    }
    if (mounted) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final ready = _state is ScreenReady<LevelMapView>;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.theme.label),
        actions: <Widget>[
          IconButton(
            tooltip: AppStrings.resetProgressTooltip,
            onPressed: ready ? _confirmReset : null,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: AppBackground(
        child: Column(
          children: <Widget>[
            _Header(theme: widget.theme, state: _state),
            Expanded(
              child: AsyncView<LevelMapView>(
                state: _state,
                onRetry: _load,
                builder: (context, view) => LevelList(
                  levels: view.catalog.levels.map((level) => level.value).toList(),
                  unlocked: view.unlocked.map((level) => level.value).toSet(),
                  onSelect: (value) => _openLevel(LevelNumber.parse(value)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.theme, required this.state});

  final QuizTheme theme;
  final ScreenState<LevelMapView> state;

  @override
  Widget build(BuildContext context) {
    final view = state is ScreenReady<LevelMapView>
        ? (state as ScreenReady<LevelMapView>).data
        : null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
      child: Column(
        children: <Widget>[
          const Icon(Icons.school_outlined, color: Colors.white, size: 50),
          const SizedBox(height: 8),
          Text(
            AppStrings.levelMapInstruction.replaceFirst('%s', theme.label),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          if (view != null) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              AppStrings.levelCount
                  .replaceFirst('%d', '${view.unlockedCount}')
                  .replaceFirst('%d', '${view.catalog.length}'),
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ],
      ),
    );
  }
}
