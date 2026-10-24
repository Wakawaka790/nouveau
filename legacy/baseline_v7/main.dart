import 'package:flutter/material.dart';
import 'package:quiz_game7/screens/quiz_type_selection_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz éducatif',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.deepPurple),
      home: const QuizTypeSelectionScreen(), // démarrage direct
    );
  }
} 
