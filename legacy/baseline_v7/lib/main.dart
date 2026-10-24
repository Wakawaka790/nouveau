import 'package:flutter/material.dart';
import 'package:quiz_game7/screens/quiz_type_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const QuizGameApp());
}

class QuizGameApp extends StatelessWidget {
  const QuizGameApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF493A8C);
    return MaterialApp(
      title: 'Quiz éducatif',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF182848),
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size.fromHeight(48),
          ),
        ),
      ),
      home: const QuizTypeSelectionScreen(),
    );
  }
} 
