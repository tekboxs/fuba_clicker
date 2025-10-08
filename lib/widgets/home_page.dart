import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../gen/assets.gen.dart';
import '../providers/game_providers.dart';
import '../providers/audio_provider.dart';
import '../utils/constants.dart';
import 'generator_section.dart';
import 'parallax_background.dart';

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
    Timer.periodic(GameConstants.autoProductionInterval, (timer) {
      if (mounted) {
        final autoProduction = ref.read(autoProductionProvider);
        if (autoProduction > 0) {
          ref.read(fubaProvider.notifier).update((state) {
            return double.parse((state + autoProduction).toStringAsFixed(1));
          });
        }
      }
    });
  }

  @override
  void dispose() {
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
            _buildAudioButton(),
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isMobile) const SizedBox(height: 8),
            _buildTitle(),
            SizedBox(height: isMobile ? 3 : 16),
            _buildCounter(),
            SizedBox(height: isMobile ? 4 : 8),
            Text(
              '🌽 ${GameConstants.formatNumber(ref.watch(autoProductionProvider))}/s',
              style: TextStyle(
                fontSize: isMobile ? 16 : 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isMobile ? 8 : 16),
            _buildCakeButton(),
            SizedBox(height: isMobile ? 12 : 20),
            Expanded(child: GeneratorSection()),
          ],
        ),
      ),
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

    return InkWell(
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      onTap: _handleCakeClick,
      child: SizedBox(
        width: isMobile ? 200 : 150,
        height: isMobile ? 200 : 150,
        child: Assets.images.cake
            .image(fit: BoxFit.contain)
            .animate(controller: _animationController)
            .scale(
              duration: GameConstants.cakeAnimationDuration,
              curve: Curves.bounceInOut,
              begin: const Offset(1.0, 1.0),
              end: const Offset(1.1, 1.1),
            ),
      ),
    );
  }

  /// Manipula o clique no bolo
  void _handleCakeClick() {
    _animationController.forward().then((_) => _animationController.reverse());
    ref.read(fubaProvider.notifier).state++;
  }

  /// Constrói o botão de controle de áudio
  int counter = 0;
  Widget _buildAudioButton() {
    final isAudioPlaying = ref.watch(audioStateProvider);
    return Positioned(
      top: GameConstants.isMobile(context) ? 8 : 16,
      right: GameConstants.isMobile(context) ? 8 : 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withAlpha(150),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.orange.withAlpha(100)),
        ),
        child: IconButton(
          icon: Icon(
            isAudioPlaying ? Icons.volume_up : Icons.volume_off,
            color: isAudioPlaying ? Colors.orange : Colors.grey,
          ),
          onPressed: () {
            counter++;
            if (counter == 9) {
              ref.read(audioStateProvider.notifier).toggleAudio();
              return;
            }

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 1),
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
      ),
    );
  }
}
