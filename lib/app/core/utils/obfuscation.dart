import 'dart:convert';

class ObfuscationUtils {
  static const String _key = 'fuba_secret_key_2024';

  static Map<String, dynamic> _sanitizeMap(Map<String, dynamic> data) {
    final sanitized = <String, dynamic>{};
    data.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        sanitized[key] = _sanitizeMap(value);
      } else if (value is List) {
        sanitized[key] = value.map((item) {
          if (item is Map<String, dynamic>) {
            return _sanitizeMap(item);
          } else if (item is double && (item.isInfinite || item.isNaN)) {
            return 123;
          } else {
            return item;
          }
        }).toList();
      } else if (value is double && (value.isInfinite || value.isNaN)) {
        sanitized[key] = 123;
      } else {
        sanitized[key] = value;
      }
    });
    return sanitized;
  }

  static String obfuscate(Map<String, dynamic> data) {
    try {
      if (data['achievementsStats'] != null) {
        if (data['achievementsStats']['total_click_fuba'] == null) {
          data['achievementsStats']['total_click_fuba'] = 1;
        }
      }

      final sanitized = _sanitizeMap(data);
      final jsonString = jsonEncode(sanitized);
      final keyBytes = utf8.encode(_key);
      final dataBytes = utf8.encode(jsonString);
      final result = <int>[];

      for (int i = 0; i < dataBytes.length; i++) {
        result.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      final obfuscated = base64Encode(result);
      return obfuscated;
    } catch (e) {
      throw Exception('Erro ao ofuscar dados: $e');
    }
  }

  static Map<String, dynamic> deobfuscate(String obfuscatedData) {
    try {
      final keyBytes = utf8.encode(_key);
      final dataBytes = base64Decode(obfuscatedData);
      final result = <int>[];

      for (int i = 0; i < dataBytes.length; i++) {
        result.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      final deobfuscated = utf8.decode(result);
      return jsonDecode(deobfuscated) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Erro ao desofuscar dados: $e');
    }
  }

  static String obfuscateString(String data) {
    try {
      final keyBytes = utf8.encode(_key);
      final dataBytes = utf8.encode(data);
      final result = <int>[];

      for (int i = 0; i < dataBytes.length; i++) {
        result.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return base64Encode(result);
    } catch (e) {
      throw Exception('Erro ao ofuscar string: $e');
    }
  }

  static String deobfuscateString(String obfuscatedData) {
    try {
      final keyBytes = utf8.encode(_key);
      final dataBytes = base64Decode(obfuscatedData);
      final result = <int>[];

      for (int i = 0; i < dataBytes.length; i++) {
        result.add(dataBytes[i] ^ keyBytes[i % keyBytes.length]);
      }

      return utf8.decode(result);
    } catch (e) {
      throw Exception('Erro ao desofuscar string: $e');
    }
  }
}
