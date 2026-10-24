import 'package:flutter/material.dart';
import 'package:quiz_game7/models/quiz_category.dart';
import 'package:quiz_game7/screens/quiz_screen.dart';
import 'package:quiz_game7/services/level_manager.dart';
import 'package:quiz_game7/services/question_loader.dart';
import 'package:quiz_game7/widgets/animated_background.dart';

class LevelMapScreen extends StatefulWidget {
  const LevelMapScreen({super.key, required this.quizType});

  final String quizType;

  @override
  State<LevelMapScreen> createState() => _LevelMapScreenState();
}

class _LevelMapScreenState extends State<LevelMapScreen> {
  List<int> _availableLevels = <int>[];
  Set<int> _unlockedLevels = <int>{1};
  bool _isLoading = true;
  String? _errorMessage;

  String get _title => quizCategoryForId(widget.quizType)?.label ?? widget.quizType;

  @override
  void initState() {
    super.initState();
    _loadLevels();
  }

  Future<void> _loadLevels() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final available = await QuestionLoader.loadAvailableLevels(widget.quizType);
      if (available.isNotEmpty) {
        await LevelManager.initializeLevelsForQuiz(
          widget.quizType,
          totalLevels: available.last,
        );
      }
      final unlockedStrings = await LevelManager.getUnlockedLevels(widget.quizType);
      if (!mounted) return;
      setState(() {
        _availableLevels = available;
        _unlockedLevels = unlockedStrings.map(int.parse).toSet();
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _startLevel(int level) async {
    final completed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => QuizScreen(
          niveau: level,
          quizType: widget.quizType,
          availableLevels: List<int>.unmodifiable(_availableLevels),
        ),
      ),
    );
    if (completed == true) await _loadLevels();
  }

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser la progression ?'),
        content: Text('Les niveaux débloqués pour « $_title » seront remis à zéro.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Réinitialiser'),
          ), 
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await LevelManager.resetLevels(
        widget.quizType,
        totalLevels: _availableLevels.last,
      );
      await _loadLevels();
    } catch (error) {
      if (!mounted) return;
      setState(() => _errorMessage = error.toString());
    }
  }

  Widget _buildLevelList() {
    if (_isLoading) {
      return const Expanded(
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_errorMessage != null) {
      return Expanded(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(Icons.error_outline, color: Colors.white, size: 48),
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _loadLevels,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_availableLevels.isEmpty) {
      return const Expanded(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(Icons.inbox_outlined, color: Colors.white, size: 52),
                SizedBox(height: 12),
                Text(
                  'Aucun niveau n’est encore configuré pour ce thème.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'Ajoutez des numéros dans le fichier levels.json pour activer le quiz.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: _availableLevels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final level = _availableLevels[index];
          final isUnlocked = _unlockedLevels.contains(level);
          return Card(
            color: isUnlocked ? Colors.white : Colors.white.withOpacity(0.82), 
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isUnlocked ? const Color(0xFF493A8C) : Colors.grey,
                child: Icon(
                  isUnlocked ? Icons.lock_open : Icons.lock_outline,
                  color: Colors.white,
                ),
              ),
              title: Text(
                'Niveau $level',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(isUnlocked ? 'Touchez pour jouer' : 'Terminez le niveau précédent'),
              trailing: Icon(isUnlocked ? Icons.play_arrow : Icons.lock),
              enabled: isUnlocked,
              onTap: isUnlocked ? () => _startLevel(level) : null,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        actions: <Widget>[
          IconButton(
            tooltip: 'Réinitialiser la progression',
            onPressed: _isLoading || _availableLevels.isEmpty ? null : _confirmReset,
            icon: const Icon(Icons.restart_alt),
          ),
        ],
      ),
      body: AnimatedBackground(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
                child: Column(
                  children: <Widget>[
                    const Icon(Icons.school_outlined, color: Colors.white, size: 50),
                    const SizedBox(height: 8),
                    Text(
                      'Choisissez un niveau pour le thème « $_title ».',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    if (_availableLevels.isNotEmpty) ...<Widget>[
                      const SizedBox(height: 8),
                      Text(
                        '${_unlockedLevels.intersection(_availableLevels.toSet()).length} / ${_availableLevels.length} niveaux débloqués',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ],
                ),
              ),
              _buildLevelList(),
            ],
          ),
        ),
      ),
    );
  }
} 
