import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import 'auth_dialog.dart';

class WelcomePopup extends ConsumerWidget {
  const WelcomePopup({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    
    if (authState.isAuthenticated) {
      return const SizedBox.shrink();
    }

    return AlertDialog(
      title: const Row(
        children: [
          Text('🌽'),
          SizedBox(width: 8),
          Text('Bem-vindo ao Fuba Clicker!'),
        ],
      ),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crie uma conta para:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Text('• Sincronizar seu progresso na nuvem'),
          Text('• Participar do ranking de jogadores'),
          Text('• Acessar seu save de qualquer dispositivo'),
          SizedBox(height: 16),
          Text(
            'Ou continue jogando offline!',
            style: TextStyle(fontStyle: FontStyle.italic),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Continuar sem Login'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => const AuthDialog(),
            );
          },
          child: const Text('Fazer Login'),
        ),
      ],
    );
  }
}


