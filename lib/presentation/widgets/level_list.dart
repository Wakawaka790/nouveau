import 'package:flutter/material.dart';

import '../app_strings.dart';

/// Liste des niveaux d'un thème avec état verrouillé/déverrouillé (REQ-062).
class LevelList extends StatelessWidget {
  const LevelList({
    required this.levels,
    required this.unlocked,
    required this.onSelect,
    super.key,
  });

  final List<int> levels;
  final Set<int> unlocked;
  final void Function(int level) onSelect;

  @override
  Widget build(BuildContext context) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
        itemCount: levels.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final level = levels[index];
          final isUnlocked = unlocked.contains(level);
          return Card(
            color: Colors.white,
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor:
                    isUnlocked ? const Color(0xFF493A8C) : Colors.grey,
                child: Icon(
                  isUnlocked ? Icons.lock_open : Icons.lock_outline,
                  color: Colors.white,
                ),
              ),
              title: Text(
                AppStrings.levelLabel.replaceFirst('%d', '$level'),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                isUnlocked
                    ? AppStrings.levelUnlockedHint
                    : AppStrings.levelLockedHint,
              ),
              trailing: Icon(isUnlocked ? Icons.play_arrow : Icons.lock),
              enabled: isUnlocked,
              onTap: isUnlocked ? () => onSelect(level) : null,
            ),
          );
        },
      );
}
