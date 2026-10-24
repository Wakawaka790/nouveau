import 'package:flutter/material.dart';

/// Bouton d'option accessible : cible ≥ 48 dp, libellé sémantique (REQ-067).
class OptionButton extends StatelessWidget {
  const OptionButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Semantics(
          button: true,
          label: label,
          enabled: onPressed != null,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF34266D),
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              textStyle: const TextStyle(fontSize: 16),
            ),
            child: Text(label, textAlign: TextAlign.center),
          ),
        ),
      );
}
