import 'package:flutter/material.dart';

import 'presentation/app_dependencies.dart';
import 'presentation/screens/theme_selection_screen.dart';

/// Racine de l'application : thème, typographie, écran initial (REQ-061).
class QuizApp extends StatelessWidget {
  const QuizApp({required this.deps, super.key});

  static const Color seedColor = Color(0xFF493A8C);
  static const Color appBarColor = Color(0xFF182848);

  final AppDependencies deps;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Quiz éducatif',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
          appBarTheme: const AppBarTheme(
            backgroundColor: appBarColor,
            foregroundColor: Colors.white,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
            ),
          ),
        ),
        home: ThemeSelectionScreen(deps: deps),
      );
}
