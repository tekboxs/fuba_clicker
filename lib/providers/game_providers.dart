import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/fuba_generator.dart';

final fubaProvider = StateProvider<double>((ref) {
  return 0;
});

final generatorsProvider = StateProvider<List<int>>((ref) {
  return List.filled(availableGenerators.length, 0);
});

final autoProductionProvider = StateProvider.autoDispose<double>((ref) {
  final generators = ref.watch(generatorsProvider);
  double totalProduction = 0;

  for (int i = 0; i < availableGenerators.length; i++) {
    totalProduction += availableGenerators[i].getProduction(generators[i]);
  }

  return double.parse(totalProduction.toStringAsFixed(1));
});
