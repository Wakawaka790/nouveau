import 'package:shared_preferences/shared_preferences.dart';

class ProfileManager {
  static const String _scoreKey = 'total_score';

  /// Adds earned points to the locally saved score and returns the new total.
  static Future<int> updateScore(int additionalPoints) async {
    if (additionalPoints < 0) {
      throw ArgumentError.value(
        additionalPoints,
        'additionalPoints',
        'ne peut pas être négatif',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final newTotal = (prefs.getInt(_scoreKey) ?? 0) + additionalPoints;
    await prefs.setInt(_scoreKey, newTotal);
    return newTotal;
  }

  static Future<void> resetScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_scoreKey, 0);
  }

  static Future<void> clearScore() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_scoreKey);
  }

  static Future<int> getTotalScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_scoreKey) ?? 0;
  }
}
