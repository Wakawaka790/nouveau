import 'package:flutter/material.dart';

import 'app.dart';
import 'presentation/app_dependencies.dart';

/// Point d'entrée unique (ANO-05).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final deps = await AppDependencies.production();
  runApp(QuizApp(deps: deps));
}
