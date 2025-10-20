import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';
import '../utils/constants.dart';
import 'hexagonal_achievement_badge.dart';

class AchievementsPage extends ConsumerWidget {
  const AchievementsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unlocked = ref.watch(unlockedAchievementsProvider);
    final multiplier = ref.watch(achievementMultiplierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conquistas'),
        backgroundColor: Colors.black.withAlpha(200),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade900.withAlpha(200), Colors.black],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(unlocked.length, multiplier),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: _getCrossAxisCount(context),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.8,
                ),
                itemCount: allAchievements.length,
                itemBuilder: (context, index) {
                  final achievement = allAchievements[index];
                  final isUnlocked = unlocked.contains(achievement.id);
                  return _buildAchievementCard(
                    achievement,
                    isUnlocked,
                    false,
                    context,
                    ref,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;
    if (width > 800) return 3;
    if (width > 600) return 2;
    return 2;
  }

  Widget _buildHeader(int unlockedCount, double multiplier) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha(150),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.withAlpha(100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              Text(
                '$unlockedCount/${allAchievements.length}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Text(
                'Desbloqueadas',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
          Container(width: 1, height: 40, color: Colors.amber.withAlpha(100)),
          Column(
            children: [
              Text(
                'x${multiplier.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              Text(
                'Multiplicador Total',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(
    Achievement achievement,
    bool isUnlocked,
    bool isBarrierLocked,
    BuildContext context,
    WidgetRef ref,
  ) {
    final difficultyColor = _getDifficultyColor(achievement.difficulty);
    final isMobile = GameConstants.isMobile(context);
    final cardSize = _getCardSizeForDifficulty(
      achievement.difficulty,
      isMobile,
    );

    return Container(
      height: cardSize.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isUnlocked
              ? [difficultyColor.withAlpha(80), Colors.black.withAlpha(200)]
              : [
                  Colors.grey.shade800.withAlpha(100),
                  Colors.black.withAlpha(200),
                ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked
              ? difficultyColor.withAlpha(120)
              : Colors.grey.shade600.withAlpha(80),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnlocked
                ? difficultyColor.withAlpha(60)
                : Colors.grey.withAlpha(30),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            HexagonalAchievementBadge(
              difficulty: achievement.difficulty,
              emoji: achievement.emoji,
              isUnlocked: isUnlocked,
              size: isMobile ? 50 : 60,
              enableAnimations: isUnlocked,
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: difficultyColor.withAlpha(80),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _getDifficultyLabel(achievement.difficulty),
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: difficultyColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              achievement.name,
              style: TextStyle(
                fontSize: isMobile ? 12 : 14,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.white : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Text(
              achievement.description,
              style: TextStyle(
                fontSize: isMobile ? 9 : 10,
                color: isUnlocked ? Colors.grey.shade400 : Colors.grey.shade700,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUnlocked) ...[
              const SizedBox(height: 8),
              _buildRewardChip(achievement.reward),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRewardChip(AchievementReward reward) {
    String text;
    Color color;

    switch (reward.type) {
      case AchievementRewardType.multiplier:
        text = 'x${reward.value.toStringAsFixed(2)}';
        color = Colors.orange;
        break;
      case AchievementRewardType.tokens:
        text = '+${reward.value.toInt()} 💎';
        color = Colors.cyan;
        break;
      case AchievementRewardType.unlockSecret:
        text = 'Unlock';
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withAlpha(100)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
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

  Size _getCardSizeForDifficulty(
    AchievementDifficulty difficulty,
    bool isMobile,
  ) {
    final baseHeight = isMobile ? 200.0 : 240.0;
    final heightMultiplier =
        difficulty.index >= AchievementDifficulty.epic.index ? 1.2 : 1.0;
    return Size(double.infinity, baseHeight * heightMultiplier);
  }
}
