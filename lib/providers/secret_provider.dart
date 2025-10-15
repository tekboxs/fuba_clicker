import 'package:flutter_riverpod/flutter_riverpod.dart';

final unlockedSecretsProvider = StateProvider<Set<String>>((ref) {
  return {};
});

class SecretNotifier {
  SecretNotifier(this.ref);
  final Ref ref;

  void unlockSecret(String secretId) {
    final unlocked = ref.read(unlockedSecretsProvider);
    if (!unlocked.contains(secretId)) {
      ref.read(unlockedSecretsProvider.notifier).state = {
        ...unlocked,
        secretId,
      };
    }
  }

  bool isSecretUnlocked(String secretId) {
    return ref.read(unlockedSecretsProvider).contains(secretId);
  }
}

final secretNotifierProvider = Provider<SecretNotifier>((ref) {
  return SecretNotifier(ref);
});

