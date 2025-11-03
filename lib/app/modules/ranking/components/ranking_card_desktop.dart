import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';
import 'package:fuba_clicker/gen/assets.gen.dart';

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
        return const Color(0xFFD4AF37);
      case 2:
        return const Color(0xFF555555);
      case 3:
        return const Color(0xFF8B4513);
      default:
        return const Color(0xFF555555);
    }
  }

  Color _getRankCrownColor() {
    switch (rank) {
      case 1:
        return const Color(0xFFFFD700);
      case 2:
        return const Color(0xFFC0C0C0);
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
    int flex = 1,
  }) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          // color: color,
          gradient: LinearGradient(
            colors: [
              color,
              color.withValues(alpha: 0.7),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
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
            // const SizedBox(width: 4),
            // Text(
            //   label,
            //   style: const TextStyle(
            //     color: Colors.white,
            //     fontSize: 13,
            //     fontWeight: FontWeight.w500,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getRankColor(),
              _getRankColor().withValues(alpha: 0.5),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              entry.username.substring(0, 1).toUpperCase(),
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineLarge
                                  ?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          // 'asdasdsadasdsadasd33333333333333333333333',
                          entry.username,
                          maxLines: 3,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                      ],
                    ),
                    Positioned(
                      top: -16,
                      left: -6,
                      child: Transform.rotate(
                        angle: -35 * pi / 180,
                        child: Assets.images.crown.image(
                          width: 30,
                          height: 30,
                          color: _getRankCrownColor(),
                        ),
                      ).animate(
                        onPlay: (controller) {
                          controller.repeat(reverse: true);
                        },
                      ).moveY(
                        begin: -10,
                        duration: 1.seconds,
                        end: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        entry.furuborusCount.toString(),
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium
                                            ?.copyWith(
                                          color: Colors.white,
                                          fontSize: 80,
                                          fontWeight: FontWeight.bold,
                                          shadows: [
                                            Shadow(
                                              color: Colors.black.withValues(
                                                alpha: 0.3,
                                              ),
                                              blurRadius: 4,
                                              offset: const Offset(0, 2),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 12),
                                      child: Column(
                                        children: [
                                          Assets.images.forus
                                              .image(width: 60, height: 60),
                                          const SizedBox(height: 10),
                                          Text(
                                            'Forus',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: Colors.white,
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
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            IntrinsicHeight(
              child: Row(
                spacing: 6,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildStatBadge(
                    icon: Icons.adb,
                    label: 'Ascensão',
                    value: entry.transcendenceCount.toString(),
                    color: Colors.deepOrange,
                  ),
                  _buildStatBadge(
                    icon: Icons.star,
                    label: 'Ascensão',
                    value: entry.ascensionCount.toString(),
                    color: const Color(0xFF2196F3),
                  ),
                  _buildStatBadge(
                    icon: Icons.repeat,
                    label: 'Rebirth',
                    value: entry.rebirthCount.toString(),
                    color: const Color(0xFF4CAF50),
                  ),
                  _buildStatBadge(
                    icon: Icons.monetization_on,
                    label: 'Tokens',
                    value: entry.celestialTokens.toStringAsFixed(1),
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
            ),
          ],
        ),
      ),
    );
  }
}
