import 'package:flutter/material.dart';

import '../app_strings.dart';

/// Message d'échec + action « Réessayer » (REQ-060).
///
/// N'affiche jamais de détail technique : seul le message associé au code
/// d'erreur est présenté (REQ-051).
class ErrorView extends StatelessWidget {
  const ErrorView({required this.code, required this.onRetry, super.key});

  final String code;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.error_outline, color: Colors.white, size: 48),
              const SizedBox(height: 12),
              Text(
                AppStrings.forErrorCode(code),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text(AppStrings.retry),
              ),
            ],
          ),
        ),
      );
}
