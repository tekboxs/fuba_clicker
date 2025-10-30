import 'package:flutter/material.dart';

class AppErrorWidget extends StatelessWidget {
  final String? message;
  final bool expand;

  const AppErrorWidget({
    super.key,
    this.message,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    const defaultMessage = 'Erro de conexão. Tente novamente.';

    if (expand) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline,
                  color: Theme.of(context).colorScheme.error, size: 48),
              const SizedBox(height: 16),
              Text(
                message ?? defaultMessage,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.error_outline,
            color: Theme.of(context).colorScheme.error, size: 24),
        const SizedBox(height: 8),
        Text(
          message ?? defaultMessage,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.onSurface),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
