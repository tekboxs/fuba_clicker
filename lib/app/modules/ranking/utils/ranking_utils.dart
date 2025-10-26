import 'package:big_decimal/big_decimal.dart';
import 'package:flutter/material.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';

class RankingUtils {
  static String getAvatarUrl(String username) {
    final seed = username.hashCode.abs().toString();
    return 'https://api.dicebear.com/7.x/avataaars/svg?seed=$seed&backgroundColor=b6e3f4,c0aede,d1d4f9,ffd5dc,ffdfbf';
  }

  static String formatWalletId(String username) {
    if (username.length <= 8) return username;
    return '${username.substring(0, 4)}...${username.substring(username.length - 4)}';
  }

  static String formatFuba(BigDecimal fuba) {
    final value = fuba.toDouble();
    
    if (value >= 1e12) {
      return '${(value / 1e12).toStringAsFixed(1)}T';
    } else if (value >= 1e9) {
      return '${(value / 1e9).toStringAsFixed(1)}B';
    } else if (value >= 1e6) {
      return '${(value / 1e6).toStringAsFixed(1)}M';
    } else if (value >= 1e3) {
      return '${(value / 1e3).toStringAsFixed(1)}K';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  static BigDecimal calculateMockFuba(RankingEntry entry) {
    double baseFuba = 1000000;
    
    baseFuba += entry.rebirthCount * 500000;
    baseFuba += entry.ascensionCount * 2000000;
    baseFuba += entry.transcendenceCount * 10000000;
    baseFuba += entry.achievementCount * 100000;
    baseFuba += entry.celestialTokens * 50000;
    
    return BigDecimal.parse(baseFuba.toString());
  }

  static Color getCrownColor(int rank) {
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

  static Color getCardBackgroundColor(int rank) {
    switch (rank) {
      case 1:
        return const Color(0xFF8B734C);
      case 2:
        return const Color(0xFF555555);
      case 3:
        return const Color(0xFFA08B73);
      default:
        return const Color(0xFF333333);
    }
  }

  static String getStatsText(RankingEntry entry) {
    final parts = <String>[];
    
    if (entry.rebirthCount > 0) {
      parts.add('${entry.rebirthCount} rebirths');
    }
    if (entry.ascensionCount > 0) {
      parts.add('${entry.ascensionCount} ascensions');
    }
    if (entry.transcendenceCount > 0) {
      parts.add('${entry.transcendenceCount} transcendences');
    }
    if (entry.achievementCount > 0) {
      parts.add('${entry.achievementCount} achievements');
    }
    
    return parts.isEmpty ? 'No progress yet' : parts.join(' • ');
  }
}
