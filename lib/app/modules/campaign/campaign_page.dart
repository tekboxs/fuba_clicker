import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/campaign_data.dart';
import '../../providers/campaign_provider.dart';
import '../../providers/rebirth_provider.dart';
import '../../providers/rebirth_upgrade_provider.dart';
import '../../providers/save_provider.dart';

class CampaignPage extends ConsumerStatefulWidget {
  const CampaignPage({super.key});

  @override
  ConsumerState<CampaignPage> createState() => _CampaignPageState();
}

class _CampaignPageState extends ConsumerState<CampaignPage>
    with SingleTickerProviderStateMixin {
  Timer? _battleTimer;
  late AnimationController _hitController;
  bool _showHit = false;

  @override
  void initState() {
    super.initState();
    _hitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _battleTimer?.cancel();
    _hitController.dispose();
    super.dispose();
  }

  void _startBattle(int phase) {
    ref.read(campaignNotifierProvider).startBattle(phase);
    _startBattleTimer();
  }

  void _startBattleTimer() {
    _battleTimer?.cancel();
    _battleTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final battle = ref.read(activeBattleProvider);
      if (battle == null) {
        _battleTimer?.cancel();
        return;
      }
      ref.read(campaignNotifierProvider).tickTimer();
      // Auto-damage from auto-clicker
      final autoRate = ref.read(upgradeNotifierProvider).getAutoClickerRate();
      if (autoRate > 0) {
        ref.read(campaignNotifierProvider).dealDamage(autoRate);
      }
      setState(() {});
      if (battle.finished) {
        _battleTimer?.cancel();
        if (battle.won) _handleVictory(battle);
      }
    });
  }

  void _handlePlayerTap() {
    final battle = ref.read(activeBattleProvider);
    if (battle == null || battle.finished) return;
    ref.read(campaignNotifierProvider).dealDamage(1.0);
    setState(() => _showHit = true);
    _hitController.forward().then((_) {
      _hitController.reset();
      if (mounted) setState(() => _showHit = false);
    });
    final b = ref.read(activeBattleProvider);
    if (b != null && b.finished && b.won) {
      _battleTimer?.cancel();
      _handleVictory(b);
    }
  }

  void _handleVictory(CampaignBattle battle) {
    final notifier = ref.read(campaignNotifierProvider);
    notifier.claimVictory();
    // Give rewards
    final rebirthNotifier = ref.read(rebirthNotifierProvider);
    rebirthNotifier.addTokens(battle.phase.tokenReward.toDouble());
    if (battle.phase.forusReward > 0) {
      rebirthNotifier.addForus(battle.phase.forusReward);
    }
    ref.read(saveNotifierProvider.notifier).saveImmediate();
    if (mounted) _showResultDialog(true, battle.phase);
  }

  void _showResultDialog(bool won, CampaignPhase phase) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          won ? '🏆 Vitória!' : '💀 Derrota',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: won ? Colors.amber : Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              won
                  ? 'Fase ${phase.phase} concluída!'
                  : 'Tente novamente quando estiver mais forte!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            if (won) ...[
              const SizedBox(height: 12),
              _rewardChip('⭐ ${phase.tokenReward} tokens', Colors.amber),
              if (phase.forusReward > 0)
                _rewardChip(
                    '💎 ${_formatForus(phase.forusReward)} forus', Colors.cyan),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(won ? 'Continuar' : 'Fechar',
                style: const TextStyle(color: Colors.white70)),
          ),
          if (!won)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _startBattle(phase.phase);
              },
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Tentar novamente'),
            ),
        ],
      ),
    );
  }

  Widget _rewardChip(String label, Color color) => Container(
        margin: const EdgeInsets.only(top: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Text(label,
            style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      );

  String _formatForus(double value) {
    return value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final battle = ref.watch(activeBattleProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF090B14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF090B14),
        elevation: 0,
        title: const Text('Campanha do Milharal',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          if (battle != null)
            TextButton(
              onPressed: () {
                ref.read(campaignNotifierProvider).abandonBattle();
                _battleTimer?.cancel();
                setState(() {});
              },
              child: const Text('Abandonar',
                  style: TextStyle(color: Colors.redAccent)),
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF090B14), Color(0xFF151022), Color(0xFF24170A)],
          ),
        ),
        child: battle != null ? _buildBattle(battle) : _buildPhaseList(),
      ),
    );
  }

  Widget _buildPhaseList() {
    final maxCleared = ref.watch(campaignMaxPhaseProvider);
    final phases = CampaignPhase.allPhases;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        _buildCampaignHeader(maxCleared),
        const SizedBox(height: 14),
        for (final phase in phases)
          _buildPhaseCard(
            phase,
            phase.phase <= maxCleared + 1,
            phase.phase <= maxCleared,
          ),
      ],
    );
  }

  Widget _buildCampaignHeader(int maxCleared) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF3A2405), Color(0xFF171A35)],
        ),
        border: Border.all(color: Colors.amber.withOpacity(0.35)),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.12),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: Colors.amber.withOpacity(0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.amber.withOpacity(0.45)),
            ),
            child:
                const Center(child: Text('⚔️', style: TextStyle(fontSize: 28))),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Avance pelo milharal sombrio',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Maior fase concluída: $maxCleared • Bosses rendem 0.5 forus',
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhaseCard(CampaignPhase phase, bool isUnlocked, bool isCleared) {
    final borderColor = phase.isBoss
        ? Colors.amber
        : isCleared
            ? Colors.green
            : isUnlocked
                ? Colors.blue
                : Colors.grey.shade700;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: isUnlocked ? 1 : 0.56,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: phase.isBoss
                ? [const Color(0xFF2C1A06), const Color(0xFF151727)]
                : [const Color(0xFF151A2D), const Color(0xFF11131F)],
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor.withOpacity(0.6), width: 1.5),
          boxShadow: isUnlocked
              ? [
                  BoxShadow(
                    color: borderColor.withOpacity(0.13),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          leading: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: borderColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: borderColor.withOpacity(0.3)),
            ),
            child: Center(
              child: Text(
                isUnlocked ? phase.enemyEmoji : '🔒',
                style: const TextStyle(fontSize: 25),
              ),
            ),
          ),
          title: Row(
            children: [
              Text(
                'Fase ${phase.phase}',
                style: TextStyle(
                  color: isUnlocked ? Colors.white : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (phase.isBoss)
                Container(
                  margin: const EdgeInsets.only(left: 6),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.amber.withOpacity(0.5)),
                  ),
                  child: const Text('BOSS',
                      style: TextStyle(
                          color: Colors.amber,
                          fontSize: 10,
                          fontWeight: FontWeight.bold)),
                ),
              if (isCleared)
                const Padding(
                  padding: EdgeInsets.only(left: 6),
                  child:
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                ),
            ],
          ),
          subtitle: isUnlocked
              ? Text(
                  '${phase.enemyName} • ${phase.maxHp.toInt()} HP • ${phase.timerSeconds}s',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                )
              : const Text('Conclua a fase anterior',
                  style: TextStyle(color: Colors.grey, fontSize: 11)),
          trailing: isUnlocked
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('⭐ ${phase.tokenReward}',
                        style:
                            const TextStyle(color: Colors.amber, fontSize: 11)),
                    if (phase.forusReward > 0)
                      Text('💎 ${_formatForus(phase.forusReward)}',
                          style: const TextStyle(
                              color: Colors.cyan, fontSize: 11)),
                  ],
                )
              : null,
          onTap: isUnlocked
              ? () {
                  _startBattle(phase.phase);
                  setState(() {});
                }
              : null,
        ),
      ),
    );
  }

  Widget _buildBattle(CampaignBattle battle) {
    final hpColor = battle.hpPercent > 0.5
        ? Colors.green
        : battle.hpPercent > 0.25
            ? Colors.orange
            : Colors.red;

    final timeColor = battle.secondsRemaining > 20
        ? Colors.white
        : battle.secondsRemaining > 10
            ? Colors.orange
            : Colors.red;

    return Column(
      children: [
        // Timer and phase info
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Fase ${battle.phase.phase}',
                  style: const TextStyle(
                      color: Colors.white70, fontWeight: FontWeight.bold)),
              Row(
                children: [
                  Icon(Icons.timer, color: timeColor, size: 16),
                  const SizedBox(width: 4),
                  Text('${battle.secondsRemaining}s',
                      style: TextStyle(
                          color: timeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                ],
              ),
            ],
          ),
        ),

        // HP bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(battle.phase.enemyName,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                  Text(
                      '${battle.currentHp.toInt()} / ${battle.phase.maxHp.toInt()} HP',
                      style:
                          const TextStyle(color: Colors.white60, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: battle.hpPercent,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation(hpColor),
                  minHeight: 14,
                ),
              ),
            ],
          ),
        ),

        // Enemy tap area
        Expanded(
          child: GestureDetector(
            onTap: _handlePlayerTap,
            child: Center(
              child: AnimatedScale(
                scale: _showHit ? 0.88 : 1.0,
                duration: const Duration(milliseconds: 80),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: battle.phase.isBoss
                            ? Colors.amber.withOpacity(0.1)
                            : Colors.blue.withOpacity(0.08),
                        border: Border.all(
                          color: battle.phase.isBoss
                              ? Colors.amber.withOpacity(0.5)
                              : Colors.blue.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                    ),
                    Text(
                      battle.phase.enemyEmoji,
                      style: const TextStyle(fontSize: 96),
                    ),
                    if (_showHit)
                      const Positioned(
                        top: 20,
                        right: 20,
                        child: Text('💥', style: TextStyle(fontSize: 36)),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Auto-clicker info
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Builder(builder: (context) {
            final autoRate =
                ref.read(upgradeNotifierProvider).getAutoClickerRate();
            return Text(
              autoRate > 0
                  ? '🤖 Auto: ${autoRate.toInt()} dmg/s  |  👆 Toque para atacar'
                  : '👆 Toque para atacar',
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            );
          }),
        ),

        // Timer progress bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: battle.secondsRemaining / battle.phase.timerSeconds,
                  backgroundColor: Colors.grey.shade800,
                  valueColor: AlwaysStoppedAnimation(timeColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
