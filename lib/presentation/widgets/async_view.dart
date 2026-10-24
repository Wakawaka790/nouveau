import 'package:flutter/material.dart';

import 'error_view.dart';
import 'loading_view.dart';

/// État d'écran scellé et exhaustif (REQ-060).
sealed class ScreenState<T> {
  const ScreenState();
}

final class ScreenLoading<T> extends ScreenState<T> {
  const ScreenLoading();
}

final class ScreenReady<T> extends ScreenState<T> {
  const ScreenReady(this.data);

  final T data;
}

final class ScreenFailure<T> extends ScreenState<T> {
  const ScreenFailure(this.code);

  final String code;
}

/// Rendu uniforme chargement / contenu / échec.
class AsyncView<T> extends StatelessWidget {
  const AsyncView({
    required this.state,
    required this.builder,
    required this.onRetry,
    super.key,
  });

  final ScreenState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => switch (state) {
        ScreenLoading<T>() => const LoadingView(),
        ScreenReady<T>(:final data) => builder(context, data),
        ScreenFailure<T>(:final code) => ErrorView(code: code, onRetry: onRetry),
      };
}
