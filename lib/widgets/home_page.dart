import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import 'package:fuba_clicker/providers/save_provider.dart';
import '../providers/game_providers.dart';
import '../providers/audio_provider.dart';
import '../providers/accessory_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/rebirth_upgrade_provider.dart';
import '../providers/rebirth_provider.dart';
import '../providers/secret_provider.dart';
import '../services/save_service.dart';
import '../models/achievement.dart';
import '../models/cake_accessory.dart';
import '../models/fuba_generator.dart';
import '../models/rebirth_data.dart';
import '../utils/constants.dart';
import 'generator_section.dart';
import 'parallax_background.dart';
import 'loot_box_shop.dart';
import 'floating_accessories.dart';
import 'cake_display.dart';
import 'rebirth_page.dart';
import 'achievements_page.dart';
import 'rebirth_upgrades_page.dart';
import 'achievement_popup.dart';

BigDecimal _safeParseMultiplier(double value) {
  if (value.isInfinite || value.isNaN) {
    return BigDecimal.parse('1e50');
  }
  return BigDecimal.parse(value.toString());
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
  Timer? _playTimeTimer;
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
      ref.read(audioStateProvider.notifier);
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
          final autoClickerRate = ref
              .read(upgradeNotifierProvider)
              .getAutoClickerRate();

          BigDecimal totalProduction = autoProduction;

          if (autoClickerRate > 0) {
            final clickMultiplier = ref
                .read(upgradeNotifierProvider)
                .getClickMultiplier();
            final achievementMultiplier = ref.watch(
              achievementMultiplierProvider,
            );
            final accessoryMultiplier = ref.read(accessoryMultiplierProvider);
            final rebirthMultiplier = ref.read(rebirthMultiplierProvider);
            final oneTimeMultiplier = ref.read(oneTimeMultiplierProvider);

            final totalClickMultiplier =
                clickMultiplier *
                achievementMultiplier *
                accessoryMultiplier *
                rebirthMultiplier *
                oneTimeMultiplier;

            final autoClickValue = autoClickerRate * totalClickMultiplier;
            if (autoClickValue.isFinite) {
              totalProduction += BigDecimal.parse(autoClickValue.toString());
            }

            // Contar cliques automáticos para conquistas
            _processAutoClicks(autoClickerRate, autoClickValue);
          }

          if (totalProduction.compareTo(BigDecimal.zero) > 0) {
            ref.read(fubaProvider.notifier).update((state) {
              return state + totalProduction;
            });

            ref
                .read(achievementNotifierProvider)
                .incrementStat(
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
    _playTimeTimer?.cancel();
    _animationController.dispose();
    _parallaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            ParallaxBackground(parallaxController: _parallaxController),
            _buildMainContent(),

            _buildTopRightButtons(),
            _buildTopLeftButtons(),
          ],
        ),
      ),
      floatingActionButton: _buildSupporterButton(),
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
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 35),
        const SizedBox(height: 4),
        _buildTitle(),
        const SizedBox(height: 2),
        _buildCounter(),
        const SizedBox(height: 2),
        Text(
          '🌽 ${GameConstants.formatNumber(ref.watch(autoProductionProvider))}/s',
          style: TextStyle(
            fontSize: GameConstants.isMobile(context) ? 12 : 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        _buildDetailedMultipliers(ref),
        const SizedBox(height: 4),
        _buildCakeButton(),
        const SizedBox(height: 8),
        Expanded(child: GeneratorSection()),
      ],
    );
  }

  /// Layout para desktop (row)
  Widget _buildDesktopLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lado esquerdo - Fubá e bolo
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
        ),
        const SizedBox(width: 20),
        // Lado direito - Geradores
        Expanded(flex: 3, child: GeneratorSection()),
      ],
    );
  }

  /// Constrói o título do jogo
  Widget _buildTitle() {
    return Text(
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
    _animationController.forward().then((_) => _animationController.reverse());

    final isAudioEnabled = ref.read(audioStateProvider);
    if (isAudioEnabled) {
      ref.read(clickSoundNotifierProvider).playClickSound();
    }

    final clickMultiplier = ref
        .read(upgradeNotifierProvider)
        .getClickMultiplier();
    final achievementMultiplier = ref.watch(achievementMultiplierProvider);
    final accessoryMultiplier = ref.read(accessoryMultiplierProvider);
    final rebirthMultiplier = ref.read(rebirthMultiplierProvider);
    final oneTimeMultiplier = ref.read(oneTimeMultiplierProvider);

    final totalClickMultiplier =
        clickMultiplier *
        achievementMultiplier *
        accessoryMultiplier *
        rebirthMultiplier *
        oneTimeMultiplier;

    final clickValue = 1 * totalClickMultiplier;

    if (clickValue.isFinite) {
      ref.read(fubaProvider.notifier).state += _safeParseMultiplier(clickValue);
    }

    // Rastreamento de cliques para conquistas
    _updateClickTracking(clickValue);
    _updateSecretAchievementTracking(clickValue);

    ref
        .read(achievementNotifierProvider)
        .incrementStat('total_clicks', 1, context);
    ref
        .read(achievementNotifierProvider)
        .incrementStat('total_production', clickValue, context);
  }

  /// Atualiza o rastreamento de cliques para conquistas
  void _updateClickTracking(double clickValue) {
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
        .updateFubaPerClick(clickValue, context);

    _lastClickTime = now;
  }

  /// Atualiza o rastreamento para conquistas secretas
  void _updateSecretAchievementTracking(double clickValue) {
    final now = DateTime.now();

    // Atualizar lista de cliques para verificar cliques em 10 segundos
    _clickTimes.add(now);
    _clickTimes.removeWhere((time) => now.difference(time).inSeconds > 10);

    // Atualizar estatística de cliques em 10 segundos
    ref
        .read(achievementNotifierProvider)
        .updateClicksIn10Seconds(_clickTimes.length.toDouble(), context);

    // Atualizar fubá total obtido por cliques
    _totalClickFuba += clickValue;
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
    _playTimeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
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
    // Incrementar contador total de cliques
    ref
        .read(achievementNotifierProvider)
        .incrementStat('total_clicks', clickRate, context);

    // Calcular velocidade de cliques automáticos (cliques por segundo)
    final clicksPerSecond =
        clickRate /
        (GameConstants.autoProductionInterval.inMilliseconds / 1000);
    ref
        .read(achievementNotifierProvider)
        .updateClickSpeed(clicksPerSecond, context);

    // Atualizar sequência de cliques (auto clicks mantêm a sequência)
    _currentStreak += clickRate.toInt();
    _lastStreakTime = DateTime.now(); // Atualizar tempo da sequência
    ref
        .read(achievementNotifierProvider)
        .updateClickStreak(_currentStreak.toDouble(), context);

    // Atualizar eficiência (fubá por clique)
    final fubaPerClick = totalValue / clickRate;
    ref
        .read(achievementNotifierProvider)
        .updateFubaPerClick(fubaPerClick, context);
  }

  Widget _buildDetailedMultipliers(WidgetRef ref) {
    final totalMultiplier = ref.watch(totalMultiplierProvider);
    final achievementMultiplier = ref.watch(achievementMultiplierProvider);
    final rebirthMultiplier = ref.watch(rebirthMultiplierProvider);
    final upgradeMultiplier = ref.watch(upgradeProductionMultiplierProvider);
    final accessoryMultiplier = ref.watch(accessoryMultiplierProvider);
    final oneTimeMultiplier = ref.watch(oneTimeMultiplierProvider);
    final equippedIds = ref.watch(equippedAccessoriesProvider);

    final manualTotal =
        accessoryMultiplier *
        rebirthMultiplier *
        upgradeMultiplier *
        achievementMultiplier *
        oneTimeMultiplier;

    return Column(
      children: [
        const SizedBox(height: 5),

        Text(
          'Multiplicador Total: x${GameConstants.formatNumber(_safeParseMultiplier(totalMultiplier))}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (kDebugMode) ...[
          ElevatedButton(
            onPressed: () {
              _showTestAchievementPopup();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            child: const Text('Test Achievement Popup'),
          ),
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
                ref.read(fubaProvider.notifier).state = BigDecimal.zero;
                ref.read(generatorsProvider.notifier).state = List.filled(
                  availableGenerators.length,
                  0,
                );
                ref.read(inventoryProvider.notifier).state = <String, int>{};
                ref.read(equippedAccessoriesProvider.notifier).state =
                    <String>[];
                ref.read(rebirthDataProvider.notifier).state =
                    const RebirthData();
                ref.read(unlockedAchievementsProvider.notifier).state =
                    <String>{};
                ref.read(achievementStatsProvider.notifier).state =
                    <String, double>{};
                ref.read(upgradesLevelProvider.notifier).state =
                    <String, int>{};
                ref.read(unlockedSecretsProvider.notifier).state = <String>{};

                // Limpar dados salvos
                final saveService = SaveService();
                await saveService.clearSave();

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
              ref.read(fubaProvider.notifier).state *= BigDecimal.parse('1e90');
            },
            child: const Text('mult'),
          ),
          Text(
            'Debug Manual: x${manualTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Acessórios: x${accessoryMultiplier.toStringAsFixed(2)} | Rebirth: x${rebirthMultiplier.toStringAsFixed(2)} | Upgrade: x${upgradeMultiplier.toStringAsFixed(2)} | Conquistas: x${achievementMultiplier.toStringAsFixed(2)} | Único: x${oneTimeMultiplier.toStringAsFixed(2)}',
            style: const TextStyle(fontSize: 8, color: Colors.grey),
          ),
          Text(
            'IDs Equipados: ${equippedIds.join(", ")}',
            style: const TextStyle(fontSize: 8, color: Colors.yellow),
          ),
        ],
        const SizedBox(height: 5),
        if (totalMultiplier > 1) ...[
          const SizedBox(height: 4),
          _buildEquippedAccessories(equippedIds),
          const SizedBox(height: 4),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 2,
            children: [
              if (achievementMultiplier > 1)
                Text(
                  '🏆 x${achievementMultiplier.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (rebirthMultiplier > 1)
                Text(
                  '🔄 x${GameConstants.formatNumber(BigDecimal.parse(rebirthMultiplier.toStringAsFixed(2)))}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (upgradeMultiplier > 1)
                Text(
                  '⚡ x${upgradeMultiplier.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (oneTimeMultiplier > 1)
                Text(
                  '💎 x${oneTimeMultiplier.toStringAsFixed(2)}',
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

    accessoryList.sort(
      (a, b) => b.productionMultiplier.compareTo(a.productionMultiplier),
    );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: accessoryList.map((accessory) {
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
            '${accessory.emoji} x${accessory.productionMultiplier.toStringAsFixed(2)}',
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

  int counter = 0;

  Widget _buildTopRightButtons() {
    final isAudioPlaying = ref.watch(audioStateProvider);
    final isMobile = GameConstants.isMobile(context);

    return Positioned(
      top: isMobile ? 4 : 16,
      right: isMobile ? 4 : null,
      left: isMobile ? null : MediaQuery.of(context).size.width / 2 - 250,
      child: Row(
        children: [
          _buildIconButtonWithLabel(
            Icons.emoji_events,
            Colors.amber,
            'Conquistas',
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AchievementsPage(),
                ),
              );
            },
          ),
          SizedBox(width: isMobile ? 4 : 8),
          _buildIconButtonWithLabel(
            isAudioPlaying ? Icons.volume_up : Icons.volume_off,
            isAudioPlaying ? Colors.orange : Colors.grey,
            'Som',
            () {
              counter++;
              if (counter == 0 || counter == 4) {
                ref.read(audioStateProvider.notifier).toggleAudio();
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(
                    counter > 1
                        ? counter > 2
                              ? counter > 3
                                    ? 'Agora fica sem musica tmb infeliz >:('
                                    : 'Aproveita a obra de arte'
                              : 'Tem certeza que vai perder a obra de arte?'
                        : 'Escute a musica do bolo de fuba ;-;',
                    style: TextStyle(color: Colors.white),
                  ),

                  backgroundColor: Colors.red,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTopLeftButtons() {
    final isMobile = GameConstants.isMobile(context);

    return Positioned(
      top: isMobile ? 4 : 16,
      left: isMobile ? 4 : 16,
      child: Column(
        children: [
          Row(
            children: [
              _buildIconButtonWithLabel(
                Icons.shopping_bag,
                Colors.white,
                'Loja',
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LootBoxShopPage(),
                    ),
                  );
                },
              ),
              SizedBox(width: isMobile ? 4 : 8),
              _buildIconButtonWithLabel(
                Icons.auto_awesome,
                const Color.fromARGB(255, 141, 157, 248),
                'Upgrades',
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RebirthUpgradesPage(),
                    ),
                  );
                },
              ),
              SizedBox(width: isMobile ? 4 : 8),
              _buildIconButtonWithLabel(
                Icons.refresh,
                const Color.fromARGB(255, 255, 35, 35),
                'Rebirth',
                () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const RebirthPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    final isMobile = GameConstants.isMobile(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(isMobile ? 20 : 25),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: IconButton(
        iconSize: isMobile ? 20 : 24,
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildIconButtonWithLabel(
    IconData icon,
    Color color,
    String label,
    VoidCallback onPressed,
  ) {
    final isMobile = GameConstants.isMobile(context);

    if (isMobile) {
      return Tooltip(
        message: label,
        child: _buildIconButton(icon, color, onPressed),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildIconButton(icon, color, onPressed),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSupporterButton() {
    return InkWell(
      onTap: _showSupporterDialog,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.deepPurple, Colors.indigo],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withAlpha(100),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(Icons.favorite, color: Colors.white, size: 28),
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
          const SizedBox(height: 10),
          Text(
            'Fubádor',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
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
        title: Row(
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
            Text(
              'Se você está gostando do Fubá Clicker, considere apoiar o desenvolvimento!',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.all(16),
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
                  Row(
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
                  SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Aqui você pode implementar a funcionalidade de copiar
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Chave PIX copiada!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(100),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.green.withAlpha(150),
                                width: 1,
                              ),
                            ),
                            child: Text(
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
                      SizedBox(width: 12),
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
                                child: Icon(
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
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
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
                    decoration: InputDecoration(
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

                          ref
                              .read(rebirthDataProvider.notifier)
                              .state = rebirthData.copyWith(
                            hasUsedOneTimeMultiplier: true,
                            usedCoupons: {...rebirthData.usedCoupons, 'ivi100'},
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

                          ref
                              .read(rebirthDataProvider.notifier)
                              .state = rebirthData.copyWith(
                            celestialTokens: rebirthData.celestialTokens + 8.0,
                            usedCoupons: {
                              ...rebirthData.usedCoupons,
                              'milkyde4',
                            },
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

                          ref
                              .read(rebirthDataProvider.notifier)
                              .state = rebirthData.copyWith(
                            celestialTokens: rebirthData.celestialTokens + 69,
                            usedCoupons: {
                              ...rebirthData.usedCoupons,
                              'oliveiralindo',
                            },
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
                      icon: Icon(Icons.confirmation_num),
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
            child: Text(
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

    final randomId =
        achievementIds[(DateTime.now().millisecondsSinceEpoch %
            achievementIds.length)];
    final achievement = allAchievements.firstWhere((a) => a.id == randomId);

    AchievementPopupManager.showAchievementPopup(context, achievement);
  }
}
