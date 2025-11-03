import 'dart:developer' as developer;

int safeToInt(num value, {int defaultValue = 0, String? context}) {
  try {
    if (value.isNaN || value.isInfinite) {
      final contextInfo = context != null ? ' | Context: $context' : '';
      developer.log(
        '⚠️ [INFINITY_TO_INT_ERROR] Tentativa de converter valor inválido para int: $value (NaN: ${value.isNaN}, Infinite: ${value.isInfinite})$contextInfo',
        name: 'SafeConvert',
        error: 'Value: $value, Default used: $defaultValue',
      );
      print('[INFINITY_TO_INT_ERROR] Tentativa de converter $value para int (context: ${context ?? 'unknown'}) - usando default: $defaultValue');
      return defaultValue;
    }
    return value.toInt();
  } catch (e, stackTrace) {
    final contextInfo = context != null ? ' | Context: $context' : '';
    developer.log(
      '❌ [INFINITY_TO_INT_ERROR] Erro ao converter $value para int: $e$contextInfo',
      name: 'SafeConvert',
      error: e,
      stackTrace: stackTrace,
    );
    print('[INFINITY_TO_INT_ERROR] Erro ao converter $value para int no contexto: ${context ?? 'unknown'}');
    print('Erro: $e');
    print('Stack trace: $stackTrace');
    return defaultValue;
  }
}

double safeToDouble(num value, {double defaultValue = 0.0, String? context}) {
  try {
    if (value.isNaN || value.isInfinite) {
      final contextInfo = context != null ? ' | Context: $context' : '';
      developer.log(
        '⚠️ [INFINITY_CONVERSION_ERROR] Tentativa de usar valor inválido: $value (NaN: ${value.isNaN}, Infinite: ${value.isInfinite})$contextInfo',
        name: 'SafeConvert',
        error: 'Value: $value, Default used: $defaultValue',
      );
      print('[INFINITY_CONVERSION_ERROR] Valor inválido $value no contexto: ${context ?? 'unknown'} - usando default: $defaultValue');
      return defaultValue;
    }
    return value.toDouble();
  } catch (e, stackTrace) {
    final contextInfo = context != null ? ' | Context: $context' : '';
    developer.log(
      '❌ [INFINITY_CONVERSION_ERROR] Erro ao converter $value para double: $e$contextInfo',
      name: 'SafeConvert',
      error: e,
      stackTrace: stackTrace,
    );
    print('[INFINITY_CONVERSION_ERROR] Erro ao converter $value no contexto: ${context ?? 'unknown'}');
    print('Erro: $e');
    print('Stack trace: $stackTrace');
    return defaultValue;
  }
}

List<int> safeCastToListInt(dynamic value, {String? context}) {
  try {
    if (value == null) return [];
    if (value is! List) {
      print('[SAFE_CAST_LIST_INT] Valor não é uma lista: ${value.runtimeType} (context: ${context ?? 'unknown'})');
      return [];
    }
    
    final result = <int>[];
    for (int i = 0; i < value.length; i++) {
      try {
        final item = value[i];
        if (item is int) {
          result.add(item);
        } else if (item is num) {
          result.add(safeToInt(item, context: '${context ?? 'List<int>'}[$i]'));
        } else {
          print('[SAFE_CAST_LIST_INT] Item $i não numérico: $item (type: ${item.runtimeType}) (context: ${context ?? 'unknown'})');
          result.add(0);
        }
      } catch (e) {
        print('[SAFE_CAST_LIST_INT] Erro ao processar item $i: $e (context: ${context ?? 'unknown'})');
        result.add(0);
      }
    }
    return result;
  } catch (e, stackTrace) {
    developer.log(
      '❌ [SAFE_CAST_LIST_INT] Erro ao fazer cast de lista para int: $e',
      name: 'SafeConvert',
      error: e,
      stackTrace: stackTrace,
    );
    print('[SAFE_CAST_LIST_INT] Erro crítico no contexto: ${context ?? 'unknown'}');
    print('Erro: $e');
    print('Stack: $stackTrace');
    return [];
  }
}

Map<String, int> safeCastToMapStringInt(dynamic value, {String? context}) {
  try {
    if (value == null) return {};
    if (value is! Map) return {};
    
    final result = <String, int>{};
    value.forEach((key, val) {
      final stringKey = key.toString();
      if (val is int) {
        result[stringKey] = val;
      } else if (val is num) {
        result[stringKey] = safeToInt(val, context: context ?? 'Map<String,int>[$stringKey]');
      } else {
        print('[SAFE_CAST] Valor não numérico encontrado no map String->int: $val para chave "$stringKey" (context: ${context ?? 'unknown'})');
        result[stringKey] = 0;
      }
    });
    return result;
  } catch (e, stackTrace) {
    developer.log(
      '❌ [SAFE_CAST_MAP_STRING_INT] Erro ao fazer cast de map para Map<String,int>: $e',
      name: 'SafeConvert',
      error: e,
      stackTrace: stackTrace,
    );
    print('[SAFE_CAST_MAP_STRING_INT] Erro no contexto: ${context ?? 'unknown'}');
    print('Erro: $e');
    return {};
  }
}

Map<String, double> safeCastToMapStringDouble(dynamic value, {String? context}) {
  try {
    if (value == null) return {};
    if (value is! Map) return {};
    
    final result = <String, double>{};
    value.forEach((key, val) {
      final stringKey = key.toString();
      if (val is double) {
        result[stringKey] = val;
      } else if (val is num) {
        result[stringKey] = safeToDouble(val, context: context ?? 'Map<String,double>[$stringKey]');
      } else {
        print('[SAFE_CAST] Valor não numérico encontrado no map String->double: $val para chave "$stringKey" (context: ${context ?? 'unknown'})');
        result[stringKey] = 0.0;
      }
    });
    return result;
  } catch (e, stackTrace) {
    developer.log(
      '❌ [SAFE_CAST_MAP_STRING_DOUBLE] Erro ao fazer cast de map para Map<String,double>: $e',
      name: 'SafeConvert',
      error: e,
      stackTrace: stackTrace,
    );
    print('[SAFE_CAST_MAP_STRING_DOUBLE] Erro no contexto: ${context ?? 'unknown'}');
    print('Erro: $e');
    return {};
  }
}

List<String> safeCastToListString(dynamic value, {String? context}) {
  try {
    if (value == null) return [];
    if (value is! List) return [];
    
    return value.map((item) => item.toString()).toList();
  } catch (e, stackTrace) {
    developer.log(
      '❌ [SAFE_CAST_LIST_STRING] Erro ao fazer cast de lista para String: $e',
      name: 'SafeConvert',
      error: e,
      stackTrace: stackTrace,
    );
    print('[SAFE_CAST_LIST_STRING] Erro no contexto: ${context ?? 'unknown'}');
    print('Erro: $e');
    return [];
  }
}

