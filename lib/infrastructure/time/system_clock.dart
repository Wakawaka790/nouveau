import '../../application/ports/clock.dart';

/// Horloge système monotone (IF-07).
final class SystemClock implements Clock {
  SystemClock();

  final Stopwatch _stopwatch = Stopwatch()..start();

  @override
  int nowMs() => _stopwatch.elapsedMilliseconds;
}
