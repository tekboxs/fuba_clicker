import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncConflictType {
  none,
  needsConfirmation,
}

class SyncNotifier extends StateNotifier<SyncConflictType> {
  SyncNotifier() : super(SyncConflictType.none);

  void notifyDataLoaded() {
    state = SyncConflictType.none;
  }

  void notifyConflict() {
    state = SyncConflictType.needsConfirmation;
  }

  void reset() {
    state = SyncConflictType.none;
  }
}

final syncNotifierProvider = StateNotifierProvider<SyncNotifier, SyncConflictType>((ref) {
  return SyncNotifier();
});
