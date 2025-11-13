import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fuba_clicker/app/global_widgets/storage_monitor.dart';
import 'package:fuba_clicker/app/providers/auth_provider.dart';
import 'package:fuba_clicker/app/modules/account/components/auth_dialog.dart';
import 'package:fuba_clicker/app/modules/account/components/avatar_selector.dart';
import 'package:fuba_clicker/app/core/utils/avatar_helper.dart';
import 'package:fuba_clicker/app/providers/sync_notifier.dart';
import 'package:fuba_clicker/app/services/sync_service.dart';
import 'package:fuba_clicker/app/theme/tokens.dart';

class AccountSettings extends ConsumerWidget {
  const AccountSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final isAuthenticated = authState.isAuthenticated;
    final user = authState.user;

    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadii.lg),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              gradient: AppGradients.purpleFuchsia,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppRadii.lg),
                topRight: Radius.circular(AppRadii.lg),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                  ),
                  child: const Icon(
                    Icons.account_circle,
                    size: 24,
                    color: AppColors.primaryForeground,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Conta',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryForeground,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isAuthenticated) ...[
                  _buildAuthenticatedSection(context, ref, user),
                ] else ...[
                  _buildUnauthenticatedSection(context, ref),
                ],
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                const StorageMonitor(),
                const SizedBox(height: 16),
                const Divider(color: AppColors.border),
                const SizedBox(height: 16),
                _buildSocialMediaSection(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthenticatedSection(
      BuildContext context, WidgetRef ref, user) {
    final profilePicture = user?.profile?.profilePicture;
    final avatarPath = AvatarHelper.getAvatarPath(profilePicture);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha(100),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => _showAvatarSelector(context, ref, profilePicture),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primary,
                      width: 3,
                    ),
                    boxShadow: AppShadows.glowPurple,
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      avatarPath,
                      key: ValueKey(avatarPath),
                      // fit: BoxFit.,
                      // cacheWidth: 150,
                      // cacheHeight: 150,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.muted,
                          child: const Icon(
                            Icons.person,
                            size: 36,
                            color: AppColors.mutedForeground,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logado como',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.username?.isNotEmpty == true
                          ? user!.username
                          : (user?.email?.isNotEmpty == true
                              ? user!.email
                              : 'Usuário'),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showAvatarSelector(context, ref, profilePicture),
                icon: const Icon(Icons.edit, color: AppColors.primary),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.primary.withAlpha(30),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Sincronização',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.cloud_upload,
                label: 'Enviar',
                gradient: AppGradients.blueCyan,
                onPressed: () => _syncToCloud(context, ref),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildActionButton(
                context,
                icon: Icons.cloud_download,
                label: 'Carregar',
                gradient: AppGradients.emeraldGreen,
                onPressed: () => _loadFromCloud(context, ref),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            context,
            icon: Icons.logout,
            label: 'Sair da Conta',
            gradient: AppGradients.redRose,
            onPressed: () => _logout(context, ref),
            isOutlined: true,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onPressed,
    bool isOutlined = false,
  }) {
    if (isOutlined) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          side: const BorderSide(
            color: AppColors.destructive,
            width: 1.5,
          ),
          foregroundColor: AppColors.destructive,
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.level1,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppColors.primaryForeground,
        ),
      ),
    );
  }

  Widget _buildUnauthenticatedSection(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.secondary.withAlpha(100),
            borderRadius: BorderRadius.circular(AppRadii.md),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.muted.withAlpha(150),
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                child: const Icon(
                  Icons.person_off,
                  color: AppColors.mutedForeground,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Não logado',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.foreground,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Faça login para sincronizar seu progresso',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.purpleFuchsia,
              borderRadius: BorderRadius.circular(AppRadii.md),
              boxShadow: AppShadows.glowPurple,
            ),
            child: ElevatedButton.icon(
              onPressed: () => _showAuthDialog(context),
              icon: const Icon(Icons.login, size: 20),
              label: const Text(
                'Fazer Login',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                foregroundColor: AppColors.primaryForeground,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMediaSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Redes Sociais',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.mutedForeground,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Acompanhe novidades e atualizações',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.mutedForeground,
              ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildSocialButton(
                context,
                icon: Icons.chat_bubble_outline,
                label: 'Discord',
                gradient: const LinearGradient(
                  colors: [Color(0xFF5865F2), Color(0xFF4752C4)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: () => _openDiscord(context),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildSocialButton(
                context,
                icon: Icons.alternate_email,
                label: 'Twitter',
                gradient: const LinearGradient(
                  colors: [Color(0xFF1DA1F2), Color(0xFF0d8bd9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onPressed: () => _openTwitter(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Gradient gradient,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.level1,
      ),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: AppColors.primaryForeground,
        ),
      ),
    );
  }

  Future<void> _openDiscord(BuildContext context) async {
    final uri = Uri.parse('https://discord.gg/4Q4eG2n9QE');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o Discord'),
              backgroundColor: Colors.red,
            ),
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

  Future<void> _openTwitter(BuildContext context) async {
    final uri = Uri.parse('https://x.com/tekfuba');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o Twitter'),
              backgroundColor: Colors.red,
            ),
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
      barrierColor: Colors.black.withAlpha(200),
      builder: (context) => const AuthDialog(),
    );
  }

  void _showAvatarSelector(
    BuildContext context,
    WidgetRef ref,
    String? currentAvatar,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(200),
      builder: (context) => AvatarSelector(
        currentAvatar: currentAvatar,
        onAvatarSelected: (avatarPath) async {
          final success = await ref
              .read(authNotifierProvider.notifier)
              .updateProfile(avatarPath);

          if (context.mounted) {
            final scaffoldMessenger = ScaffoldMessenger.of(context);
            scaffoldMessenger.showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(
                      success ? Icons.check_circle : Icons.error,
                      color: AppColors.primaryForeground,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        success
                            ? 'Avatar atualizado com sucesso!'
                            : 'Erro ao atualizar avatar',
                        style: const TextStyle(
                          color: AppColors.primaryForeground,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                backgroundColor:
                    success ? AppColors.emerald500 : AppColors.destructive,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.md),
                ),
                margin: const EdgeInsets.all(16),
                duration: const Duration(seconds: 3),
              ),
            );
          }

          return success;
        },
      ),
    );
  }
}
