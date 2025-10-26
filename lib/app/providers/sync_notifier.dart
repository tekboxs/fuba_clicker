import 'package:flutter_riverpod/flutter_riverpod.dart';

class SyncNotifier extends StateNotifier<bool> {
  SyncNotifier() : super(false);

  void notifyDataLoaded() {
    state = true;
  }

  void reset() {
    state = false;
  }
}

final syncNotifierProvider = StateNotifierProvider<SyncNotifier, bool>((ref) {
  return SyncNotifier();
});
