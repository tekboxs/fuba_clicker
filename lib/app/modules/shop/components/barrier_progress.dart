import 'package:flutter/material.dart';
import 'package:fuba_clicker/app/core/utils/difficulty_barriers.dart';
import 'package:fuba_clicker/app/core/utils/efficient_number.dart';
import 'package:fuba_clicker/app/models/fuba_generator.dart';

class BarrierProgress extends StatelessWidget {
  final DifficultyBarrier barrier;
  final List<int> generatorsOwned;
  final bool isMobile;

  const BarrierProgress({
    super.key,
    required this.barrier,
    required this.generatorsOwned,
    required this.isMobile,
  });

  @override
  Widget build(BuildContext context) {
    double progress =
        barrier.getProgress(const EfficientNumber.zero(), generatorsOwned);
    progress -= 0.5;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.orange.withAlpha(30),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withAlpha(100)),
          ),
          child: Column(
            children: [
              Text(
                'Requisitos:',
                style: TextStyle(
                  fontSize: isMobile ? 10 : 12,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (barrier.requiredGeneratorTier < generatorsOwned.length)
                Text(
                  '${availableGenerators[barrier.requiredGeneratorTier].emoji} ${barrier.requiredGeneratorCount}x ${availableGenerators[barrier.requiredGeneratorTier].name}',
                  style: TextStyle(
                    fontSize: isMobile ? 9 : 11,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress * 2,
            minHeight: 12,
            backgroundColor: Colors.grey.shade800,
            valueColor:
                const AlwaysStoppedAnimation<Color>(Colors.orange),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${((progress * 2) * 100).toStringAsFixed(1)}%',
          style: TextStyle(
            fontSize: isMobile ? 10 : 12,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}


