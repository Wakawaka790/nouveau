import 'package:flutter/services.dart';

/// Lecture d'un asset textuel, isolant `rootBundle` (IF-05).
abstract interface class AssetReader {
  /// Lève une exception si l'asset est absent ; convertie par le dépôt.
  Future<String> read(String path);
}

/// Adaptateur `rootBundle` (production).
final class FlutterAssetReader implements AssetReader {
  const FlutterAssetReader();

  @override
  Future<String> read(String path) => rootBundle.loadString(path);
}
