import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:big_decimal/big_decimal.dart';
import '../models/rebirth_data.dart';
import '../models/fuba_generator.dart';
import 'game_providers.dart';
import 'accessory_provider.dart';
import 'save_provider.dart';
import 'rebirth_upgrade_provider.dart';
import '../utils/constants.dart';

final rebirthDataProvider = StateProvider<RebirthData>((ref) {
  return const RebirthData();
});

final rebirthMultiplierProvider = Provider<double>((ref) {
  return ref.watch(rebirthDataProvider).getTotalMultiplier();
});

final oneTimeMultiplierProvider = Provider<double>((ref) {
  final rebirthData = ref.watch(rebirthDataProvider);
  return rebirthData.hasUsedOneTimeMultiplier ? 100.0 : 1.0;
});

final canRebirthProvider = Provider.family<bool, RebirthTier>((ref, tier) {
  final fuba = ref.watch(fubaProvider);
  final rebirthData = ref.watch(rebirthDataProvider);

  final requirement = switch (tier) {
    RebirthTier.rebirth => tier.getRequirement(rebirthData.rebirthCount),
    RebirthTier.ascension => tier.getRequirement(rebirthData.ascensionCount),
    RebirthTier.transcendence =>
      tier.getRequirement(rebirthData.transcendenceCount),
  };

  final requirementString = requirement.toString();
  if (requirementString == 'Infinity' || requirementString == 'NaN') {
    return false;
  }
  return fuba.compareTo(BigDecimal.parse(requirementString)) >= 0;
});

class RebirthNotifier {
  RebirthNotifier(this.ref);
  final Ref ref;

  void performRebirth(RebirthTier tier) {
    final currentData = ref.read(rebirthDataProvider);
    final canRebirth = ref.read(canRebirthProvider(tier));

    if (!canRebirth) return;

    final tokenReward = switch (tier) {
      RebirthTier.rebirth => tier.getTokenReward(currentData.rebirthCount),
      RebirthTier.ascension => tier.getTokenReward(currentData.ascensionCount),
      RebirthTier.transcendence =>
        tier.getTokenReward(currentData.transcendenceCount),
    };

    _resetProgress(tier);

    ref.read(rebirthDataProvider.notifier).state = switch (tier) {
      RebirthTier.rebirth => currentData.copyWith(
          rebirthCount: currentData.rebirthCount + 1,
          celestialTokens: currentData.celestialTokens + tokenReward,
        ),
      RebirthTier.ascension => currentData.copyWith(
          ascensionCount: currentData.ascensionCount + 1,
          celestialTokens: currentData.celestialTokens + tokenReward,
        ),
      RebirthTier.transcendence => currentData.copyWith(
          transcendenceCount: currentData.transcendenceCount + 1,
          celestialTokens: currentData.celestialTokens + tokenReward,
        ),
    };
  }

  void _resetProgress(RebirthTier tier) {
    ref.read(fubaProvider.notifier).state = BigDecimal.zero;
    ref.read(generatorsProvider.notifier).state =
        List.filled(availableGenerators.length, 0);

    final upgradeNotifier = ref.read(upgradeNotifierProvider);
    final shouldKeepItems = upgradeNotifier.shouldKeepItems();

    switch (tier) {
      case RebirthTier.rebirth:
        break;
      case RebirthTier.ascension:
        if (!shouldKeepItems) {
          ref.read(inventoryProvider.notifier).state = {};
          ref.read(equippedAccessoriesProvider.notifier).state = [];
        }
        break;
      case RebirthTier.transcendence:
        if (!shouldKeepItems) {
          ref.read(inventoryProvider.notifier).state = {};
          ref.read(equippedAccessoriesProvider.notifier).state = [];
        }
        break;
    }
    
    ref.read(saveNotifierProvider.notifier).saveImmediate();
  }

  void spendTokens(double amount) {
    final currentData = ref.read(rebirthDataProvider);
    if (currentData.celestialTokens >= amount) {
      ref.read(rebirthDataProvider.notifier).state = currentData.copyWith(
        celestialTokens: currentData.celestialTokens - amount,
      );
    }
  }

  void performMultipleRebirth(RebirthTier tier, int count) {
    if (count <= 0) return;
    
    final currentData = ref.read(rebirthDataProvider);
    final fuba = ref.read(fubaProvider);
    
    int actualCount = 0;
    BigDecimal remainingFuba = fuba;
    
    final currentTierCount = switch (tier) {
      RebirthTier.rebirth => currentData.rebirthCount,
      RebirthTier.ascension => currentData.ascensionCount,
      RebirthTier.transcendence => currentData.transcendenceCount,
    };
    
    // Limites máximos seguros para evitar travamentos
    const maxRebirths = 200;
    const maxAscensions = 100;
    const maxTranscendences = 80;
    
    // Determina limite baseado no tier
    int maxAllowed;
    switch (tier) {
      case RebirthTier.rebirth:
        maxAllowed = maxRebirths;
        break;
      case RebirthTier.ascension:
        maxAllowed = maxAscensions;
        break;
      case RebirthTier.transcendence:
        maxAllowed = maxTranscendences;
        break;
    }
    
    // Limita o loop para evitar travamentos
    final maxIterations = count > maxAllowed ? maxAllowed : count;
    
    // Converte fuba para SuffixNumber para comparações eficientes
    final fubaSuffix = SuffixNumber.fromBigDecimal(fuba);
    
    // Otimização: para números muito grandes, usa lógica especial
    if (fubaSuffix.magnitude > 20) { // Para números muito grandes (acima de 10^60)
      // Para números extremos, permite mais rebirths baseado na magnitude
      final adjustedMaxIterations = switch (tier) {
        RebirthTier.rebirth => fubaSuffix.magnitude > 30 ? 200 : 100,
        RebirthTier.ascension => fubaSuffix.magnitude > 35 ? 100 : 50,
        RebirthTier.transcendence => fubaSuffix.magnitude > 40 ? 80 : 40,
      };
      
      if (adjustedMaxIterations > maxIterations) {
        // Usa o limite maior para números extremos
        for (int i = 0; i < adjustedMaxIterations; i++) {
          final requirement = tier.getRequirement(currentTierCount + i);
          
          // Para números muito grandes, sempre permite se o fuba é suficiente
          if (requirement > 1e50) {
            // Com fuba extremo, assume que pode fazer o rebirth
            actualCount++;
            if (actualCount >= adjustedMaxIterations) break;
            continue;
          }
          
          // Lógica normal para números menores
          if (requirement.isInfinite || requirement.isNaN || requirement <= 0) {
            break;
          }
          
          try {
            final requirementBigDecimal = BigDecimal.parse(requirement.toString());
            final requirementSuffix = SuffixNumber.fromBigDecimal(requirementBigDecimal);
            
            if (fubaSuffix.isGreaterOrEqual(requirementSuffix)) {
              remainingFuba = remainingFuba - requirementBigDecimal;
              actualCount++;
            } else {
              break;
            }
          } catch (e) {
            break;
          }
        }
        
        if (actualCount > 0) {
          // Calcula token reward usando aproximação
          double totalTokenReward = 0.0;
          switch (tier) {
            case RebirthTier.rebirth:
              totalTokenReward = actualCount * 0.5;
              break;
            case RebirthTier.ascension:
              final avgCount = currentTierCount + (actualCount ~/ 2);
              totalTokenReward = (1.0 + (avgCount ~/ 2)) * actualCount;
              break;
            case RebirthTier.transcendence:
              final avgCount = currentTierCount + (actualCount ~/ 2);
              totalTokenReward = (5.0 + avgCount) * actualCount;
              break;
          }
          
          _resetProgress(tier);
          
          ref.read(rebirthDataProvider.notifier).state = switch (tier) {
            RebirthTier.rebirth => currentData.copyWith(
                rebirthCount: currentData.rebirthCount + actualCount,
                celestialTokens: currentData.celestialTokens + totalTokenReward,
              ),
            RebirthTier.ascension => currentData.copyWith(
                ascensionCount: currentData.ascensionCount + actualCount,
                celestialTokens: currentData.celestialTokens + totalTokenReward,
              ),
            RebirthTier.transcendence => currentData.copyWith(
                transcendenceCount: currentData.transcendenceCount + actualCount,
                celestialTokens: currentData.celestialTokens + totalTokenReward,
              ),
          };
        }
        return;
      }
    }
    
    for (int i = 0; i < maxIterations; i++) {
      final requirement = tier.getRequirement(currentTierCount + i);
      
      // Verifica se o requisito é válido antes de converter
      if (requirement.isInfinite || requirement.isNaN || requirement <= 0) {
        break;
      }
      
      // Para números muito grandes, usa comparação de SuffixNumber
      if (requirement > 1e50) {
        // Converte requirement para SuffixNumber e compara
        try {
          final requirementBigDecimal = BigDecimal.parse(requirement.toString());
          final requirementSuffix = SuffixNumber.fromBigDecimal(requirementBigDecimal);
          
          if (fubaSuffix.isGreaterOrEqual(requirementSuffix)) {
            remainingFuba = remainingFuba - requirementBigDecimal;
            actualCount++;
          } else {
            break;
          }
        } catch (e) {
          // Se houver erro na conversão, para o loop
          break;
        }
        continue;
      }
      
      final requirementString = requirement.toString();
      if (requirementString == 'Infinity' || requirementString == 'NaN') {
        break;
      }
      
      try {
        final requirementBigDecimal = BigDecimal.parse(requirementString);
        final requirementSuffix = SuffixNumber.fromBigDecimal(requirementBigDecimal);
        
        // Usa comparação de SuffixNumber para números muito grandes
        if (fubaSuffix.isGreaterOrEqual(requirementSuffix)) {
          remainingFuba = remainingFuba - requirementBigDecimal;
          actualCount++;
        } else {
          break;
        }
      } catch (e) {
        // Se houver erro na conversão, para o loop
        break;
      }
      
      // Otimização: se já processou muitos rebirths, para para evitar travamentos
      if (actualCount >= maxAllowed) {
        break;
      }
    }
    
    if (actualCount == 0) return;
    
    // Otimização: calcula token reward de forma mais eficiente
    double totalTokenReward = 0.0;
    
    if (actualCount <= 100) {
      // Para poucos rebirths, calcula individualmente
      for (int i = 0; i < actualCount; i++) {
        totalTokenReward += tier.getTokenReward(currentTierCount + i);
      }
    } else {
      // Para muitos rebirths, usa aproximação matemática
      switch (tier) {
        case RebirthTier.rebirth:
          totalTokenReward = actualCount * 0.5; // Rebirth sempre dá 0.5
          break;
        case RebirthTier.ascension:
          // Aproximação: (1 + count/2) * actualCount para valores médios
          final avgCount = currentTierCount + (actualCount ~/ 2);
          totalTokenReward = (1.0 + (avgCount ~/ 2)) * actualCount;
          break;
        case RebirthTier.transcendence:
          // Aproximação: (5 + count) * actualCount para valores médios
          final avgCount = currentTierCount + (actualCount ~/ 2);
          totalTokenReward = (5.0 + avgCount) * actualCount;
          break;
      }
    }
    
    _resetProgress(tier);
    
    ref.read(rebirthDataProvider.notifier).state = switch (tier) {
      RebirthTier.rebirth => currentData.copyWith(
          rebirthCount: currentData.rebirthCount + actualCount,
          celestialTokens: currentData.celestialTokens + totalTokenReward,
        ),
      RebirthTier.ascension => currentData.copyWith(
          ascensionCount: currentData.ascensionCount + actualCount,
          celestialTokens: currentData.celestialTokens + totalTokenReward,
        ),
      RebirthTier.transcendence => currentData.copyWith(
          transcendenceCount: currentData.transcendenceCount + actualCount,
          celestialTokens: currentData.celestialTokens + totalTokenReward,
        ),
    };
  }
}

final rebirthNotifierProvider = Provider<RebirthNotifier>((ref) {
  return RebirthNotifier(ref);
});

int calculateMaxOperations(RebirthTier tier, BigDecimal fuba, RebirthData rebirthData) {
  int count = 0;
  BigDecimal remainingFuba = fuba;
  
  final currentCount = switch (tier) {
    RebirthTier.rebirth => rebirthData.rebirthCount,
    RebirthTier.ascension => rebirthData.ascensionCount,
    RebirthTier.transcendence => rebirthData.transcendenceCount,
  };
  
  // Limites máximos seguros para evitar travamentos
  const maxRebirths = 200;
  const maxAscensions = 100;
  const maxTranscendences = 80;
  
  // Determina limite baseado no tier
  int maxAllowed;
  switch (tier) {
    case RebirthTier.rebirth:
      maxAllowed = maxRebirths;
      break;
    case RebirthTier.ascension:
      maxAllowed = maxAscensions;
      break;
    case RebirthTier.transcendence:
      maxAllowed = maxTranscendences;
      break;
  }
  
  // Limita o loop para evitar travamentos
  final maxIterations = maxAllowed;
  
  // Converte fuba para SuffixNumber para comparações eficientes
  final fubaSuffix = SuffixNumber.fromBigDecimal(fuba);
  
  for (int i = 0; i < maxIterations; i++) {
    final requirement = tier.getRequirement(currentCount + count);
    
    // Verifica se o requisito é válido
    if (requirement.isInfinite || requirement.isNaN || requirement <= 0) {
      break;
    }
    
    // Para números muito grandes, usa comparação de SuffixNumber
    if (requirement > 1e50) {
      // Converte requirement para SuffixNumber e compara
      try {
        final requirementBigDecimal = BigDecimal.parse(requirement.toString());
        final requirementSuffix = SuffixNumber.fromBigDecimal(requirementBigDecimal);
        
        if (fubaSuffix.isGreaterOrEqual(requirementSuffix)) {
          remainingFuba = remainingFuba - requirementBigDecimal;
          count++;
        } else {
          break;
        }
      } catch (e) {
        // Se houver erro na conversão, para o loop
        break;
      }
      continue;
    }
    
    final requirementString = requirement.toString();
    if (requirementString == 'Infinity' || requirementString == 'NaN') {
      break;
    }
    
    try {
      final requirementBigDecimal = BigDecimal.parse(requirementString);
      final requirementSuffix = SuffixNumber.fromBigDecimal(requirementBigDecimal);
      
      // Usa comparação de SuffixNumber para números muito grandes
      if (fubaSuffix.isGreaterOrEqual(requirementSuffix)) {
        remainingFuba = remainingFuba - requirementBigDecimal;
        count++;
      } else {
        break;
      }
    } catch (e) {
      // Se houver erro na conversão, para o loop
      break;
    }
  }
  
  return count;
}


