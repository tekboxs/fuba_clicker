import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/providers/save_provider.dart';
import '../../providers/game_providers.dart';
import '../../providers/audio_provider.dart';
import '../../providers/accessory_provider.dart';
import '../../providers/achievement_provider.dart';
import '../../providers/rebirth_upgrade_provider.dart';
import '../../providers/rebirth_provider.dart';
import '../../providers/forus_upgrade_provider.dart';
import '../../providers/visual_settings_provider.dart';
import '../../providers/potion_provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/potion_color.dart';
import '../../models/potion_effect.dart';
import '../../services/save_service.dart';
import '../../models/achievement.dart';
import '../../models/cake_accessory.dart';
import '../../models/fuba_generator.dart';
import '../../models/rebirth_data.dart';
import '../../core/utils/constants.dart';
import '../../core/utils/efficient_number.dart';
import 'components/generator_section.dart';
import '../../theme/components.dart';
import '../shop/loot_box_shop.dart';
import '../shop/forus_shop.dart';
import '../shop/craft_page.dart';
import '../potions/cauldron_page.dart';
import 'components/floating_accessories.dart';
import 'components/cake_display.dart';
import '../rebirth/rebirth_page.dart';
import '../achievements/achievements_page.dart';
import '../rebirth/rebirth_upgrades_page.dart';
import '../achievements/components/achievement_popup.dart';
import '../account/account_settings.dart';
import '../ranking/ranking_page.dart';

class _MenuItemData {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;
  final int? badgeCount;

  _MenuItemData({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
    this.badgeCount,
  });
}

/// Página principal do jogo
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _parallaxController;
  Timer? _autoProductionTimer;

  // Variáveis para rastreamento de cliques
  DateTime _lastClickTime = DateTime.now();
  int _currentStreak = 0;
  DateTime _lastStreakTime = DateTime.now();

  // Variáveis para conquistas secretas
  final List<DateTime> _clickTimes = [];
  Timer? _patienceTimer;
  Timer? _consolidatedAchievementTimer;
  double _totalClickFuba = 0;
  DateTime _lastClickTimeForZen = DateTime.now();
  final DateTime _appStartTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startAutoProduction();
    _initializeAudio();
    _startPlayTimeTracking();
  }

  /// Inicializa o áudio do jogo
  void _initializeAudio() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(audioStateProvider.notifier);
      }
    });
  }

  /// Inicializa os controllers de animação
  void _initializeControllers() {
    _animationController = AnimationController(
      vsync: this,
      duration: GameConstants.cakeAnimationDuration,
    );

    _parallaxController = AnimationController(
      vsync: this,
      duration: GameConstants.parallaxAnimationDuration,
    );

    _parallaxController.forward();
    _parallaxController.addListener(_handleParallaxAnimation);
  }

  /// Manipula a animação de paralaxe (ida e volta)
  void _handleParallaxAnimation() {
    if (_parallaxController.isCompleted) {
      _parallaxController.reverse();
    }
    if (_parallaxController.isDismissed) {
      _parallaxController.forward();
    }
  }

  /// Inicia a produção automática de fubá
  void _startAutoProduction() {
    _autoProductionTimer = Timer.periodic(
      GameConstants.autoProductionInterval,
      (timer) {
        if (mounted) {
          final autoProduction = ref.read(autoProductionProvider);
          final autoClickerRate =
              ref.read(upgradeNotifierProvider).getAutoClickerRate();

          EfficientNumber totalProduction = autoProduction;

          if (autoClickerRate > 0 &&
              autoClickerRate.isFinite &&
              !autoClickerRate.isNaN) {
            final clickMultiplier =
                ref.read(upgradeNotifierProvider).getClickMultiplier();
            final achievementMultiplier = ref.watch(
              achievementMultiplierProvider,
            );
            final accessoryMultiplier = ref.read(accessoryMultiplierProvider);
            final rebirthMultiplier = ref.read(rebirthMultiplierProvider);
            final oneTimeMultiplier = ref.read(oneTimeMultiplierProvider);

            final totalClickMultiplier = clickMultiplier *
                achievementMultiplier *
                accessoryMultiplier *
                rebirthMultiplier *
                oneTimeMultiplier;

            if (totalClickMultiplier.toDouble().isFinite) {
              final autoClickValue =
                  EfficientNumber.fromDouble(autoClickerRate) *
                      totalClickMultiplier;
              totalProduction += autoClickValue;

              final autoClickValueDouble = autoClickValue.toDouble();
              if (autoClickValueDouble.isFinite &&
                  !autoClickValueDouble.isNaN) {
                _processAutoClicks(autoClickerRate, autoClickValueDouble);
              }
            }
          }

          if (totalProduction.compareTo(const EfficientNumber.zero()) > 0) {
            ref.read(fubaProvider.notifier).update((state) {
              return state + totalProduction;
            });

            ref.read(achievementNotifierProvider).incrementStat(
                  'total_production',
                  totalProduction.toDouble(),
                  context,
                );
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _autoProductionTimer?.cancel();
    _patienceTimer?.cancel();
    _consolidatedAchievementTimer?.cancel();
    _animationController.dispose();
    _parallaxController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (context) {
        try {
          final isMobile = GameConstants.isMobile(context);
          return Scaffold(
            body: AnimatedGradientBackground(
              child: SafeArea(
                child: isMobile
                    ? Column(
                        children: [
                          _buildAccessToolbar(),
                          Expanded(child: _buildMainContent()),
                        ],
                      )
                    : _buildMainContent(),
              ),
            ),
          );
        } catch (error, stackTrace) {
          if (kDebugMode) {
            print('Erro na HomePage: $error\n$stackTrace');
          }

          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        '❌',
                        style: TextStyle(fontSize: 80),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Erro no Jogo',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      if (kDebugMode) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'Stack Trace:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SelectableText(
                          stackTrace.toString(),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.white54,
                          ),
                        ),
                      ],
                      const SizedBox(height: 32),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pushAndRemoveUntil(
                            MaterialPageRoute(
                              builder: (context) => const HomePage(),
                            ),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Recarregar Jogo'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildAccessBarInner(bool isMobile, bool isAudioPlaying) {
    final ownedUpgrades = ref.watch(forusUpgradesOwnedProvider);
    final hasMergeUpgrade = ownedUpgrades.contains('merge_items');

    final menuItems = [
      _MenuItemData(
        icon: Icons.shopping_bag,
        label: 'Loja',
        gradient: const LinearGradient(
          colors: [Color(0xFFA855F7), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        badgeCount: _getShopBadgeCount(),
        onTap: () {
          ref.read(notificationNotifierProvider).markNotificationsAsViewed('shop');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LootBoxShopPage(),
            ),
          );
        },
      ),
      _MenuItemData(
        icon: Icons.diamond,
        label: 'Forus',
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF3B82F6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ForusShopPage(),
            ),
          );
        },
      ),
      if (hasMergeUpgrade)
        _MenuItemData(
          icon: Icons.merge,
          label: 'Fundir',
          gradient: const LinearGradient(
            colors: [Color(0xFFEC4899), Color(0xFFA855F7)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const CraftPage(),
              ),
            );
          },
        ),
      _MenuItemData(
        icon: Icons.science,
        label: 'Poções',
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFFA855F7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CauldronPage(),
            ),
          );
        },
      ),
      _MenuItemData(
        icon: Icons.auto_awesome,
        label: 'Upgrades',
        gradient: const LinearGradient(
          colors: [Color(0xFFEAB308), Color(0xFFF97316)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        badgeCount: _getUpgradesBadgeCount(),
        onTap: () {
          ref.read(notificationNotifierProvider).markNotificationsAsViewed('upgrades');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RebirthUpgradesPage(),
            ),
          );
        },
      ),
      _MenuItemData(
        icon: Icons.refresh,
        label: 'Rebirth',
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        badgeCount: ref.watch(rebirthBadgeCountProvider),
        onTap: () {
          ref.read(notificationNotifierProvider).markNotificationsAsViewed('rebirth');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RebirthPage(),
            ),
          );
        },
      ),
      _MenuItemData(
        icon: Icons.account_circle,
        label: 'Conta',
        gradient: const LinearGradient(
          colors: [Color(0xFF3B82F6), Color(0xFF6366F1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          _showAccountSettings();
        },
      ),
      _MenuItemData(
        icon: Icons.leaderboard,
        label: 'Ranking',
        gradient: const LinearGradient(
          colors: [Color(0xFFA855F7), Color(0xFFEC4899)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const RankingPage(),
            ),
          );
        },
      ),
      _MenuItemData(
        icon: Icons.emoji_events,
        label: 'Conquistas',
        gradient: const LinearGradient(
          colors: [Color(0xFFEAB308), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        badgeCount: _getAchievementsBadgeCount(),
        onTap: () {
          _markAllAchievementsAsViewed();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const AchievementsPage(),
            ),
          );
        },
      ),
      _MenuItemData(
        icon: Icons.settings,
        label: 'Config',
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          _showPerformanceModeDialog();
        },
      ),
      _MenuItemData(
        icon: isAudioPlaying ? Icons.volume_up : Icons.volume_off,
        label: 'Som',
        gradient: LinearGradient(
          colors: isAudioPlaying
              ? [const Color(0xFF22C55E), const Color(0xFF14B8A6)]
              : [Colors.grey.shade600, Colors.grey.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        onTap: () {
          _showVolumeControlDialog();
        },
      ),
      if (!isMobile)
        _MenuItemData(
          icon: Icons.favorite,
          label: 'Fubádor',
          gradient: const LinearGradient(
            colors: [Color(0xFFEF4444), Color(0xFFF43F5E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          onTap: _showSupporterDialog,
        ),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Stack(
              children: [
                if (!isMobile)
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    width: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFC4B5FD).withAlpha(200),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                if (isMobile)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 2,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            const Color(0xFFC4B5FD).withAlpha(200),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isMobile ? 4 : 6,
                    vertical: isMobile ? 4 : 6,
                  ),
                  child: isMobile
                      ? _buildMobileMenuGrid(menuItems)
                      : _buildDesktopMenuVertical(menuItems),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileMenuGrid(List<_MenuItemData> items) {
    final firstRowItems = items.take(6).toList();
    final secondRowItems = items.skip(6).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: firstRowItems.map((item) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: _buildMenuButton(item, true),
              ),
            );
          }).toList(),
        ),
        if (secondRowItems.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              ...secondRowItems.map((item) {
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: _buildMenuButton(item, true),
                  ),
                );
              }),
              ...List.generate(
                6 - secondRowItems.length,
                (index) => const Expanded(child: SizedBox()),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDesktopMenuVertical(List<_MenuItemData> items) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: items.map((item) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildMenuButton(item, false),
        );
      }).toList(),
    );
  }

  Widget _buildMenuButton(_MenuItemData item, bool isMobile) {
    return SizedBox(
      height: isMobile ? 60 : 70,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              gradient: item.gradient,
              borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
              border: Border.all(
                color: Colors.white.withAlpha(102),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withAlpha(128),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withAlpha(100),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: item.onTap,
                borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                child: Stack(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withAlpha(51),
                            Colors.transparent,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(isMobile ? 12 : 16),
                      ),
                      // padding: EdgeInsets.all(isMobile ? 4 : 6),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            item.icon,
                            color: Colors.white,
                            size: isMobile ? 18 : 20,
                            shadows: [
                              Shadow(
                                color: Colors.white.withAlpha(230),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          if (isMobile) ...[
                            const SizedBox(height: 2),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ] else ...[
                            const SizedBox(height: 4),
                            Text(
                              item.label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (item.badgeCount != null && item.badgeCount! > 0)
            Positioned(
              top: -4,
              right: -4,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.red.shade400,
                        width: 1,
                      ),
                    ),
                  )
                      .animate(onPlay: (controller) => controller.repeat())
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(2, 2),
                        duration: 1500.ms,
                        curve: Curves.easeOut,
                      )
                      .then()
                      .fadeOut(duration: 1500.ms),
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFEF4444),
                          Color(0xFFEC4899),
                        ],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF1a0a3e),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.red.withAlpha(128),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 20,
                      minHeight: 20,
                    ),
                    child: Center(
                      child: Text(
                        item.badgeCount.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                          .animate(onPlay: (controller) => controller.repeat())
                          .scale(
                            begin: const Offset(1, 1),
                            end: const Offset(1.2, 1.2),
                            duration: 500.ms,
                            curve: Curves.easeInOut,
                          )
                          .then(delay: 2000.ms)
                          .scale(
                            begin: const Offset(1.2, 1.2),
                            end: const Offset(1, 1),
                            duration: 500.ms,
                            curve: Curves.easeInOut,
                          ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  int? _getShopBadgeCount() {
    return ref.watch(shopBadgeCountProvider);
  }

  int? _getUpgradesBadgeCount() {
    return ref.watch(upgradesBadgeCountProvider);
  }

  int? _getAchievementsBadgeCount() {
    return ref.watch(achievementsBadgeCountProvider);
  }

  void _markAllAchievementsAsViewed() {
    final unlocked = ref.read(unlockedAchievementsProvider);
    final notificationNotifier = ref.read(notificationNotifierProvider);
    
    for (final achievementId in unlocked) {
      notificationNotifier.markAchievementAsViewed(achievementId);
    }
  }

  Widget _buildAccessToolbar() {
    final isMobile = GameConstants.isMobile(context);
    final isAudioPlaying = ref.watch(audioStateProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(
        isMobile ? 4 : 16,
        isMobile ? 4 : 16,
        isMobile ? 4 : 16,
        0,
      ),
      child: _buildAccessBarInner(isMobile, isAudioPlaying),
    );
  }

  Widget _buildAccessToolbarOverlay() {
    final isAudioPlaying = ref.watch(audioStateProvider);

    return SizedBox(
      width: 80,
      child: _buildAccessBarInner(false, isAudioPlaying),
    );
  }

  void _showVolumeControlDialog() {
    final isMobile = GameConstants.isMobile(context);

    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(100),
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(isMobile ? 16 : 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1a0a3e).withAlpha(242),
                    const Color(0xFF2d1b5e).withAlpha(242),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFA78BFA).withAlpha(128),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8B5CF6).withAlpha(128),
                    blurRadius: 40,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Consumer(
                builder: (context, ref, child) {
                  final volume = ref.watch(audioVolumeProvider);
                  final audioState = ref.watch(audioStateProvider);

                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFF22C55E),
                                      Color(0xFF14B8A6),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  audioState ? Icons.volume_up : Icons.volume_off,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Controle de Volume',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isMobile ? 18 : 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white70),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(
                              Icons.volume_off,
                              color: Colors.white70,
                              size: 28,
                            ),
                            onPressed: () {
                              ref.read(audioVolumeProvider.notifier).setVolume(0.01);
                              ref.read(audioStateProvider.notifier).setVolume(0.01);
                            },
                          ),
                          Expanded(
                            child: SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF22C55E),
                                inactiveTrackColor: Colors.grey.withAlpha(100),
                                thumbColor: const Color(0xFF22C55E),
                                overlayColor: const Color(0xFF22C55E).withAlpha(51),
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 12,
                                ),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: volume,
                                min: 0.01,
                                max: 1.0,
                                onChanged: (value) {
                                  ref.read(audioVolumeProvider.notifier).setVolume(value);
                                  ref.read(audioStateProvider.notifier).setVolume(value);
                                },
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.volume_up,
                              color: Colors.white70,
                              size: 28,
                            ),
                            onPressed: () {
                              ref.read(audioVolumeProvider.notifier).setVolume(1.0);
                              ref.read(audioStateProvider.notifier).setVolume(1.0);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${(volume * 100).toInt()}%',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 24 : 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {
                              ref.read(audioStateProvider.notifier).toggleAudio();
                            },
                            icon: Icon(
                              audioState ? Icons.volume_off : Icons.volume_up,
                              color: Colors.white,
                            ),
                            label: Text(
                              audioState ? 'Desativar' : 'Ativar',
                              style: const TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: audioState
                                  ? Colors.red.withAlpha(200)
                                  : const Color(0xFF22C55E).withAlpha(200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  final TextEditingController _codeController = TextEditingController();

  /// Constrói o conteúdo principal da tela
  Widget _buildMainContent() {
    final isMobile = GameConstants.isMobile(context);

    return SizedBox(
      width: double.infinity,
      child: Padding(
        padding: EdgeInsets.all(GameConstants.getDefaultPadding(context)),
        child: isMobile ? _buildMobileLayout() : _buildDesktopLayout(),
      ),
    );
  }

  /// Layout para mobile (coluna)
  Widget _buildMobileLayout() {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 8),
                _buildTitle(),
                const SizedBox(height: 4),
                _buildCounter(),
                const SizedBox(height: 4),
                Text(
                  '🌽 ${GameConstants.formatNumber(ref.watch(autoProductionProvider))}/s',
                  style: TextStyle(
                    fontSize: GameConstants.isMobile(context) ? 12 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                _buildDetailedMultipliers(ref),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _buildCakeButton(),
                    Align(
                      alignment: Alignment.centerRight,
                      child: _buildSupporterButton(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
        const Expanded(
          flex: 5,
          child: GeneratorSection(),
        ),
      ],
    );
  }

  final ScrollController _scrollController = ScrollController();

  /// Layout para desktop (row)
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildAccessToolbarOverlay(),
        const SizedBox(width: 20),
        // Lado esquerdo - Fubá e bolo
        Expanded(
          flex: 2,
          child: LayoutBuilder(builder: (context, constraints) {
            if (constraints.maxHeight > 600) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  _buildTitle(),
                  const SizedBox(height: 16),
                  _buildCounter(),
                  const SizedBox(height: 8),
                  Text(
                    '🌽 ${GameConstants.formatNumber(ref.watch(autoProductionProvider))}/s',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildDetailedMultipliers(ref),
                  const Spacer(),
                  _buildCakeButton(),
                  const Spacer(),
                ],
              );
            }
            return Scrollbar(
              controller: _scrollController,
              trackVisibility: true,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    _buildTitle(),
                    const SizedBox(height: 16),
                    _buildCounter(),
                    const SizedBox(height: 8),
                    Text(
                      '🌽 ${GameConstants.formatNumber(ref.watch(autoProductionProvider))}/s',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildDetailedMultipliers(ref),
                    const SizedBox(height: 20),
                    _buildCakeButton(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          }),
        ),
        const SizedBox(width: 20),
        // Meio - Barra de menus

        // Lado direito - Geradores
        const Expanded(flex: 3, child: GeneratorSection()),
      ],
    );
  }

  /// Constrói o título do jogo
  Widget _buildTitle() {
    return const Text(
      'FUBÁ',
      style: TextStyle(
        // fontSize: GameConstants.getTitleFontSize(context) + 6,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Constrói o contador de fubá com animação
  Widget _buildCounter() {
    return Text(
      GameConstants.formatNumber(ref.watch(fubaProvider)),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: GameConstants.getCounterFontSize(context),
        fontWeight: FontWeight.bold,
      ),
    )
        .animate(
          autoPlay: true,
          onComplete: (controller) => controller.repeat(),
        )
        .shimmer(
          delay: 1.seconds,
          duration: 10.seconds,
          color: Colors.deepOrangeAccent.withAlpha(100),
          curve: Curves.decelerate,
        );
  }

  /// Constrói o botão do bolo clicável
  Widget _buildCakeButton() {
    final isMobile = GameConstants.isMobile(context);
    final equippedIds = ref.watch(equippedAccessoriesProvider);
    final equippedAccessories = equippedIds
        .map((id) => allAccessories.firstWhere((acc) => acc.id == id))
        .toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        if (equippedAccessories.isNotEmpty)
          FloatingAccessories(
            accessories: equippedAccessories,
            centerSize: isMobile ? 200 : 150,
          ),
        InkWell(
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          onTap: _handleCakeClick,
          child: SizedBox(
            width: isMobile ? 120 : 150,
            height: isMobile ? 120 : 150,
            child: CakeDisplay(
              accessories: equippedAccessories,
              size: isMobile ? 200 : 150,
              animationController: _animationController,
            ),
          ),
        ),
      ],
    );
  }

  /// Manipula o clique no bolo
  void _handleCakeClick() {
    final disableAnimations = ref.read(disableAnimationsProvider);

    if (!disableAnimations) {
      _animationController
          .forward()
          .then((_) => _animationController.reverse());
    }

    final isAudioEnabled = ref.read(audioStateProvider);
    if (isAudioEnabled) {
      ref.read(clickSoundNotifierProvider).playClickSound();
    }

    final clickMultiplier =
        ref.read(upgradeNotifierProvider).getClickMultiplier();
    final achievementMultiplier = ref.watch(achievementMultiplierProvider);
    final accessoryMultiplier = ref.read(accessoryMultiplierProvider);
    final rebirthMultiplier = ref.read(rebirthMultiplierProvider);
    final oneTimeMultiplier = ref.read(oneTimeMultiplierProvider);
    final potionClickPower = ref.read(potionClickPowerProvider);

    final potionClickPowerEfficient =
        EfficientNumber.fromValues(potionClickPower, 0);

    final totalClickMultiplier = clickMultiplier *
        achievementMultiplier *
        accessoryMultiplier *
        rebirthMultiplier *
        oneTimeMultiplier *
        potionClickPowerEfficient;

    final clickValue = totalClickMultiplier;

    ref.read(fubaProvider.notifier).state += clickValue;

    // Rastreamento de cliques para conquistas
    _updateClickTracking(clickValue);
    _updateSecretAchievementTracking(clickValue);

    ref
        .read(achievementNotifierProvider)
        .incrementStat('total_clicks', 1, context);
    ref
        .read(achievementNotifierProvider)
        .incrementStat('total_production', clickValue.toDouble(), context);
  }

  /// Atualiza o rastreamento de cliques para conquistas
  void _updateClickTracking(EfficientNumber clickValue) {
    final now = DateTime.now();

    // Calcular velocidade de cliques (cliques por segundo)
    final timeDiff = now.difference(_lastClickTime).inMilliseconds;
    if (timeDiff > 0) {
      final clicksPerSecond = 1000 / timeDiff;
      ref
          .read(achievementNotifierProvider)
          .updateClickSpeed(clicksPerSecond, context);
    }

    // Atualizar sequência de cliques
    final streakTimeDiff = now.difference(_lastStreakTime).inMilliseconds;
    if (streakTimeDiff < 2000) {
      // 2 segundos para manter a sequência
      _currentStreak++;
    } else {
      _currentStreak = 1;
    }
    _lastStreakTime = now;
    ref
        .read(achievementNotifierProvider)
        .updateClickStreak(_currentStreak.toDouble(), context);

    // Atualizar eficiência (fubá por clique)
    ref
        .read(achievementNotifierProvider)
        .updateFubaPerClick(clickValue.toDouble(), context);

    _lastClickTime = now;
  }

  /// Atualiza o rastreamento para conquistas secretas
  void _updateSecretAchievementTracking(EfficientNumber clickValue) {
    final now = DateTime.now();

    // Atualizar lista de cliques para verificar cliques em 10 segundos
    _clickTimes.add(now);
    _clickTimes.removeWhere((time) => now.difference(time).inSeconds > 10);

    // Atualizar estatística de cliques em 10 segundos
    ref
        .read(achievementNotifierProvider)
        .updateClicksIn10Seconds(_clickTimes.length.toDouble(), context);

    // Atualizar fubá total obtido por cliques
    _totalClickFuba += clickValue.toDouble();
    ref
        .read(achievementNotifierProvider)
        .updateTotalClickFuba(_totalClickFuba, context);

    // Atualizar tempo do último clique para conquista zen
    _lastClickTimeForZen = now;

    // Reiniciar timer de paciência
    _patienceTimer?.cancel();
    _patienceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final timeSinceClick = now.difference(_lastClickTime).inSeconds;
      ref
          .read(achievementNotifierProvider)
          .updateTimeSinceLastClick(timeSinceClick.toDouble(), context);
    });
  }

  /// Inicia o rastreamento de tempo de jogo consecutivo
  void _startPlayTimeTracking() {
    _consolidatedAchievementTimer =
        Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final playTime = now.difference(_appStartTime).inSeconds;

      ref
          .read(achievementNotifierProvider)
          .updateConsecutivePlayTime(playTime.toDouble(), context);

      // Verificar tempo sem clicar para conquista zen
      final timeSinceLastClick = now.difference(_lastClickTimeForZen).inSeconds;
      ref
          .read(achievementNotifierProvider)
          .updateTimeWithoutClicking(timeSinceLastClick.toDouble(), context);
    });
  }

  /// Processa cliques automáticos para conquistas
  void _processAutoClicks(double clickRate, double totalValue) {
    if (!clickRate.isFinite || clickRate.isNaN || clickRate < 0) {
      return;
    }

    if (!totalValue.isFinite || totalValue.isNaN) {
      return;
    }

    final safeClickRate =
        clickRate.isInfinite || clickRate.isNaN ? 0.0 : clickRate;

    final safeTotalValue =
        totalValue.isInfinite || totalValue.isNaN ? 0.0 : totalValue;

    ref
        .read(achievementNotifierProvider)
        .incrementStat('total_clicks', safeClickRate, context);

    if (GameConstants.autoProductionInterval.inMilliseconds > 0) {
      final clicksPerSecond = safeClickRate /
          (GameConstants.autoProductionInterval.inMilliseconds / 1000);
      if (clicksPerSecond.isFinite && !clicksPerSecond.isNaN) {
        ref
            .read(achievementNotifierProvider)
            .updateClickSpeed(clicksPerSecond, context);
      }
    }

    final safeIntClickRate = (safeClickRate > 0 && safeClickRate.isFinite)
        ? safeClickRate.clamp(0, 1e6).toInt()
        : 0;
    _currentStreak += safeIntClickRate;
    _lastStreakTime = DateTime.now();

    if (_currentStreak.isFinite && !_currentStreak.isNaN) {
      ref
          .read(achievementNotifierProvider)
          .updateClickStreak(_currentStreak.toDouble(), context);
    }

    if (safeClickRate > 0 && safeClickRate.isFinite) {
      final fubaPerClick = safeTotalValue / safeClickRate;
      if (fubaPerClick.isFinite && !fubaPerClick.isNaN) {
        ref
            .read(achievementNotifierProvider)
            .updateFubaPerClick(fubaPerClick, context);
      }
    }
  }

  Widget _buildDetailedMultipliers(WidgetRef ref) {
    final totalMultiplier = ref.watch(totalMultiplierProvider);
    final achievementMultiplier = ref.watch(achievementMultiplierProvider);
    final rebirthMultiplier = ref.watch(rebirthMultiplierProvider);
    final upgradeMultiplier = ref.watch(upgradeProductionMultiplierProvider);
    final accessoryMultiplier = ref.watch(accessoryMultiplierProvider);
    final oneTimeMultiplier = ref.watch(oneTimeMultiplierProvider);
    final equippedIds = ref.watch(equippedAccessoriesProvider);

    final manualTotal = accessoryMultiplier *
        rebirthMultiplier *
        upgradeMultiplier *
        achievementMultiplier *
        oneTimeMultiplier;

    return Column(
      children: [
        const SizedBox(height: 5),
        Text(
          'Multiplicador Total: x${GameConstants.formatNumber(totalMultiplier)}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (kDebugMode)
          Wrap(
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Mostrar diálogo de confirmação
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('⚠️ WIPE ALL DATA'),
                      content: const Text(
                        'Esta ação irá EXCLUIR PERMANENTEMENTE todos os seus dados do jogo!\n\n'
                        'Isso inclui:\n'
                        '• Todo o fubá\n'
                        '• Todos os geradores\n'
                        '• Todos os acessórios\n'
                        '• Todas as conquistas\n'
                        '• Todos os upgrades\n'
                        '• Todos os rebirths\n\n'
                        'Esta ação NÃO PODE ser desfeita!\n\n'
                        'Tem certeza que deseja continuar?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('SIM, EXCLUIR TUDO'),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true) {
                    // Limpar todos os providers
                    ref.read(fubaProvider.notifier).state =
                        const EfficientNumber.zero();
                    ref.read(generatorsProvider.notifier).state = List.filled(
                      availableGenerators.length,
                      0,
                    );
                    ref.read(inventoryProvider.notifier).state =
                        <String, int>{};
                    ref.read(equippedAccessoriesProvider.notifier).state =
                        <String>[];
                    ref.read(rebirthDataProvider.notifier).state =
                        const RebirthData();
                    ref.read(unlockedAchievementsProvider.notifier).state =
                        <String>[];
                    ref.read(achievementStatsProvider.notifier).state =
                        <String, double>{};
                    ref.read(upgradesLevelProvider.notifier).state =
                        <String, int>{};
                    ref.read(forusUpgradesOwnedProvider.notifier).state =
                        <String>{};
                    ref.read(cauldronProvider.notifier).state =
                        <PotionColor, int>{};
                    ref.read(activePotionEffectsProvider.notifier).state =
                        <PotionEffect>[];
                    ref.read(permanentPotionMultiplierProvider.notifier).state =
                        1.0;
                    ref.read(activePotionCountProvider.notifier).state =
                        <String, int>{};

                    // Limpar dados salvos
                    final saveService = SaveService();
                    await saveService.clearSave();

                    // Salvar imediatamente para garantir que tudo foi limpo
                    await ref
                        .read(saveNotifierProvider.notifier)
                        .saveImmediate();

                    // Mostrar confirmação
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('✅ Todos os dados foram excluídos!'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Wipe All Data'),
              ),
              ElevatedButton(
                onPressed: () {
                  ref.read(fubaProvider.notifier).state *=
                      EfficientNumber.parse('1e90');
                },
                child: const Text('mult'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final newGenerators = List.generate(
                    availableGenerators.length,
                    (index) => 1000,
                  );
                  ref.read(generatorsProvider.notifier).state = newGenerators;
                  ref.read(saveNotifierProvider.notifier).saveImmediate();
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('1000 gen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  final newGenerators = List.generate(
                    availableGenerators.length,
                    (index) => 1,
                  );
                  ref.read(generatorsProvider.notifier).state = newGenerators;
                  ref.read(saveNotifierProvider.notifier).saveImmediate();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('+1 de todos os geradores adicionados'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                icon: const Icon(Icons.add_circle),
                label: const Text('1 gen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        const SizedBox(height: 5),
        if (totalMultiplier.compareTo(const EfficientNumber.one()) > 0) ...[
          const SizedBox(height: 4),
          _buildEquippedAccessories(equippedIds),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 2,
            children: [
              if (achievementMultiplier.compareTo(const EfficientNumber.one()) >
                  0)
                Text(
                  '🏆 x${achievementMultiplier.toDouble().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (rebirthMultiplier.compareTo(const EfficientNumber.one()) > 0)
                Text(
                  '🔄 x${GameConstants.formatNumber(rebirthMultiplier)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (upgradeMultiplier.compareTo(const EfficientNumber.one()) > 0)
                Text(
                  '⚡ x${upgradeMultiplier.toDouble().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (oneTimeMultiplier.compareTo(const EfficientNumber.one()) > 0)
                Text(
                  '💎 x${oneTimeMultiplier.toDouble().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.purple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildEquippedAccessories(List<String> equippedIds) {
    if (equippedIds.isEmpty) {
      return const SizedBox.shrink();
    }

    final accessoryList = equippedIds
        .map((id) => allAccessories.firstWhere((acc) => acc.id == id))
        .toList();

    final Map<String, int> groupedAccessories = {};
    final Map<String, dynamic> accessoryData = {};

    for (int i = 0; i < accessoryList.length; i++) {
      final accessory = accessoryList[i];

      final key =
          '${accessory.emoji}_${accessory.productionMultiplier.toStringAsFixed(2)}';
      groupedAccessories[key] = (groupedAccessories[key] ?? 0) + 1;

      if (!accessoryData.containsKey(key)) {
        accessoryData[key] = {
          'emoji': accessory.emoji,
          'multiplier': accessory.productionMultiplier,
          'rarity': accessory.rarity,
        };
      }
    }

    final Map<String, double> effectiveMultipliers = {};
    for (final entry in groupedAccessories.entries) {
      final key = entry.key;
      final count = entry.value;
      final accessory = accessoryList.firstWhere(
        (acc) =>
            '${acc.emoji}_${acc.productionMultiplier.toStringAsFixed(2)}' ==
            key,
      );

      double totalEffectiveMultiplier = 1.0;
      for (int i = 0; i < count; i++) {
        totalEffectiveMultiplier *= accessory.productionMultiplier;
      }

      effectiveMultipliers[key] = totalEffectiveMultiplier;
    }

    final sortedKeys = groupedAccessories.keys.toList()
      ..sort((a, b) {
        final dataA = accessoryData[a]!;
        final dataB = accessoryData[b]!;
        return dataB['multiplier'].compareTo(dataA['multiplier']);
      });

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: sortedKeys.map((key) {
        final count = groupedAccessories[key]!;
        final data = accessoryData[key]!;
        final totalEffectiveMultiplier = effectiveMultipliers[key]!;
        final accessory = accessoryList.firstWhere(
          (acc) =>
              acc.emoji == data['emoji'] &&
              acc.productionMultiplier == data['multiplier'],
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: accessory.rarity.color.withAlpha(50),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: accessory.rarity.color.withAlpha(150),
              width: 1,
            ),
          ),
          child: Text(
            count > 1
                ? '${data['emoji']} x${GameConstants.formatNumber(EfficientNumber.fromDouble(totalEffectiveMultiplier))} (x$count)'
                : '${data['emoji']} x${totalEffectiveMultiplier.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 10,
              color: accessory.rarity.color,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSupporterButton() {
    return InkWell(
      onTap: _showSupporterDialog,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 240, 132, 10),
                  Color.fromARGB(255, 219, 111, 9),
                  Color.fromARGB(255, 181, 96, 63)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(255, 207, 53, 6).withAlpha(100),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.favorite, color: Colors.white, size: 20),
          )
              .animate(
                autoPlay: true,
                onComplete: (controller) => controller.repeat(),
              )
              .shimmer(
                delay: 3.seconds,
                duration: 5.seconds,
                color: Colors.white.withAlpha(100),
              ),
          const SizedBox(height: 4),
          const Text(
            'Fubádor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _showSupporterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withAlpha(240),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.purple.withAlpha(150), width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.pink, size: 28),
            SizedBox(width: 8),
            Text(
              'Apoie o Fubá',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Se você está gostando do Fubá Clicker, considere apoiar o desenvolvimento!',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withAlpha(100),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.qr_code, color: Colors.green, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Chave PIX:',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Aqui você pode implementar a funcionalidade de copiar
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Chave PIX copiada!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(100),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withAlpha(150),
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'tekboxs@gmail.com',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withAlpha(150),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            'assets/images/qrcode.png',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.withAlpha(100),
                                child: const Icon(
                                  Icons.qr_code,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Qualquer valor é bem-vindo e ajuda muito no desenvolvimento!\nEntre em contato para receber conteudo excluivo caso deseje se tornar um apoiador',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    decoration: const InputDecoration(
                      hintText: 'Código',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                Consumer(
                  builder: (context, ref, child) {
                    return IconButton(
                      onPressed: () {
                        final code = _codeController.text;
                        if (code == 'ivi100') {
                          final rebirthData = ref.read(rebirthDataProvider);

                          if (rebirthData.usedCoupons.contains('ivi100')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Este cupom já foi usado!'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          ref.read(rebirthDataProvider.notifier).state =
                              rebirthData.copyWith(
                            hasUsedOneTimeMultiplier: true,
                            usedCoupons: [...rebirthData.usedCoupons, 'ivi100'],
                          );

                          ref
                              .read(saveNotifierProvider.notifier)
                              .saveImmediate();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Multiplicador x100 ativado!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );

                          Navigator.of(context).pop();
                        } else if (code == 'milkyde4') {
                          final rebirthData = ref.read(rebirthDataProvider);

                          if (rebirthData.usedCoupons.contains('milkyde4')) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Este cupom já foi usado!'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          ref.read(rebirthDataProvider.notifier).state =
                              rebirthData.copyWith(
                            celestialTokens: rebirthData.celestialTokens + 8.0,
                            usedCoupons: [
                              ...rebirthData.usedCoupons,
                              'milkyde4',
                            ],
                          );

                          ref
                              .read(saveNotifierProvider.notifier)
                              .saveImmediate();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                '✅ 8 Tokens Celestiais adicionados! 💎',
                              ),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );

                          Navigator.of(context).pop();
                        } else if (code == 'oliveiralindo') {
                          final rebirthData = ref.read(rebirthDataProvider);

                          if (rebirthData.usedCoupons.contains(
                            'oliveiralindo',
                          )) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('❌ Este cupom já foi usado!'),
                                backgroundColor: Colors.red,
                                duration: Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          ref.read(rebirthDataProvider.notifier).state =
                              rebirthData.copyWith(
                            celestialTokens: rebirthData.celestialTokens + 69,
                            usedCoupons: [
                              ...rebirthData.usedCoupons,
                              'oliveiralindo',
                            ],
                          );

                          ref
                              .read(saveNotifierProvider.notifier)
                              .saveImmediate();

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ 69 Diamantes adicionados! 💎'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                            ),
                          );

                          Navigator.of(context).pop();
                        } else if (code == 'fubaadm') {
                          // final rebirthData = ref.read(rebirthDataProvider);

                          // if (rebirthData.usedCoupons.contains('fubaadm')) {
                          //   ScaffoldMessenger.of(context).showSnackBar(
                          //     const SnackBar(
                          //       content: Text('❌ Este cupom já foi usado!'),
                          //       backgroundColor: Colors.red,
                          //       duration: Duration(seconds: 3),
                          //     ),
                          //   );
                          //   return;
                          // }

                          // ref.read(rebirthDataProvider.notifier).state =
                          //     rebirthData.copyWith(
                          //   hasUsedOneTimeMultiplier: true,
                          //   usedCoupons: [
                          //     ...rebirthData.usedCoupons,
                          //     'fubaadm',
                          //   ],
                          // );

                          // ref
                          //     .read(saveNotifierProvider.notifier)
                          //     .saveImmediate();

                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   const SnackBar(
                          //     content:
                          //         Text('✅ Multiplicador x99999 ativado! 🚀'),
                          //     backgroundColor: Colors.green,
                          //     duration: Duration(seconds: 3),
                          //   ),
                          // );

                          // Navigator.of(context).pop();
                        }
                        // if (code.isNotEmpty) {
                        //   final saveData = SaveService.restoreFromBackupCode(
                        //     code,
                        //   );
                        //   if (saveData != null) {
                        //     ref.read(saveProvider.notifier).state = saveData;
                        //   }
                        // }
                      },
                      icon: const Icon(
                        Icons.confirmation_num,
                        color: Colors.white,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fechar',
              style: TextStyle(
                color: Colors.purple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPerformanceModeDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withAlpha(240),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: Colors.orange.withAlpha(150), width: 2),
        ),
        title: const Row(
          children: [
            Icon(Icons.settings, color: Colors.orange, size: 28),
            SizedBox(width: 8),
            Text(
              'Modo Performance',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configurações para otimizar performance em produção:',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 20),
            Consumer(
              builder: (context, ref, child) {
                final visualSettings = ref.watch(visualSettingsProvider);
                final isPerformanceMode = visualSettings.isPerformanceMode;

                return Column(
                  children: [
                    SwitchListTile(
                      title: const Text(
                        'Modo Performance Completo',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Desabilita todas as animações e efeitos',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                      value: isPerformanceMode,
                      onChanged: (value) {
                        if (value) {
                          ref
                              .read(visualSettingsProvider.notifier)
                              .enablePerformanceMode();
                        } else {
                          ref
                              .read(visualSettingsProvider.notifier)
                              .disablePerformanceMode();
                        }
                      },
                      activeThumbColor: Colors.orange,
                    ),
                    const Divider(color: Colors.white24),
                    SwitchListTile(
                      title: const Text(
                        'Desabilitar Animações',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      value: visualSettings.disableAnimations,
                      onChanged: (value) {
                        ref
                            .read(visualSettingsProvider.notifier)
                            .toggleAnimation();
                      },
                      activeThumbColor: Colors.orange,
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Desabilitar Partículas',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      value: visualSettings.disableParticles,
                      onChanged: (value) {
                        ref
                            .read(visualSettingsProvider.notifier)
                            .toggleParticles();
                      },
                      activeThumbColor: Colors.orange,
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Desabilitar Paralaxe',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      value: visualSettings.disableParallax,
                      onChanged: (value) {
                        ref
                            .read(visualSettingsProvider.notifier)
                            .toggleParallax();
                      },
                      activeThumbColor: Colors.orange,
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Desabilitar Efeitos',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      value: visualSettings.disableEffects,
                      onChanged: (value) {
                        ref
                            .read(visualSettingsProvider.notifier)
                            .toggleEffects();
                      },
                      activeThumbColor: Colors.orange,
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Modo Baixa Qualidade',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      value: visualSettings.lowQualityMode,
                      onChanged: (value) {
                        ref
                            .read(visualSettingsProvider.notifier)
                            .toggleLowQuality();
                      },
                      activeThumbColor: Colors.orange,
                    ),
                    SwitchListTile(
                      title: const Text(
                        'Ocultar Acessórios',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      value: visualSettings.hideAccessories,
                      onChanged: (value) {
                        ref
                            .read(visualSettingsProvider.notifier)
                            .toggleAccessories();
                      },
                      activeThumbColor: Colors.orange,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estas configurações são salvas automaticamente e ajudam a melhorar a performance em dispositivos mais lentos.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Fechar',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showTestAchievementPopup() {
    final achievementIds = [
      'first_click',
      'click_100',
      'production_1k',
      'first_generator',
      'first_accessory',
      'accessory_legendary',
      'lootbox_10',
      'first_rebirth',
    ];

    final randomId = achievementIds[
        (DateTime.now().millisecondsSinceEpoch % achievementIds.length)];
    final achievement = allAchievements.firstWhere((a) => a.id == randomId);

    AchievementPopupManager.showAchievementPopup(context, achievement);
  }

  void _showAccountSettings() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const AccountSettings(),
        ),
      ),
    );
  }
}
