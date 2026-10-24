import 'package:flutter/material.dart';
import 'package:quiz_game7/services/profile_functions.dart';
import 'package:quiz_game7/widgets/animated_background.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({super.key});

  @override
  State<ScoresScreen> createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  int _totalScore = 0;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadScore();
  }

  Future<void> _loadScore() async {
    try {
      final total = await ProfileManager.getTotalScore();
      if (!mounted) return;
      setState(() {
        _totalScore = total;
        _isLoading = false;
        _errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _resetScore() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Effacer le score ?'),
        content: const Text('Cette action remettra votre score total à zéro.'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    try {
      await ProfileManager.resetScore();
      await _loadScore();
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Impossible de réinitialiser le score : $error';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tous les scores')),
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : _errorMessage != null
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Impossible de charger le score : $_errorMessage',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.amber,
                              size: 72,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Votre score total',
                              style: TextStyle(color: Colors.white, fontSize: 20),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$_totalScore points',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 34,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (_totalScore > 0) ...<Widget>[
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                onPressed: _resetScore,
                                icon: const Icon(Icons.delete_outline),
                                label: const Text('Réinitialiser le score'),
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
}
