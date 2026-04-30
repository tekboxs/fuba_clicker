import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/campaign_data.dart';

// Highest phase cleared (0 = none)
final campaignMaxPhaseProvider = StateProvider<int>((ref) => 0);

// Active battle (null = none)
final activeBattleProvider = StateProvider<CampaignBattle?>((ref) => null);

class CampaignNotifier {
  CampaignNotifier(this.ref);
  final Ref ref;

  void startBattle(int phase) {
    final phaseData = CampaignPhase.forPhase(phase);
    ref.read(activeBattleProvider.notifier).state =
        CampaignBattle(phase: phaseData);
  }

  // Returns true if enough damage was dealt to finish the battle
  void dealDamage(double dmg) {
    final battle = ref.read(activeBattleProvider);
    if (battle == null || battle.finished) return;
    battle.dealDamage(dmg);
    // Trigger rebuild by reassigning the same object (StateProvider needs a new notif)
    ref.read(activeBattleProvider.notifier).state = battle;
  }

  void tickTimer() {
    final battle = ref.read(activeBattleProvider);
    if (battle == null || battle.finished) return;
    battle.checkTimeout();
    ref.read(activeBattleProvider.notifier).state = battle;
  }

  void claimVictory() {
    final battle = ref.read(activeBattleProvider);
    if (battle == null || !battle.won) return;
    final cleared = battle.phase.phase;
    final current = ref.read(campaignMaxPhaseProvider);
    if (cleared > current) {
      ref.read(campaignMaxPhaseProvider.notifier).state = cleared;
    }
    ref.read(activeBattleProvider.notifier).state = null;
  }

  void abandonBattle() {
    ref.read(activeBattleProvider.notifier).state = null;
  }
}

final campaignNotifierProvider = Provider<CampaignNotifier>((ref) {
  return CampaignNotifier(ref);
});
