import 'dart:async';

import 'package:flutter/material.dart';

/// Fond animé cyclant des images locales, avec repli sur une couleur unie.
///
/// Comportement identique à la v7 mais isolé de toute logique métier (IF-09).
class CyclingBackground extends StatefulWidget {
  const CyclingBackground({
    required this.child,
    required this.images,
    this.interval = const Duration(seconds: 10),
    super.key,
  });

  final Widget child;
  final List<String> images;
  final Duration interval;

  @override
  State<CyclingBackground> createState() => _CyclingBackgroundState();
}

class _CyclingBackgroundState extends State<CyclingBackground> {
  static const Color _fallback = Color(0xFF182848);

  int _index = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _start();
  }

  @override
  void didUpdateWidget(covariant CyclingBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.images != widget.images || oldWidget.interval != widget.interval) {
      _timer?.cancel();
      _index = 0;
      _start();
    }
  }

  void _start() {
    if (widget.images.length < 2 || widget.interval <= Duration.zero) {
      return;
    }
    _timer = Timer.periodic(widget.interval, (_) {
      if (!mounted) {
        return;
      }
      setState(() => _index = (_index + 1) % widget.images.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.images.isEmpty) {
      return ColoredBox(color: _fallback, child: widget.child);
    }
    final current = widget.images[_index];
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 700),
          child: Image.asset(
            current,
            key: ValueKey<String>(current),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) =>
                const ColoredBox(color: _fallback),
          ),
        ),
        const ColoredBox(color: Color(0x660B1020)),
        widget.child,
      ],
    );
  }
}

/// Enveloppe commune : fond animé + zone sûre.
class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  static const List<String> _images = <String>[
    'assets/backgrounds/bg1.png',
    'assets/backgrounds/bg2.png',
    'assets/backgrounds/bg3.png',
  ];

  final Widget child;

  @override
  Widget build(BuildContext context) => CyclingBackground(
        images: _images,
        child: SafeArea(child: child),
      );
}
