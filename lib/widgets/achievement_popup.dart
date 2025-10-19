import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fuba_clicker/utils/constants.dart';
import '../models/achievement.dart';
import 'hexagonal_achievement_badge.dart';

class AchievementPopup extends StatefulWidget {
  final Achievement achievement;
  final VoidCallback onClose;

  const AchievementPopup({
    super.key,
    required this.achievement,
    required this.onClose,
  });

  @override
  State<AchievementPopup> createState() => _AchievementPopupState();
}

class _AchievementPopupState extends State<AchievementPopup>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;

  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  Timer? _closeTimer;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _startAnimation();

    _closeTimer = Timer(const Duration(seconds: 2), () {
      if (!_isDisposed && mounted) {
        _closePopup();
      }
    });
  }

  void _startAnimation() {
    if (_isDisposed || !mounted) return;
    
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      if (!_isDisposed && mounted) {
        _scaleController.forward();
        _fadeController.forward();
      }
    });
  }

  void _closePopup() async {
    if (_isDisposed || !mounted) return;
    
    try {
      await _fadeController.reverse();
      if (!_isDisposed && mounted) {
        await _slideController.reverse();
        if (!_isDisposed && mounted) {
          widget.onClose();
        }
      }
    } catch (e) {
      // Controller já foi disposto, apenas chama onClose
      if (!_isDisposed && mounted) {
        widget.onClose();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _closeTimer?.cancel();
    _slideController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Área transparente que permite cliques passarem
          IgnorePointer(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.transparent,
            ),
          ),
          Positioned(
            top: GameConstants.isMobile(context) ? null : 16,
            bottom: GameConstants.isMobile(context) ? 16 : null,
            right: 16,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: IgnorePointer(
                    ignoring: true,
                    child: _buildPopupCard(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopupCard() {
    final difficultyColor = _getDifficultyColor(widget.achievement.difficulty);
    final isMobile = GameConstants.isMobile(context);

    return Container(
      width: isMobile ? 300 : 360,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            difficultyColor.withAlpha(150),
            Colors.black.withAlpha(250),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: difficultyColor.withAlpha(180),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: difficultyColor.withAlpha(120),
            blurRadius: 25,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _closePopup,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(100),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: difficultyColor.withAlpha(100),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: difficultyColor.withAlpha(150)),
                      ),
                      child: Text(
                        _getDifficultyLabel(widget.achievement.difficulty),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: difficultyColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                HexagonalAchievementBadge(
                  difficulty: widget.achievement.difficulty,
                  emoji: widget.achievement.emoji,
                  isUnlocked: true,
                  size: isMobile ? 70 : 80,
                  enableAnimations: true,
                ),
                const SizedBox(height: 16),
                Text(
                  'Conquista Desbloqueada!',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: difficultyColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.achievement.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(120),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              children: [
                Text(
                  widget.achievement.description,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey.shade300,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                _buildRewardChip(widget.achievement.reward),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRewardChip(AchievementReward reward) {
    String text;
    Color color;

    switch (reward.type) {
      case AchievementRewardType.multiplier:
        text = 'Multiplicador x${reward.value.toStringAsFixed(2)}';
        color = Colors.orange;
        break;
      case AchievementRewardType.tokens:
        text = '${reward.value.toInt()} Tokens Celestiais 💎';
        color = Colors.cyan;
        break;
      case AchievementRewardType.unlockSecret:
        text = 'Segredo Desbloqueado!';
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(150)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Color _getDifficultyColor(AchievementDifficulty difficulty) {
    switch (difficulty) {
      case AchievementDifficulty.common:
        return Colors.green;
      case AchievementDifficulty.uncommon:
        return Colors.blue;
      case AchievementDifficulty.rare:
        return Colors.purple;
      case AchievementDifficulty.epic:
        return Colors.orange;
      case AchievementDifficulty.legendary:
        return Colors.red;
    }
  }

  String _getDifficultyLabel(AchievementDifficulty difficulty) {
    switch (difficulty) {
      case AchievementDifficulty.common:
        return 'COMUM';
      case AchievementDifficulty.uncommon:
        return 'INCOMUM';
      case AchievementDifficulty.rare:
        return 'RARO';
      case AchievementDifficulty.epic:
        return 'ÉPICO';
      case AchievementDifficulty.legendary:
        return 'LENDÁRIO';
    }
  }

}

class AchievementPopupManager {
  static OverlayEntry? _currentPopup;

  static void showAchievementPopup(
    BuildContext context,
    Achievement achievement,
  ) {
    if (_currentPopup != null) {
      _currentPopup!.remove();
      _currentPopup = null;
    }

    try {
      final overlay = Navigator.of(context).overlay;
      if (overlay == null) {
        debugPrint('Overlay not found, cannot show achievement popup');
        return;
      }

      _currentPopup = OverlayEntry(
        builder: (context) => IgnorePointer(
          ignoring: true,
          child: AchievementPopup(
            achievement: achievement,
            onClose: () {
              _currentPopup?.remove();
              _currentPopup = null;
            },
          ),
        ),
      );

      overlay.insert(_currentPopup!);
    } catch (e) {
      debugPrint('Error showing achievement popup: $e');
    }
  }
}
