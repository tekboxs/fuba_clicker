import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/models/forus_upgrade.dart';
import 'package:fuba_clicker/app/providers/rebirth_provider.dart';
import 'package:fuba_clicker/app/providers/save_provider.dart';
import 'package:fuba_clicker/app/modules/shop/components/forus_upgrade_card.dart';
import 'package:fuba_clicker/gen/assets.gen.dart';

class ForusShopPage extends ConsumerWidget {
  const ForusShopPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final forus = ref.watch(rebirthDataProvider).forus;
    final isMobile = GameConstants.isMobile(context);

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(240),
      appBar: AppBar(
        title: const Text('Loja de Forus'),
        backgroundColor: Colors.cyan.withAlpha(200),
      ),
      body: Padding(
        padding: EdgeInsets.all(GameConstants.getDefaultPadding(context)),
        child: Column(
          children: [
            Container(
              constraints: const BoxConstraints(maxWidth: 400, minWidth: 250),
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                color: const Color(0xff1A1D23),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan.withAlpha(100),
                    blurRadius: 30,
                    offset: const Offset(0, 0),
                  ),
                  BoxShadow(
                    color: Colors.cyan.withAlpha(50),
                    blurRadius: 50,
                    offset: const Offset(0, -10),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    Assets.images.forus.path,
                    width: isMobile ? 40 : 45,
                    height: isMobile ? 40 : 45,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.diamond,
                        size: 45,
                        color: Colors.cyan,
                      );
                    },
                  ),
                  const SizedBox(width: 30),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Forus',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.cyan,
                        ),
                      ),
                      Text(
                        forus.toStringAsFixed(0),
                        style: TextStyle(
                          fontSize: isMobile ? 28 : 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: isMobile ? 24 : 32),
            if (kDebugMode)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        final rebirthData = ref.read(rebirthDataProvider);
                        ref.read(rebirthDataProvider.notifier).state =
                            rebirthData.copyWith(forus: rebirthData.forus + 10);
                        ref.read(saveNotifierProvider.notifier).saveImmediate();
                      },
                      icon: const Icon(Icons.add_circle),
                      label: const Text('+10 Forus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        final rebirthData = ref.read(rebirthDataProvider);
                        ref.read(rebirthDataProvider.notifier).state =
                            rebirthData.copyWith(
                          celestialTokens: rebirthData.celestialTokens + 1000,
                        );
                        ref.read(saveNotifierProvider.notifier).saveImmediate();
                      },
                      icon: const Icon(Icons.add_circle),
                      label: const Text('+1000 Tokens'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: isMobile ? 350 : 300,
                  mainAxisExtent: isMobile ? 300 : 250,
                  crossAxisSpacing: isMobile ? 16 : 20,
                  mainAxisSpacing: isMobile ? 16 : 20,
                ),
                itemCount: allForusUpgrades.length,
                itemBuilder: (context, index) {
                  final upgrade = allForusUpgrades[index];
                  return ForusUpgradeCard(
                    upgrade: upgrade,
                    isMobile: isMobile,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
