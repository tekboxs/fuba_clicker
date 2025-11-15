import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../../core/utils/efficient_number.dart';
import 'package:fuba_clicker/app/models/rebirth_upgrade.dart';
import 'package:fuba_clicker/app/modules/rebirth/components/hexagonal_upgrade_card.dart';
import 'package:fuba_clicker/app/providers/rebirth_upgrade_provider.dart';
import 'package:fuba_clicker/app/providers/rebirth_provider.dart';
import 'package:fuba_clicker/app/providers/notification_provider.dart';
import 'package:fuba_clicker/app/providers/game_providers.dart';
import 'package:fuba_clicker/app/core/utils/difficulty_barriers.dart';
import 'package:fuba_clicker/app/theme/tokens.dart';

class RebirthUpgradesPage extends ConsumerStatefulWidget {
  const RebirthUpgradesPage({super.key});

  @override
  ConsumerState<RebirthUpgradesPage> createState() => _RebirthUpgradesPageState();
}

class _RebirthUpgradesPageState extends ConsumerState<RebirthUpgradesPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _gradientController;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(notificationNotifierProvider).markNotificationsAsViewed('upgrades');
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    super.dispose();
  }

  bool _isUpgradeBarrierLocked(
    RebirthUpgrade upgrade,
    EfficientNumber fuba,
    List<int> generatorsOwned,
  ) {
    final barriers = DifficultyBarrierManager.getBarriersForCategory('upgrade');

    // if (kDebugMode) return false;

    switch (upgrade.id) {
      case 'auto_clicker':
      case 'click_power':
        return !barriers[0].isUnlocked(fuba, generatorsOwned);
      case 'idle_boost':
      case 'lucky_boxes':
      case 'starting_fuba':
        return !barriers[1].isUnlocked(fuba, generatorsOwned);
      case 'generator_discount':
      case 'offline_production':
      case 'production_multiplier':
        return !barriers[2].isUnlocked(fuba, generatorsOwned);
      default:
        return false;
    }
  }

  DifficultyBarrier? _getBarrierForUpgrade(RebirthUpgrade upgrade) {
    final barriers = DifficultyBarrierManager.getBarriersForCategory('upgrade');

    switch (upgrade.id) {
      case 'auto_clicker':
      case 'click_power':
        return barriers[0];
      case 'idle_boost':
      case 'lucky_boxes':
      case 'starting_fuba':
        return barriers[1];
      case 'generator_discount':
      case 'offline_production':
      case 'production_multiplier':
        return barriers[2];
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ref = this.ref;
    final rebirthData = ref.watch(rebirthDataProvider);
    final fuba = ref.watch(fubaProvider);
    final generatorsOwned = ref.watch(generatorsProvider);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Text('✨ '),
            Text(
              'Upgrades Celestiais',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.foreground,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.card.withAlpha(240),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.background,
              AppColors.purple900.withAlpha(200),
              AppColors.background,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            Column(
              children: [
                _buildTokenDisplay(rebirthData.celestialTokens, isMobile),
                Expanded(
                  child: GridView.builder(
                    padding: EdgeInsets.all(isMobile ? 12 : 24),
                    gridDelegate: isMobile
                        ? SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 320,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.65,
                          )
                        : SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 500,
                            mainAxisExtent: 450,
                            crossAxisSpacing: 24,
                            mainAxisSpacing: 24,
                          ),
                    itemCount: allUpgrades.length,
                    itemBuilder: (context, index) {
                      final upgrade = allUpgrades[index];
                      final isBarrierLocked = _isUpgradeBarrierLocked(
                        upgrade,
                        fuba,
                        generatorsOwned,
                      );
                      final barrier = _getBarrierForUpgrade(upgrade);

                      return HexagonalUpgradeCard(
                        key: ValueKey('upgrade_${upgrade.id}'),
                        upgrade: upgrade,
                        rebirthData: rebirthData,
                        isBarrierLocked: isBarrierLocked,
                        barrier: barrier,
                        fuba: fuba,
                        generatorsOwned: generatorsOwned,
                      )
                          .animate()
                          .fadeIn(
                            duration: 300.ms,
                            delay: (index * 50).ms,
                          )
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            duration: 400.ms,
                            delay: (index * 50).ms,
                            curve: Curves.easeOutBack,
                          );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: _CelestialBackgroundPainter(),
      ),
    );
  }

  Widget _buildTokenDisplay(double tokens, bool isMobile) {
    return Container(
      margin: EdgeInsets.all(isMobile ? 12 : 16),
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 16 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.purple600.withAlpha(100),
                  AppColors.fuchsia600.withAlpha(80),
                  AppColors.cyan500.withAlpha(100),
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(AppRadii.xl),
              border: Border.all(
                color: AppColors.cyan500.withAlpha(150),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.cyan500.withAlpha(100),
                  blurRadius: 24,
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppColors.purple500.withAlpha(80),
                  blurRadius: 32,
                  spreadRadius: -4,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      colors: [
                        AppColors.cyan500.withAlpha(200),
                        AppColors.cyan500.withAlpha(100),
                      ],
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cyan500.withAlpha(150),
                        blurRadius: 16,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Text(
                    '💎',
                    style: TextStyle(fontSize: 32),
                  ),
                )
                    .animate(onPlay: (controller) => controller.repeat(reverse: true))
                    .scale(
                      begin: const Offset(1.0, 1.0),
                      end: const Offset(1.08, 1.08),
                      duration: 2.seconds,
                      curve: Curves.easeInOut,
                    ),
                SizedBox(width: isMobile ? 12 : 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _gradientController,
                      builder: (context, child) {
                        final progress = _gradientController.value;
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            final angle = progress * 2 * math.pi;
                            final cos = math.cos(angle);
                            final sin = math.sin(angle);
                            return LinearGradient(
                              begin: Alignment(
                                -cos + sin,
                                -sin - cos,
                              ),
                              end: Alignment(
                                cos - sin,
                                sin + cos,
                              ),
                              colors: [
                                AppColors.cyan400,
                                AppColors.fuchsia400,
                                AppColors.purple400,
                                AppColors.cyan400,
                              ],
                              stops: const [0.0, 0.33, 0.66, 1.0],
                            ).createShader(bounds);
                          },
                          child: Text(
                            tokens.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: isMobile ? 28 : 36,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        );
                      },
                    ),
                    Text(
                      'Tokens Celestiais',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        color: AppColors.mutedForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (kDebugMode) ...[
                  const Spacer(),
                  Row(
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          return ElevatedButton(
                            onPressed: () {
                              ref.read(rebirthDataProvider.notifier).state =
                                  ref.read(rebirthDataProvider).copyWith(
                                        celestialTokens: ref
                                                .read(rebirthDataProvider)
                                                .celestialTokens +
                                            1000.0,
                                      );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.cyan500,
                              foregroundColor: AppColors.foreground,
                            ),
                            child: const Text('+1000'),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          return ElevatedButton(
                            onPressed: () {
                              _unlockAllUpgrades(ref);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.emerald500,
                              foregroundColor: AppColors.foreground,
                            ),
                            child: const Text('Desbloquear'),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.2, end: 0, duration: 500.ms, curve: Curves.easeOut);
  }

  void _unlockAllUpgrades(WidgetRef ref) {
    final upgradeNotifier = ref.read(upgradeNotifierProvider);
    final rebirthData = ref.read(rebirthDataProvider);

    final maxAscensionRequirement = allUpgrades.map((u) => u.ascensionRequirement).reduce((a, b) => a > b ? a : b);

    ref.read(rebirthDataProvider.notifier).state = rebirthData.copyWith(
      celestialTokens: 9999999.0,
      ascensionCount: maxAscensionRequirement,
    );

    for (final upgrade in allUpgrades) {
      final currentLevel = upgradeNotifier.getUpgradeLevel(upgrade.id);
      for (int level = currentLevel; level < upgrade.maxLevel; level++) {
        if (upgradeNotifier.canPurchase(upgrade)) {
          upgradeNotifier.purchaseUpgrade(upgrade);
        }
      }
    }
  }
}

class _CelestialBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    for (int i = 0; i < 20; i++) {
      final angle = (i * math.pi * 2) / 20;
      final radius = size.width * 0.3;
      final x = centerX + math.cos(angle) * radius;
      final y = centerY + math.sin(angle) * radius;

      final distance = math.sqrt(
        math.pow(x - centerX, 2) + math.pow(y - centerY, 2),
      );
      final normalizedDistance = distance / (size.width * 0.5);
      final opacity = (1 - normalizedDistance).clamp(0.0, 0.3);

      paint.color = AppColors.cyan500.withAlpha((opacity * 50).toInt());
      canvas.drawCircle(
        Offset(x, y),
        3 + (i % 3) * 2,
        paint,
      );
    }

    for (int i = 0; i < 15; i++) {
      final angle = (i * math.pi * 2) / 15 + math.pi / 4;
      final radius = size.width * 0.4;
      final x = centerX + math.cos(angle) * radius;
      final y = centerY + math.sin(angle) * radius;

      final distance = math.sqrt(
        math.pow(x - centerX, 2) + math.pow(y - centerY, 2),
      );
      final normalizedDistance = distance / (size.width * 0.5);
      final opacity = (1 - normalizedDistance).clamp(0.0, 0.25);

      paint.color = AppColors.purple400.withAlpha((opacity * 40).toInt());
      canvas.drawCircle(
        Offset(x, y),
        2 + (i % 2) * 1.5,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
