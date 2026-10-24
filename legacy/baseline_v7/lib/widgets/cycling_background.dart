import 'dart:async';

import 'package:flutter/material.dart';

/// Optional asset-based background for screens that provide their own images.
/// An empty image list safely falls back to displaying [child] unchanged.
class CyclingBackground extends StatefulWidget {
  const CyclingBackground({
    super.key,
    required this.child,
    required this.images,
    this.interval = const Duration(seconds: 6),
  });

  final Widget child;
  final List<String> images;
  final Duration interval;

  @override
  State<CyclingBackground> createState() => _CyclingBackgroundState();
}

class _CyclingBackgroundState extends State<CyclingBackground> {
  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCycle();
  }

  @override
  void didUpdateWidget(covariant CyclingBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images != widget.images || oldWidget.interval != widget.interval) {
      _timer?.cancel();
      _currentIndex = 0;
      _startCycle();
    }
  }

  void _startCycle() {
    if (widget.images.length < 2 || widget.interval <= Duration.zero) return;
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted || widget.images.isEmpty) return;
      setState(() => _currentIndex = (_currentIndex + 1) % widget.images.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) return widget.child;
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: Image.asset(
            widget.images[_currentIndex],
            key: ValueKey<String>(widget.images[_currentIndex]),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => const ColoredBox(
              color: Color(0xFF182848),
            ),
          ),
        ),
        widget.child,
      ],
    );
  }
} 
