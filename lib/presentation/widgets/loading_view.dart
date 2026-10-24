import 'package:flutter/material.dart';

/// Indicateur de chargement uniforme (REQ-060).
///
/// Centralisé pour qu'aucun écran ne redéfinisse son propre style : une seule
/// définition à maintenir, et un repère identique pour l'utilisateur.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
}
