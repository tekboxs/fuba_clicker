import 'package:flutter/material.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';
import 'package:fuba_clicker/app/modules/ranking/utils/ranking_utils.dart';

class RankingCardDesktop extends StatelessWidget {
  final RankingEntry entry;
  final int rank;

  const RankingCardDesktop({
    super.key,
    required this.entry,
    required this.rank,
  });

  Color _getRankColor() {
    switch (rank) {
      case 1:
        return const Color(0xFF555555);
      case 2:
        return const Color(0xFFD4AF37);
      case 3:
        return const Color(0xFF8B4513);
      default:
        return const Color(0xFF555555);
    }
  }

  Color _getRankCrownColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFC0C0C0);
      case 2:
        return const Color(0xFFFFD700);
      case 3:
        return const Color(0xFFCD7F32);
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _getRankColor(),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: _getRankColor().withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(40),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      entry.username.substring(0, 1).toUpperCase(),
                      style:
                          Theme.of(context).textTheme.headlineLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                    ),
                  ),
                ),
                Positioned(
                  top: -6,
                  left: -6,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getRankCrownColor(),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  RankingUtils.formatFuba(
                                      RankingUtils.calculateMockFuba(entry)),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '\$ECI',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Column(
                              spacing: 6,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                _buildStatBadge(
                                  icon: Icons.repeat,
                                  label: 'Rebirth',
                                  value: entry.rebirthCount.toString(),
                                  color: const Color(0xFF4CAF50),
                                ),
                                _buildStatBadge(
                                  icon: Icons.star,
                                  label: 'Ascensão',
                                  value: entry.ascensionCount.toString(),
                                  color: const Color(0xFF2196F3),
                                ),
                                _buildStatBadge(
                                  icon: Icons.auto_awesome,
                                  label: 'Transcendência',
                                  value: entry.transcendenceCount.toString(),
                                  color: const Color(0xFF9C27B0),
                                ),
                                _buildStatBadge(
                                  icon: Icons.monetization_on,
                                  label: 'Tokens',
                                  value:
                                      entry.celestialTokens.toStringAsFixed(1),
                                  color: const Color(0xFFFFC107),
                                ),
                                _buildStatBadge(
                                  icon: Icons.emoji_events,
                                  label: 'Conquistas',
                                  value: entry.achievementCount.toString(),
                                  color: const Color(0xFFFF9800),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.25),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.account_balance_wallet,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              RankingUtils.formatWalletId(entry.username),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
