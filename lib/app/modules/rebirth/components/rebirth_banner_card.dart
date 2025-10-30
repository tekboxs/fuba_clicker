import 'package:flutter/material.dart';
import 'package:fuba_clicker/app/theme/components.dart';

class RebirthBannerCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String emoji;
  final double progress;
  final bool isLocked;
  final bool canActivate;
  final String? lockedReason;
  final String rewardMultiplierText;
  final String? rewardTokenText;
  final VoidCallback? onTap;
  final List<Color> colors;

  const RebirthBannerCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.emoji,
    required this.progress,
    required this.isLocked,
    required this.canActivate,
    required this.rewardMultiplierText,
    this.rewardTokenText,
    this.lockedReason,
    this.onTap,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );

    return InkWell(
      onTap: isLocked || !canActivate ? null : onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: colors.last.withOpacity(0.35),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -6,
              top: -12,
              child: Opacity(
                opacity: 0.15,
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 160),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context)
                        .textTheme
                        .labelLarge
                        ?.copyWith(color: Colors.white70),
                  ),
                  const Spacer(),
                  if (isLocked && lockedReason != null) ...[
                    Text(
                      lockedReason!,
                      style: const TextStyle(
                        color: Colors.orange,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _progressBar(progress, locked: true),
                  ] else ...[
                    _progressBar(progress),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _chip(rewardMultiplierText, Icons.trending_up,
                            Colors.orange),
                        if (rewardTokenText != null) ...[
                          const SizedBox(width: 8),
                          _chip(rewardTokenText!, Icons.star, Colors.cyan),
                        ],
                        const Spacer(),
                        AppButton.primary(
                          onPressed: isLocked || !canActivate ? null : onTap,
                          child: const Text('Activate'),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            if (isLocked)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _progressBar(double value, {bool locked = false}) => ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: LinearProgressIndicator(
          value: value.clamp(0, 1),
          minHeight: 10,
          backgroundColor: Colors.white.withOpacity(0.15),
          valueColor: AlwaysStoppedAnimation<Color>(
            locked
                ? Colors.orange
                : (value >= 1.0 ? Colors.greenAccent : Colors.orangeAccent),
          ),
        ),
      );

  Widget _chip(String text, IconData icon, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
}
