import 'package:flutter/material.dart';

@immutable
class QuizCategory {
  const QuizCategory({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
  });

  /// Stable id used for preference keys and asset directories.
  final String id;
  final String label;
  final String description;
  final IconData icon;
}

const List<QuizCategory> quizCategories = <QuizCategory>[
  QuizCategory(
    id: 'arabe',
    label: 'Arabe',
    description: 'Vocabulaire et langue arabe',
    icon: Icons.translate,
  ),
  QuizCategory(
    id: 'sira',
    label: 'Sira',
    description: 'La vie du Prophète',
    icon: Icons.book_outlined,
  ),
  QuizCategory(
    id: 'coran',
    label: 'Coran',
    description: 'Connaissances autour du Coran',
    icon: Icons.menu_book,
  ),
  QuizCategory(
    id: 'histoire',
    label: 'Histoire',
    description: 'Repères historiques',
    icon: Icons.account_balance,
  ),
  QuizCategory(
    id: 'sahaba',
    label: 'Sahaba',
    description: 'Les compagnons',
    icon: Icons.people_alt,
  ),
  QuizCategory(
    id: 'hijra',
    label: 'Hijra',
    description: 'Le récit de l’Hégire',
    icon: Icons.route,
  ),
  QuizCategory(
    id: 'terme',
    label: 'Termes',
    description: 'Mots et notions à connaître',
    icon: Icons.lightbulb_outline,
  ),
  QuizCategory(
    id: 'general',
    label: 'Général',
    description: 'Questions variées',
    icon: Icons.quiz,
  ),
];

QuizCategory? quizCategoryForId(String id) {
  final normalizedId = id.trim().toLowerCase();
  for (final category in quizCategories) {
    if (category.id == normalizedId) return category;
  }
  return null;
}
