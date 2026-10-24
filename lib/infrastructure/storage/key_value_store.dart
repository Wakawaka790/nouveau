import 'package:shared_preferences/shared_preferences.dart';

/// Accès clé/valeur minimal, isolant [SharedPreferences] (IF-06).
///
/// Cette abstraction permet de tester le dépôt d'état sans plugin Flutter
/// (REQ-074) et de simuler les pannes d'écriture (REQ-044).
abstract interface class KeyValueStore {
  String? getString(String key);
  Future<void> setString(String key, String value);
  Future<void> remove(String key);
  Set<String> keys();
}

/// Adaptateur [SharedPreferences] (production).
final class SharedPreferencesStore implements KeyValueStore {
  SharedPreferencesStore(this._prefs);

  static const String _prefix = '';

  final SharedPreferences _prefs;

  static Future<SharedPreferencesStore> open() async =>
      SharedPreferencesStore(await SharedPreferences.getInstance());

  @override
  String? getString(String key) => _prefs.getString(key);

  @override
  Future<void> setString(String key, String value) =>
      _prefs.setString(key, value);

  @override
  Future<void> remove(String key) => _prefs.remove(key);

  @override
  Set<String> keys() => _prefs
      .getKeys()
      .where((key) => key.startsWith(_prefix))
      .toSet();
}
