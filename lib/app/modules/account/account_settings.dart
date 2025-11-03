import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/global_widgets/storage_monitor.dart';
import 'package:fuba_clicker/app/providers/auth_provider.dart';
import 'package:fuba_clicker/app/modules/account/components/auth_dialog.dart';
import 'package:fuba_clicker/app/providers/sync_notifier.dart';
import 'package:fuba_clicker/app/services/sync_service.dart';

class AccountSettings extends ConsumerWidget {
  const AccountSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState.isAuthenticated;
    final user = authState.user;

    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_circle, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Conta',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (isAuthenticated) ...[
              _buildAuthenticatedSection(context, ref, user),
            ] else ...[
              _buildUnauthenticatedSection(context, ref),
            ],
            const SizedBox(height: 16),
            const StorageMonitor(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthenticatedSection(BuildContext context, WidgetRef ref, user) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text('Logado como'),
          subtitle: Text(user?.username ?? 'Usuário'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _syncToCloud(context, ref),
                icon: const Icon(Icons.cloud_upload),
                label: const Text('Enviar para Nuvem'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _loadFromCloud(context, ref),
                icon: const Icon(Icons.cloud_download),
                label: const Text('Carregar da Nuvem'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _logout(context, ref),
            icon: const Icon(Icons.logout),
            label: const Text('Sair'),
          ),
        ),
      ],
    );
  }

  Widget _buildUnauthenticatedSection(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        const ListTile(
          leading: Icon(Icons.person_off),
          title: Text('Não logado'),
          subtitle: Text('Faça login para sincronizar seu progresso'),
          contentPadding: EdgeInsets.zero,
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => _showAuthDialog(context),
            icon: const Icon(Icons.login),
            label: const Text('Fazer Login'),
          ),
        ),
      ],
    );
  }

  Future<void> _syncToCloud(BuildContext context, WidgetRef ref) async {
    try {
      final success =
          await ref.read(authNotifierProvider.notifier).syncToCloud();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success
                  ? 'Progresso enviado para nuvem com sucesso!'
                  : 'Erro ao enviar para nuvem',
            ),
            backgroundColor: success ? Colors.green : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadFromCloud(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Carregar da Nuvem'),
        content: const Text(
          'Isso irá substituir seu progresso local pelo da nuvem. '
          'Tem certeza?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final syncService = ref.read(syncServiceProvider.notifier);

        final success = await syncService.downloadCloudToLocal();

        if (success) {
          ref.read(syncNotifierProvider.notifier).notifyDataLoaded();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Progresso carregado da nuvem com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          if (context.mounted) {
            showDialog(
              context: context,
              builder: (context) => const Text('Erro ao carregar da nuvem'),
            );
          }
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _logout(BuildContext context, WidgetRef ref) async {
    await ref.read(authNotifierProvider.notifier).logout();

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout realizado com sucesso'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showAuthDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AuthDialog(),
    );
  }
}
