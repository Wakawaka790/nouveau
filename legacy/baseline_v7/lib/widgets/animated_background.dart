import 'package:flutter/material.dart';

import 'cycling_background.dart';

/// Fond d'écran animé qui alterne les images locales du projet.
class AnimatedBackground extends StatelessWidget {
  const AnimatedBackground({super.key, required this.child});

  static const List<String> _backgroundImages = <String>[
    'assets/backgrounds/bg1.png',
    'assets/backgrounds/bg2.png',
    'assets/backgrounds/bg3.jpeg',
  ];

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return CyclingBackground(
      images: _backgroundImages,
      interval: const Duration(seconds: 10),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          // Assombrit légèrement les photos pour garder le texte blanc lisible.
          const ColoredBox(color: Color(0x660B1020)),
          child,
        ],
      ),
    );
  }
} 
