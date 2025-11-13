import 'package:flutter/material.dart';
import 'package:fuba_clicker/app/core/utils/avatar_helper.dart';
import 'package:fuba_clicker/app/theme/tokens.dart';

class AvatarSelector extends StatefulWidget {
  final String? currentAvatar;
  final Future<bool> Function(String) onAvatarSelected;

  const AvatarSelector({
    super.key,
    this.currentAvatar,
    required this.onAvatarSelected,
  });

  @override
  State<AvatarSelector> createState() => _AvatarSelectorState();
}

class _AvatarSelectorState extends State<AvatarSelector> {
  bool _isLoading = false;
  String? _loadingAvatar;

  Future<void> _handleAvatarSelection(String avatarPath) async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _loadingAvatar = avatarPath;
    });

    try {
      final success = await widget.onAvatarSelected(avatarPath);

      if (mounted) {
        if (success) {
          Navigator.of(context).pop();
        } else {
          setState(() {
            _isLoading = false;
            _loadingAvatar = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadingAvatar = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppRadii.lg),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
          boxShadow: AppShadows.level2,
        ),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    gradient: AppGradients.purpleFuchsia,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(AppRadii.lg),
                      topRight: Radius.circular(AppRadii.lg),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(AppRadii.md),
                            ),
                            child: const Icon(
                              Icons.account_circle,
                              color: AppColors.primaryForeground,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Selecionar Avatar',
                            style:
                                Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: AppColors.primaryForeground,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.primaryForeground,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1,
                    ),
                    itemCount: AvatarHelper.availableAvatars.length,
                    itemBuilder: (context, index) {
                      final avatarPath = AvatarHelper.availableAvatars[index];
                      final isSelected = widget.currentAvatar == avatarPath ||
                          (widget.currentAvatar == null &&
                              avatarPath == AvatarHelper.getDefaultAvatar());
                      final isLoading = _isLoading && _loadingAvatar == avatarPath;

                      return GestureDetector(
                        onTap: _isLoading ? null : () => _handleAvatarSelection(avatarPath),
                        child: Stack(
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                  width: isSelected ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(AppRadii.md),
                                boxShadow: isSelected
                                    ? AppShadows.glowPurple
                                    : null,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadii.sm),
                                child: Image.asset(
                                  avatarPath,
                                  // fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: AppColors.muted,
                                      child: const Icon(
                                        Icons.person,
                                        color: AppColors.mutedForeground,
                                        size: 32,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            if (isLoading)
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.black.withAlpha(150),
                                  borderRadius: BorderRadius.circular(AppRadii.md),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      AppColors.primaryForeground,
                                    ),
                                    strokeWidth: 2,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            if (_isLoading)
              Positioned.fill(
                child: AbsorbPointer(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(AppRadii.lg),
                    ),
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          border: Border.all(
                            color: AppColors.border,
                            width: 1,
                          ),
                          boxShadow: AppShadows.level2,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary,
                              ),
                              strokeWidth: 3,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Atualizando avatar...',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: AppColors.foreground,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

