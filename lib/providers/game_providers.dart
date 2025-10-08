import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fuba_generator.dart';

/// Provider para o contador de fubá do jogador
final fubaProvider = StateProvider.autoDispose<double>((ref) {
  return kDebugMode ? 0 : 0;
  // return kDebugMode ? 1000000000000000000 : 0;
});

/// Provider para a quantidade de geradores possuídos
final generatorsProvider = StateProvider.autoDispose<List<int>>((ref) {
  return List.filled(availableGenerators.length, 0);
});

/// Provider que calcula a produção automática total por segundo
final autoProductionProvider = StateProvider.autoDispose<double>((ref) {
  final generators = ref.watch(generatorsProvider);
  double totalProduction = 0;

  for (int i = 0; i < availableGenerators.length; i++) {
    totalProduction += availableGenerators[i].getProduction(generators[i]);
  }

  return double.parse(totalProduction.toStringAsFixed(1));
});
