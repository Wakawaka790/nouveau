import 'dart:math';

import '../../application/ports/random_source.dart';

/// Source d'aléa graineable : reproductible en test (REQ-078).
final class SeededRandomSource implements RandomSource {
  SeededRandomSource({int? seed}) : _random = Random(seed);

  final Random _random;

  @override
  int nextInt(int max) => _random.nextInt(max);
}
