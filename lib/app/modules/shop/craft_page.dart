import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/models/cake_accessory.dart';
import 'package:fuba_clicker/app/models/craft_recipe.dart';
import 'package:fuba_clicker/app/providers/accessory_provider.dart';
import 'package:fuba_clicker/app/providers/rebirth_provider.dart';
import 'package:fuba_clicker/app/providers/save_provider.dart';
import 'package:fuba_clicker/gen/assets.gen.dart';

class CraftPage extends ConsumerStatefulWidget {
  const CraftPage({super.key});

  @override
  ConsumerState<CraftPage> createState() => _CraftPageState();
}

class _CraftPageState extends ConsumerState<CraftPage> {
  @override
  Widget build(BuildContext context) {
    final isMobile = GameConstants.isMobile(context);

    const craftableRecipes = allCraftRecipes;

    return Scaffold(
      backgroundColor: Colors.black.withAlpha(240),
      appBar: AppBar(
        title: const Text('Receitas de Craft'),
        backgroundColor: Colors.purple.withAlpha(200),
      ),
      body: Padding(
        padding: EdgeInsets.all(GameConstants.getDefaultPadding(context)),
        child: Column(
          children: [
            if (isMobile)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withAlpha(100)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Use materiais do inventário para criar itens únicos através de receitas!',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ),
                  ],
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.withAlpha(50),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.withAlpha(100)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue, size: 28),
                    SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Use materiais do inventário para criar itens únicos através de receitas!',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: isMobile ? 16 : 24),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 650,
                    crossAxisSpacing: 16,
                    mainAxisExtent: 480,
                    mainAxisSpacing: 16

                    ),
                padding: const EdgeInsets.all(16),
                itemCount: craftableRecipes.length,
                itemBuilder: (context, index) {
                  final recipe = craftableRecipes[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildRecipeCard(recipe),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeCard(CraftRecipe recipe) {
    final isMobile = GameConstants.isMobile(context);
    final inventory = ref.watch(inventoryProvider);
    final equipped = ref.watch(equippedAccessoriesProvider);
    final rebirthData = ref.watch(rebirthDataProvider);
    final outputAccessory =
        allAccessories.firstWhere((a) => a.id == recipe.outputId);
    final canCraft = recipe.canCraft(
      inventory,
      equipped,
      forus: rebirthData.forus,
      celestialTokens: rebirthData.celestialTokens,
    );

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F1115),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: canCraft
              ? outputAccessory.rarity.color.withAlpha(200)
              : Colors.grey.withAlpha(100),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: canCraft
                ? outputAccessory.rarity.color.withOpacity(0.15)
                : Colors.black.withAlpha(100),
            blurRadius: 24,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: isMobile ? 64 : 80,
                  height: isMobile ? 64 : 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1D23),
                    boxShadow: [
                      BoxShadow(
                        color: outputAccessory.rarity.color.withOpacity(0.15),
                        blurRadius: 10,
                      ),
                    ],
                    borderRadius: const BorderRadius.all(Radius.circular(12)),
                  ),
                  child: Center(
                    child: Text(
                      outputAccessory.emoji,
                      style: TextStyle(fontSize: isMobile ? 38 : 48),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        outputAccessory.name,
                        style: TextStyle(
                          fontSize: isMobile ? 20 : 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        outputAccessory.rarity.displayName,
                        style: TextStyle(
                          fontSize: isMobile ? 14 : 16,
                          color: outputAccessory.rarity.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recipe.description,
                        style: TextStyle(
                          fontSize: isMobile ? 12 : 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.white24),
            const SizedBox(height: 16),
            Text(
              'Recursos necessários:',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: canCraft
                        ? Colors.green.withAlpha(30)
                        : Colors.grey.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: canCraft
                          ? Colors.green.withAlpha(100)
                          : Colors.grey.withAlpha(100),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canCraft)
                        Assets.images.forus.image(width: 30, height: 30)
                      else
                        const Text('❓', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 4),
                      Text(
                        canCraft ? recipe.forusCost.toStringAsFixed(0) : '???',
                        style: TextStyle(
                          color: canCraft ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: canCraft
                        ? Colors.green.withAlpha(30)
                        : Colors.grey.withAlpha(30),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: canCraft
                          ? Colors.green.withAlpha(100)
                          : Colors.grey.withAlpha(100),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (canCraft)
                        const Text('💎', style: TextStyle(fontSize: 20))
                      else
                        const Text('❓', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 4),
                      Text(
                        canCraft
                            ? recipe.celestialTokensCost.toStringAsFixed(0)
                            : '???',
                        style: TextStyle(
                          color: canCraft ? Colors.green : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Materiais necessários:',
              style: TextStyle(
                fontSize: isMobile ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: canCraft
                  ? recipe.inputIds.asMap().entries.map((entry) {
                      final index = entry.key;
                      final itemId = entry.value;
                      final requiredQuantity = recipe.inputQuantities[index];
                      final accessory =
                          allAccessories.firstWhere((a) => a.id == itemId);

                      final totalQuantity = inventory[itemId] ?? 0;
                      final equippedCount =
                          equipped.where((id) => id == itemId).length;
                      final availableQuantity = totalQuantity - equippedCount;
                      final hasEnough = availableQuantity >= requiredQuantity;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: hasEnough
                              ? Colors.green.withAlpha(30)
                              : Colors.red.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: hasEnough
                                ? Colors.green.withAlpha(100)
                                : Colors.red.withAlpha(100),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              accessory.emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '$requiredQuantity',
                              style: TextStyle(
                                color: hasEnough ? Colors.green : Colors.red,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (!hasEnough) ...[
                              const SizedBox(width: 4),
                              Text(
                                '($availableQuantity)',
                                style: TextStyle(
                                  color: Colors.red.withAlpha(150),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      );
                    }).toList()
                  : [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(30),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.grey.withAlpha(100),
                          ),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('❓', style: TextStyle(fontSize: 20)),
                            SizedBox(width: 4),
                            Text(
                              '???',
                              style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: canCraft
                    ? () {
                        _performCraft(recipe);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canCraft
                      ? outputAccessory.rarity.color
                      : Colors.grey.withAlpha(100),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: canCraft ? 6 : 0,
                ),
                child: Text(
                  canCraft ? 'Criar' : 'Materiais insuficientes',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performCraft(CraftRecipe recipe) {
    final inventory = ref.read(inventoryProvider);
    final equipped = ref.read(equippedAccessoriesProvider);
    final rebirthData = ref.read(rebirthDataProvider);

    if (!recipe.canCraft(
      inventory,
      equipped,
      forus: rebirthData.forus,
      celestialTokens: rebirthData.celestialTokens,
    )) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Você não tem materiais suficientes!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final newInventory = Map<String, int>.from(inventory);

    for (int i = 0; i < recipe.inputIds.length; i++) {
      final itemId = recipe.inputIds[i];
      final quantity = recipe.inputQuantities[i];

      final currentCount = newInventory[itemId] ?? 0;
      newInventory[itemId] = currentCount - quantity;

      if (newInventory[itemId] == 0) {
        newInventory.remove(itemId);
      }
    }

    newInventory[recipe.outputId] = (newInventory[recipe.outputId] ?? 0) + 1;

    ref.read(inventoryProvider.notifier).state = newInventory;
    ref.read(rebirthDataProvider.notifier).state = rebirthData.copyWith(
      forus: rebirthData.forus - recipe.forusCost,
      celestialTokens: rebirthData.celestialTokens - recipe.celestialTokensCost,
    );
    ref.read(saveNotifierProvider.notifier).saveImmediate();

    final outputAccessory =
        allAccessories.firstWhere((a) => a.id == recipe.outputId);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ ${outputAccessory.name} criado!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
