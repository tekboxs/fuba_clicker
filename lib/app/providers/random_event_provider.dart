import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/random_event.dart';

final randomEventProvider = StateProvider<RandomEvent?>((ref) => null);

final eventProductionMultiplierProvider = Provider<double>((ref) {
  final event = ref.watch(randomEventProvider);
  if (event == null) return 1.0;
  return event.productionMultiplier;
});

final eventClickMultiplierProvider = Provider<double>((ref) {
  final event = ref.watch(randomEventProvider);
  if (event == null) return 1.0;
  return event.clickMultiplier;
});

final eventTokenMultiplierProvider = Provider<double>((ref) {
  final event = ref.watch(randomEventProvider);
  if (event == null) return 1.0;
  return event.tokenMultiplier;
});
