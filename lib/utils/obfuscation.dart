import 'dart:convert';

class ObfuscationUtils {
  static const String _key = 'fuba_secret_key_2024';
  
  static String obfuscate(Map<String, dynamic> data) {
    try {
      final jsonString = jsonEncode(data);
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
