import 'package:flutter/material.dart';

@immutable
class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.imagePath,
  });

  /// Stable id used for preference keys and asset directories.
  final String id;
  final String label;
  final String description;
  final IconData icon;

  /// Image de fond de la carte du thème, dans `assets/images/`.
  final String imagePath;
}

const List<QuizCategory> quizCategories = <QuizCategory>[
  QuizCategory(
    id: 'arabe',
    label: 'Arabe',
    description: 'Vocabulaire et langue arabe',
    icon: Icons.translate,
    imagePath: 'assets/images/arabe.jpg',
  ),
  QuizCategory(
    id: 'sira',
    label: 'Sira',
    description: 'La vie du Prophète',
    icon: Icons.book_outlined,
    imagePath: 'assets/images/sira.jpg',
  ),
  QuizCategory(
    id: 'coran',
    label: 'Coran',
    description: 'Connaissances autour du Coran',
    icon: Icons.menu_book,
    imagePath: 'assets/images/coran.jpg',
  ),
  QuizCategory(
    id: 'histoire',
    label: 'Histoire',
    description: 'Repères historiques',
    icon: Icons.account_balance,
    imagePath: 'assets/images/histoire.jpg',
  ),
  QuizCategory(
    id: 'sahaba',
    label: 'Sahaba',
    description: 'Les compagnons',
    icon: Icons.people_alt,
    imagePath: 'assets/images/sahaba.jpg',
  ),
  QuizCategory(
    id: 'hijra',
    label: 'Hijra',
    description: 'Le récit de l’Hégire',
    icon: Icons.route,
    imagePath: 'assets/images/hijra.jpg',
  ),
  QuizCategory(
    id: 'terme',
    label: 'Termes',
    description: 'Mots et notions à connaître',
    icon: Icons.lightbulb_outline,
    imagePath: 'assets/images/terme.jpg',
  ),
  QuizCategory(
    id: 'general',
    label: 'Général',
    description: 'Questions variées',
    icon: Icons.quiz,
    imagePath: 'assets/images/general.jpg',
  ),
];

QuizCategory? quizCategoryForId(String id) {
  final normalizedId = id.trim().toLowerCase();
  for (final category in quizCategories) {
    if (category.id == normalizedId) return category;
  }
  return null;
}
