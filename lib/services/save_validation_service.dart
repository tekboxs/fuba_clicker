import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../models/rebirth_data.dart';
import '../models/fuba_generator.dart';

class SaveValidationService {
  static const String _validationKey = 'fuba_validation_2024';
  static const double _maxReasonableFuba = 1e400; // Limite máximo razoável

  static ValidationResult validateSaveData(GameSaveData data) {
    final issues = <String>[];
    final warnings = <String>[];

    // 1. Validar valores básicos
    _validateBasicValues(data, issues, warnings);

    // 2. Validar consistência de geradores
    _validateGenerators(data, issues, warnings);

    // 3. Validar rebirth data
    _validateRebirthData(data, issues, warnings);

    // 4. Validar inventário e equipamentos
    _validateInventory(data, issues, warnings);

    // 5. Validar achievements
    _validateAchievements(data, issues, warnings);

    // 6. Validar upgrades
    _validateUpgrades(data, issues, warnings);

    // 7. Validar consistência geral
    _validateGeneralConsistency(data, issues, warnings);

    final isValid = issues.isEmpty;
    final severity = issues.isNotEmpty 
        ? ValidationSeverity.critical 
        : warnings.isNotEmpty 
            ? ValidationSeverity.warning 
            : ValidationSeverity.valid;

    return ValidationResult(
      isValid: isValid,
      severity: severity,
      issues: issues,
      warnings: warnings,
      score: _calculateConsistencyScore(data),
    );
  }

  static void _validateBasicValues(GameSaveData data, List<String> issues, List<String> warnings) {
    if (data.fuba < 0) {
      issues.add('Fubá negativo detectado');
    }
    
    if (data.fuba > _maxReasonableFuba) {
      issues.add('Valor de fubá excessivamente alto');
    }

    if (data.fuba.isNaN || data.fuba.isInfinite) {
      issues.add('Valor de fubá inválido (NaN ou infinito)');
    }
  }

  static void _validateGenerators(GameSaveData data, List<String> issues, List<String> warnings) {
    if (data.generators.length > availableGenerators.length) {
      issues.add('Mais geradores do que disponíveis no jogo');
    }

    for (int i = 0; i < data.generators.length; i++) {
      final owned = data.generators[i];
      
      if (owned < 0) {
        issues.add('Gerador $i com quantidade negativa');
        continue;
      }

      if (owned > 1000000) {
        warnings.add('Gerador $i com quantidade muito alta');
      }

      // Validar se gerador está desbloqueado corretamente
      final generator = availableGenerators[i];
      if (owned > 0 && !generator.isUnlocked(data.generators, data.secrets)) {
        issues.add('Gerador ${generator.name} possuído mas não desbloqueado');
      }

      // Validar custo vs fubá disponível
      if (owned > 0) {
        final cost = generator.getCost(owned - 1);
        if (cost.toDouble() > data.fuba * 1000) {
          warnings.add('Gerador ${generator.name} com custo muito alto para fubá disponível');
        }
      }
    }
  }

  static void _validateRebirthData(GameSaveData data, List<String> issues, List<String> warnings) {
    final rebirth = data.rebirthData;
    
    if (rebirth.rebirthCount < 0 || rebirth.ascensionCount < 0 || rebirth.transcendenceCount < 0) {
      issues.add('Contadores de rebirth negativos');
    }

    if (rebirth.celestialTokens < 0) {
      issues.add('Tokens celestiais negativos');
    }

    // Validar consistência entre tiers
    if (rebirth.ascensionCount > 0 && rebirth.rebirthCount == 0) {
      issues.add('Ascensão sem rebirths');
    }

    if (rebirth.transcendenceCount > 0 && rebirth.ascensionCount == 0) {
      issues.add('Transcendência sem ascensões');
    }

    // Validar tokens celestiais
    final expectedTokens = RebirthTier.ascension.getTokenReward(rebirth.ascensionCount) +
                          RebirthTier.transcendence.getTokenReward(rebirth.transcendenceCount);
    
    if (rebirth.celestialTokens > expectedTokens + 10) {
      warnings.add('Tokens celestiais acima do esperado');
    }
  }

  static void _validateInventory(GameSaveData data, List<String> issues, List<String> warnings) {
    for (final entry in data.inventory.entries) {
      if (entry.value < 0) {
        issues.add('Item ${entry.key} com quantidade negativa');
      }
      
      if (entry.value > 1000) {
        warnings.add('Item ${entry.key} com quantidade muito alta');
      }
    }

    // Validar equipamentos
    for (final equipped in data.equipped) {
      if (!data.inventory.containsKey(equipped)) {
        issues.add('Item equipado $equipped não encontrado no inventário');
      }
    }

    if (data.equipped.length > 10) {
      warnings.add('Muitos itens equipados');
    }
  }

  static void _validateAchievements(GameSaveData data, List<String> issues, List<String> warnings) {
    if (data.achievements.length > 1000) {
      issues.add('Muitas conquistas desbloqueadas');
    }

    // Validar stats de achievements
    for (final entry in data.achievementStats.entries) {
      if (entry.value < 0) {
        issues.add('Stat de achievement ${entry.key} negativo');
      }
      
      if (entry.value > 1e20) {
        warnings.add('Stat de achievement ${entry.key} muito alto');
      }
    }
  }

  static void _validateUpgrades(GameSaveData data, List<String> issues, List<String> warnings) {
    for (final entry in data.upgrades.entries) {
      if (entry.value < 0) {
        issues.add('Upgrade ${entry.key} com nível negativo');
      }
      
      if (entry.value > 1000) {
        warnings.add('Upgrade ${entry.key} com nível muito alto');
      }
    }
  }

  static void _validateGeneralConsistency(GameSaveData data, List<String> issues, List<String> warnings) {
    // Validar se fubá é consistente com geradores
    final totalProduction = _calculateTotalProduction(data.generators);
    final rebirthMultiplier = data.rebirthData.getTotalMultiplier();
    final adjustedProduction = totalProduction * rebirthMultiplier;
    
    if (adjustedProduction > 0 && data.fuba > adjustedProduction * 86400 * 30) {
      warnings.add('Fubá muito alto comparado à produção (possível edição)');
    }

    // Validar progressão lógica
    if (data.fuba > 1e50 && data.rebirthData.rebirthCount == 0) {
      warnings.add('Fubá muito alto sem rebirths');
    }

    if (data.rebirthData.transcendenceCount > 0 && data.fuba < 1e30) {
      warnings.add('Transcendência com fubá baixo');
    }
  }

  static double _calculateTotalProduction(List<int> generators) {
    double total = 0;
    for (int i = 0; i < generators.length && i < availableGenerators.length; i++) {
      total += availableGenerators[i].getProduction(generators[i]).toDouble();
    }
    return total;
  }

  static int _calculateConsistencyScore(GameSaveData data) {
    int score = 100;
    
    // Penalizar valores muito altos
    if (data.fuba > 1e100) score -= 20;
    if (data.fuba > 1e200) score -= 30;
    
    // Penalizar inconsistências de progressão
    if (data.rebirthData.transcendenceCount > 0 && data.fuba < 1e40) score -= 25;
    if (data.fuba > 1e50 && data.rebirthData.rebirthCount == 0) score -= 30;
    
    // Penalizar geradores desproporcionais
    for (int i = 0; i < data.generators.length; i++) {
      if (data.generators[i] > 100000) score -= 5;
    }
    
    return max(0, score);
  }

  static String generateBackupCode(GameSaveData data) {
    final validation = validateSaveData(data);
    if (!validation.isValid) {
      throw Exception('Não é possível gerar código de backup para save inválido');
    }

    final codeData = {
      'f': data.fuba,
      'g': data.generators,
      'i': data.inventory,
      'e': data.equipped,
      'r': data.rebirthData.toJson(),
      'a': data.achievements.toList(),
      's': data.achievementStats,
      'u': data.upgrades,
      'se': data.secrets.toList(),
      't': DateTime.now().millisecondsSinceEpoch,
      'v': validation.score,
    };

    final jsonString = jsonEncode(codeData);
    final hash = sha256.convert(utf8.encode(jsonString + _validationKey)).toString();
    
    final compressed = _compressBackupCode(jsonString);
    return _encodeBackupCode(compressed, hash);
  }

  static GameSaveData? restoreFromBackupCode(String code) {
    try {
      final (compressed, hash) = _decodeBackupCode(code);
      final jsonString = _decompressBackupCode(compressed);
      
      // Validar hash
      final expectedHash = sha256.convert(utf8.encode(jsonString + _validationKey)).toString();
      if (hash != expectedHash) {
        return null;
      }
      
      final codeData = jsonDecode(jsonString);
      final now = DateTime.now().millisecondsSinceEpoch;
      final codeTime = codeData['t'] as int;
      
      // Validar idade do código (máximo 30 dias)
      if (now - codeTime > 30 * 24 * 60 * 60 * 1000) {
        return null;
      }
      
      return GameSaveData(
        fuba: (codeData['f'] as num).toDouble(),
        generators: List<int>.from(codeData['g']),
        inventory: Map<String, int>.from(codeData['i']),
        equipped: List<String>.from(codeData['e']),
        rebirthData: RebirthData.fromJson(codeData['r']),
        achievements: Set<String>.from(codeData['a']),
        achievementStats: Map<String, double>.from(codeData['s']),
        upgrades: Map<String, int>.from(codeData['u']),
        secrets: Set<String>.from(codeData['se']),
      );
    } catch (e) {
      return null;
    }
  }

  static String _compressBackupCode(String data) {
    final bytes = utf8.encode(data);
    final compressed = gzip.encode(bytes);
    return base64Encode(compressed);
  }

  static String _decompressBackupCode(String compressed) {
    final bytes = base64Decode(compressed);
    final decompressed = gzip.decode(bytes);
    return utf8.decode(decompressed);
  }

  static String _encodeBackupCode(String compressed, String hash) {
    final combined = '$compressed|$hash';
    final encoded = base64Encode(utf8.encode(combined));
    
    // Adicionar separadores para melhor legibilidade
    final chunks = <String>[];
    for (int i = 0; i < encoded.length; i += 4) {
      chunks.add(encoded.substring(i, min(i + 4, encoded.length)));
    }
    
    return chunks.join('-');
  }

  static (String compressed, String hash) _decodeBackupCode(String code) {
    final encoded = code.replaceAll('-', '');
    final combined = utf8.decode(base64Decode(encoded));
    final parts = combined.split('|');
    
    if (parts.length != 2) {
      throw Exception('Código de backup inválido');
    }
    
    return (parts[0], parts[1]);
  }
}

class ValidationResult {
  final bool isValid;
  final ValidationSeverity severity;
  final List<String> issues;
  final List<String> warnings;
  final int score;

  ValidationResult({
    required this.isValid,
    required this.severity,
    required this.issues,
    required this.warnings,
    required this.score,
  });
}

enum ValidationSeverity {
  valid,
  warning,
  critical,
}

class GameSaveData {
  final double fuba;
  final List<int> generators;
  final Map<String, int> inventory;
  final List<String> equipped;
  final RebirthData rebirthData;
  final Set<String> achievements;
  final Map<String, double> achievementStats;
  final Map<String, int> upgrades;
  final Set<String> secrets;

  GameSaveData({
    required this.fuba,
    required this.generators,
    required this.inventory,
    required this.equipped,
    required this.rebirthData,
    required this.achievements,
    required this.achievementStats,
    required this.upgrades,
    required this.secrets,
  });
}
