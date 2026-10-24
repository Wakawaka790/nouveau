import 'package:shared_preferences/shared_preferences.dart';

class LevelManager {
  static String _keyFor(String quizType) {
    final normalizedType = quizType.trim().toLowerCase();
    if (!RegExp(r'^[a-z0-9_-]+$').hasMatch(normalizedType)) {
      throw ArgumentError.value(quizType, 'quizType', 'identifiant invalide');
    }
    return 'levels__$normalizedType';
  }

  /// Starts a quiz with only its first level unlocked.
  static Future<void> initializeLevelsForQuiz(
    String quizType, {
    int totalLevels = 10,
  }) async {
    if (totalLevels < 1) {
      throw ArgumentError.value(totalLevels, 'totalLevels', 'doit être positif');
    }

    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(quizType);
    final hadCanonicalValue = prefs.containsKey(key);
    var stored = prefs.getStringList(key);

    // Preserve progress written by the older capitalized "Terme" category id.
    final trimmedType = quizType.trim();
    final titleCaseType = trimmedType.isEmpty
        ? trimmedType
        : '${trimmedType[0].toUpperCase()}${trimmedType.substring(1).toLowerCase()}';
    final legacyKeys = <String>{
      'levels__$trimmedType',
      'levels__$titleCaseType',
    };
    if (stored == null) {
      for (final legacyKey in legacyKeys) {
        if (legacyKey == key) continue;
        stored = prefs.getStringList(legacyKey);
        if (stored != null) {
          await prefs.remove(legacyKey);
          break;
        }
      }
    }

    final validLevels = <int>{};
    for (final value in stored ?? const <String>[]) {
      final parsed = int.tryParse(value);
      if (parsed != null && parsed >= 1 && parsed <= totalLevels) {
        validLevels.add(parsed);
      }
    }
    validLevels.add(1);
    final sorted = validLevels.toList()..sort();
    final normalized = sorted.map((level) => level.toString()).toList();
    if (!hadCanonicalValue || stored == null || stored.join(',') != normalized.join(',')) {
      await prefs.setStringList(key, normalized);
    }
  }

  /// Unlocks the next configured level after the current one is completed.
  /// Returns its number, or null when there is no next level to unlock.
  static Future<int?> unlockNextLevel(
    int completedLevel,
    String quizType, {
    required List<int> availableLevels,
  }) async {
    if (completedLevel < 1) return null;

    final levels = availableLevels.where((level) => level > 0).toSet().toList()
      ..sort();
    final currentIndex = levels.indexOf(completedLevel);
    if (currentIndex == -1 || currentIndex + 1 >= levels.length) return null;

    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(quizType);
    final unlocked = await getUnlockedLevels(quizType);
    if (!unlocked.contains(completedLevel.toString())) return null;

    final nextLevel = levels[currentIndex + 1];
    if (!unlocked.contains(nextLevel.toString())) {
      final updated = <int>{
        ...unlocked.map((value) => int.parse(value)),
        nextLevel,
      }.toList()
        ..sort();
      await prefs.setStringList(
        key,
        updated.map((level) => level.toString()).toList(),
      );
    }
    return nextLevel;
  }

  /// Returns a sorted list of unlocked level numbers as strings for compatibility
  /// with progress saved by earlier versions of the game.
  static Future<List<String>> getUnlockedLevels(String quizType) async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getStringList(_keyFor(quizType));
    final levels = <int>{};
    for (final value in stored ?? const <String>[]) {
      final parsed = int.tryParse(value);
      if (parsed != null && parsed > 0) levels.add(parsed);
    }
    if (levels.isEmpty) levels.add(1);
    final sorted = levels.toList()..sort();
    return sorted.map((level) => level.toString()).toList();
  }

  static Future<void> resetProgressForQuiz(String quizType) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _keyFor(quizType);
    await prefs.remove(key);
    final trimmedType = quizType.trim();
    final titleCaseType = trimmedType.isEmpty
        ? trimmedType
        : '${trimmedType[0].toUpperCase()}${trimmedType.substring(1).toLowerCase()}';
    for (final legacyKey in <String>{
      'levels__$trimmedType',
      'levels__$titleCaseType',
    }) {
      if (legacyKey != key) await prefs.remove(legacyKey);
    }
  }

  static Future<void> resetLevels(
    String quizType, {
    int totalLevels = 10,
  }) async {
    await resetProgressForQuiz(quizType);
    await initializeLevelsForQuiz(quizType, totalLevels: totalLevels);
  }
}
