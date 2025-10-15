import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/achievement.dart';
import '../providers/achievement_provider.dart';

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
            colors: [
              Colors.amber.shade900.withAlpha(200),
              Colors.black,
            ],
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
                  return _buildAchievementCard(achievement, isUnlocked);
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          Container(
            width: 1,
            height: 40,
            color: Colors.amber.withAlpha(100),
          ),
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
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement, bool isUnlocked) {
    return Card(
      color: isUnlocked
          ? _getCategoryColor(achievement.category).withAlpha(100)
          : Colors.grey.shade900.withAlpha(150),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isUnlocked || !achievement.isSecret ? achievement.emoji : '❓',
              style: TextStyle(
                fontSize: 48,
                color: isUnlocked ? null : Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isUnlocked || !achievement.isSecret ? achievement.name : '???',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? null : Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              isUnlocked || !achievement.isSecret
                  ? achievement.description
                  : 'Segredo',
              style: TextStyle(
                fontSize: 10,
                color: isUnlocked ? Colors.grey.shade400 : Colors.grey.shade700,
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

  Color _getCategoryColor(AchievementCategory category) {
    switch (category) {
      case AchievementCategory.production:
        return Colors.green;
      case AchievementCategory.clicks:
        return Colors.blue;
      case AchievementCategory.generators:
        return Colors.purple;
      case AchievementCategory.accessories:
        return Colors.pink;
      case AchievementCategory.lootBoxes:
        return Colors.orange;
      case AchievementCategory.rebirth:
        return Colors.cyan;
      case AchievementCategory.secret:
        return Colors.deepPurple;
    }
  }
}

