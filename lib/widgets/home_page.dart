import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/game_providers.dart';
import '../providers/audio_provider.dart';
import '../providers/accessory_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/rebirth_upgrade_provider.dart';
import '../providers/rebirth_provider.dart';
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
            final achievementMultiplier = ref.read(
              achievementMultiplierProvider,
            );
            final accessoryMultiplier = ref.read(accessoryMultiplierProvider);
            final rebirthMultiplier = ref.read(rebirthMultiplierProvider);

            final totalClickMultiplier =
                clickMultiplier *
                achievementMultiplier *
                accessoryMultiplier *
                rebirthMultiplier;

            totalProduction += autoClickerRate * totalClickMultiplier;
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
      floatingActionButton: _buildSupporterButton(),
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
        _buildDetailedMultipliers(ref),
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
    final achievementMultiplier = ref.read(achievementMultiplierProvider);
    final accessoryMultiplier = ref.read(accessoryMultiplierProvider);
    final rebirthMultiplier = ref.read(rebirthMultiplierProvider);

    final totalClickMultiplier =
        clickMultiplier *
        achievementMultiplier *
        accessoryMultiplier *
        rebirthMultiplier;

    final clickValue = 1 * totalClickMultiplier;

    ref.read(fubaProvider.notifier).state += clickValue;

    ref.read(achievementNotifierProvider).incrementStat('total_clicks');
    ref
        .read(achievementNotifierProvider)
        .incrementStat('total_production', clickValue);
  }

  Widget _buildDetailedMultipliers(WidgetRef ref) {
    final totalMultiplier = ref.watch(totalMultiplierProvider);
    final achievementMultiplier = ref.watch(achievementMultiplierProvider);
    final rebirthMultiplier = ref.watch(rebirthMultiplierProvider);
    final upgradeMultiplier = ref.watch(upgradeProductionMultiplierProvider);
    final accessoryMultiplier = ref.watch(accessoryMultiplierProvider);
    final equippedIds = ref.watch(equippedAccessoriesProvider);

    // Debug: calcular multiplicador manualmente
    final manualTotal =
        accessoryMultiplier *
        rebirthMultiplier *
        upgradeMultiplier *
        achievementMultiplier;

    return Column(
      children: [
        const SizedBox(height: 5),

        Text(
          'Multiplicador Total: x${totalMultiplier.toStringAsFixed(2)}',
          style: const TextStyle(
            fontSize: 12,
            color: Colors.amber,
            fontWeight: FontWeight.bold,
          ),
        ),
        if (kDebugMode) ...[
          Text(
            'Debug Manual: x${manualTotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 10,
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Acessórios: x${accessoryMultiplier.toStringAsFixed(2)} | Rebirth: x${rebirthMultiplier.toStringAsFixed(2)} | Upgrade: x${upgradeMultiplier.toStringAsFixed(2)} | Conquistas: x${achievementMultiplier.toStringAsFixed(2)}',
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
                  '🔄 x${rebirthMultiplier.toStringAsFixed(2)}',
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

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 2,
      children: equippedIds.map((id) {
        final accessory = allAccessories.firstWhere((acc) => acc.id == id);
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
      top: isMobile ? 8 : 16,
      right: isMobile ? 8 : null,
      left: isMobile ? null : MediaQuery.of(context).size.width / 2 - 250,
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

  Widget _buildSupporterButton() {
    return Container(
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
          child: FloatingActionButton(
            onPressed: _showSupporterDialog,
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Icon(Icons.favorite, color: Colors.white, size: 28),
          ),
        )
        .animate(
          autoPlay: true,
          onComplete: (controller) => controller.repeat(),
        )
        .shimmer(duration: 3.seconds, color: Colors.white.withAlpha(100));
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
                  GestureDetector(
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
                      width: double.infinity,
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
}
