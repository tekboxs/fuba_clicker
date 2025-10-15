import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';
import '../providers/audio_provider.dart';
import '../providers/accessory_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/rebirth_upgrade_provider.dart';
import '../models/cake_accessory.dart';
import '../utils/constants.dart';
import 'generator_section.dart';
import 'parallax_background.dart';
import 'loot_box_shop.dart';
import 'floating_accessories.dart';
import 'cake_display.dart';
import 'rebirth_page.dart';
import 'achievements_page.dart';
import 'rebirth_upgrades_page.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _startAutoProduction();
    _initializeAudio();
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

          double totalProduction = autoProduction;

          if (autoClickerRate > 0) {
            final clickMultiplier = ref
                .read(upgradeNotifierProvider)
                .getClickMultiplier();
            totalProduction += autoClickerRate * clickMultiplier;
          }

          if (totalProduction > 0) {
            ref.read(fubaProvider.notifier).update((state) {
              return double.parse((state + totalProduction).toStringAsFixed(1));
            });

            ref
                .read(achievementNotifierProvider)
                .incrementStat('total_production', totalProduction);
          }
        }
      },
    );
  }

  @override
  void dispose() {
    _autoProductionTimer?.cancel();
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
    );
  }

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
        const SizedBox(height: 8),
        _buildTitle(),
        const SizedBox(height: 3),
        _buildCounter(),
        const SizedBox(height: 4),
        Text(
          '🌽 ${GameConstants.formatNumber(ref.watch(autoProductionProvider))}/s',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        Text(
          'Multiplicador: x${ref.watch(totalMultiplierProvider).toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        _buildCakeButton(),
        const SizedBox(height: 12),
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
              if (ref.watch(totalMultiplierProvider) > 1)
                Text(
                  'Multiplicador: x${ref.watch(totalMultiplierProvider).toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
            width: isMobile ? 200 : 150,
            height: isMobile ? 200 : 150,
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

    final clickMultiplier = ref
        .read(upgradeNotifierProvider)
        .getClickMultiplier();
    final clickValue = 1 * clickMultiplier;

    ref.read(fubaProvider.notifier).state += clickValue;

    ref.read(achievementNotifierProvider).incrementStat('total_clicks');
    ref
        .read(achievementNotifierProvider)
        .incrementStat('total_production', clickValue);
  }

  int counter = 0;

  Widget _buildTopRightButtons() {
    final isAudioPlaying = ref.watch(audioStateProvider);
    final isMobile = GameConstants.isMobile(context);

    return Positioned(
      top: isMobile ? 8 : 16,
      right: isMobile ? 8 : null,
      left: isMobile ? null : MediaQuery.of(context).size.width/2 - 250,
      child: Row(
        children: [
          _buildIconButton(Icons.emoji_events, Colors.amber, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const AchievementsPage()),
            );
          }),
          const SizedBox(width: 8),
          _buildIconButton(
            isAudioPlaying ? Icons.volume_up : Icons.volume_off,
            isAudioPlaying ? Colors.orange : Colors.grey,
            () {
              counter++;
              if (counter == 9) {
                ref.read(audioStateProvider.notifier).toggleAudio();
                return;
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 1),
                  content: Text(
                    counter > 3
                        ? counter > 6
                              ? counter > 9
                                    ? 'Agora fica sem musica tmb infeliz >:('
                                    : 'Aproveita a obra de arte'
                              : 'Tem certeza que vai perder a obra de arte?'
                        : 'Você não pode fazer isso, escute a musica',
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
      top: isMobile ? 8 : 16,
      left: isMobile ? 8 : 16,
      child: Row(
        children: [
          _buildIconButton(Icons.shopping_bag, Colors.purple, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const LootBoxShopPage()),
            );
          }),
          const SizedBox(width: 8),
          _buildIconButton(Icons.auto_awesome, Colors.cyan, () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const RebirthUpgradesPage(),
              ),
            );
          }),
          const SizedBox(width: 8),
          _buildIconButton(Icons.refresh, Colors.deepPurple, () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const RebirthPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onPressed,
      ),
    );
  }
}
