import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/constants.dart';
import '../../models/cake_accessory.dart';
import '../../models/potion.dart';
import '../../models/potion_color.dart';
import '../../providers/accessory_provider.dart';
import '../../providers/potion_provider.dart';
import '../../models/potion_effect.dart';
import '../../theme/tokens.dart';
import '../shop/forus_shop.dart';
import 'widgets/animated_cauldron.dart';
import 'widgets/potion_riddles_dialog.dart';
import 'dart:async';

class CauldronPage extends ConsumerStatefulWidget {
  const CauldronPage({super.key});

  @override
  ConsumerState<CauldronPage> createState() => _CauldronPageState();
}

class _CauldronPageState extends ConsumerState<CauldronPage> {
  Timer? _effectUpdateTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(potionNotifierProvider).updateActiveEffects();
      }
    });
    _effectUpdateTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        ref.read(potionNotifierProvider).updateActiveEffects();
      }
    });
  }

  @override
  void dispose() {
    _effectUpdateTimer?.cancel();
    super.dispose();
  }

  void _addItemToCauldron(CakeAccessory accessory, int quantity) {
    ref.read(potionNotifierProvider).addItemToCauldron(accessory, quantity);
  }

  Widget _buildAddButton(
    String label,
    int quantity,
    int availableQuantity,
    CakeAccessory accessory,
    bool isMobile,
  ) {
    final canAdd = availableQuantity > 0 && quantity <= availableQuantity;
    final actualQuantity =
        quantity > availableQuantity ? availableQuantity : quantity;

    return ElevatedButton(
      onPressed: canAdd
          ? () {
              _addItemToCauldron(accessory, actualQuantity);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: canAdd ? AppColors.primary : AppColors.muted,
        foregroundColor: AppColors.foreground,
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 6 : 12,
          vertical: isMobile ? 12 : 12,
        ),
        minimumSize: isMobile ? const Size(0, 44) : Size.zero,
        tapTargetSize: isMobile
            ? MaterialTapTargetSize.padded
            : MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.sm),
        ),
        elevation: canAdd ? AppElevations.level2 : 0,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: isMobile ? 11 : 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = GameConstants.isMobile(context);
    final cauldron = ref.watch(cauldronProvider);
    final inventory = ref.watch(inventoryProvider);
    final potionNotifier = ref.read(potionNotifierProvider);
    final availablePotions = potionNotifier.getAvailablePotions();
    final cauldronUnlocked = ref.watch(cauldronUnlockedProvider);
    final activeEffects = ref.watch(activePotionEffectsProvider);

    if (!cauldronUnlocked) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('Caldeirão de Poções'),
          backgroundColor: AppColors.card,
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(GameConstants.getDefaultPadding(context)),
            child: Card(
              child: Padding(
                padding:
                    EdgeInsets.all(isMobile ? AppSpacing.xl : AppSpacing.xxl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '🧪',
                      style: TextStyle(fontSize: isMobile ? 64 : 80),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Caldeirão Bloqueado',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.foreground,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Compre o Caldeirão de Poções na Loja de Forus para começar a criar poções mágicas!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppColors.mutedForeground,
                          ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const ForusShopPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag, size: 24),
                      label: const Text('Ir para Loja de Forus'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.cyan500,
                        foregroundColor: AppColors.foreground,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xl,
                          vertical: AppSpacing.lg,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Caldeirão de Poções'),
        backgroundColor: AppColors.card,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: AppSpacing.sm),
            child: FilledButton.icon(
              onPressed: () {
                PotionRiddlesDialog.show(context);
              },
              icon: const Icon(Icons.auto_stories, size: 20),
              label: const Text(
                'Receitas',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.amber500,
                foregroundColor: AppColors.foreground,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadii.lg),
                ),
              ),
            ),
          ),
          if (kDebugMode)
            IconButton(
              icon: const Icon(Icons.bug_report, color: AppColors.destructive),
              tooltip: 'Debug: Ativar efeito de poção',
              onPressed: () => _showDebugPotionDialog(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(GameConstants.getDefaultPadding(context)),
        child: Column(
          children: [
            if (activeEffects.isNotEmpty)
              _buildActiveEffects(activeEffects, isMobile),
            if (activeEffects.isNotEmpty) SizedBox(height: isMobile ? 16 : 24),
            _buildCauldronDisplay(cauldron, isMobile),
            // SizedBox(height: isMobile ? 16 : 24),
            // if (bestPotion != null) _buildBestPotionCard(bestPotion, isMobile),
            SizedBox(height: isMobile ? 16 : 24),
            if (isMobile)
              Column(
                children: [
                  SizedBox(
                    height: 300,
                    child: _buildInventoryList(inventory, isMobile),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: _buildAvailablePotions(availablePotions, isMobile),
                  ),
                ],
              )
            else
              SizedBox(
                height: 400,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: _buildInventoryList(inventory, isMobile),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 1,
                      child: _buildAvailablePotions(availablePotions, isMobile),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveEffects(List effects, bool isMobile) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(isMobile ? AppSpacing.md : AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppColors.emerald500,
                  size: isMobile ? 20 : 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Efeitos Ativos',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: effects.map((effect) {
                final potionEffect = effect as PotionEffect;
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.emerald500.withAlpha(40),
                        AppColors.emerald600.withAlpha(30),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                      color: AppColors.emerald500.withAlpha(150),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.emerald500.withAlpha(50),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.emerald500,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.emerald500.withAlpha(200),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        potionEffect.description,
                        style: TextStyle(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.bold,
                          fontSize: isMobile ? 11 : 12,
                        ),
                      ),
                      if (!potionEffect.isPermanent &&
                          potionEffect.expiresAt != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald500.withAlpha(60),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Text(
                            _formatDuration(potionEffect.expiresAt!
                                .difference(DateTime.now())),
                            style: const TextStyle(
                              color: AppColors.foreground,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    if (duration.isNegative) return 'Expirado';
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  Widget _buildCauldronDisplay(Map<PotionColor, int> cauldron, bool isMobile) {
    final totalColors = cauldron.values.fold(0, (sum, count) => sum + count);
    final cauldronSize = isMobile ? 200.0 : 280.0;

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(isMobile ? AppSpacing.lg : AppSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.lg),
              AnimatedCauldron(
                cauldron: cauldron,
                size: cauldronSize,
              ),
              const SizedBox(height: AppSpacing.lg),
              if (totalColors == 0)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.muted.withAlpha(40),
                        AppColors.muted.withAlpha(20),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(AppRadii.md),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.mutedForeground,
                        size: isMobile ? 18 : 20,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Adicione itens ao caldeirão',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedForeground,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ],
                  ),
                )
              else ...[
                Container(
                  constraints: const BoxConstraints(
                    minHeight: 80,
                    maxHeight: 120,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F1115),
                    borderRadius: BorderRadius.circular(AppRadii.lg),
                    border: Border.all(
                      color: AppColors.border,
                      width: 1,
                    ),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: cauldron.entries.map((entry) {
                        return Container(
                          margin: const EdgeInsets.only(right: AppSpacing.sm),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: entry.key.color.withAlpha(30),
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            border: Border.all(
                              color: entry.key.color.withAlpha(150),
                              width: 1.5,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: entry.key.color.withAlpha(80),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: entry.key.color,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: entry.key.color.withAlpha(200),
                                      blurRadius: 6,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                '${entry.key.name}: ${entry.value}',
                                style: TextStyle(
                                  color: AppColors.foreground,
                                  fontWeight: FontWeight.bold,
                                  fontSize: isMobile ? 11 : 13,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                FilledButton.icon(
                  onPressed: () {
                    ref.read(potionNotifierProvider).clearCauldron();
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Limpar Caldeirão'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.destructive,
                    foregroundColor: AppColors.destructiveForeground,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInventoryList(Map<String, int> inventory, bool isMobile) {
    final items = inventory.entries.toList();
    items.sort((a, b) {
      final accA = allAccessories.firstWhere((acc) => acc.id == a.key);
      final accB = allAccessories.firstWhere((acc) => acc.id == b.key);
      return accB.rarity.value.compareTo(accA.rarity.value);
    });

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  Icons.inventory_2,
                  color: AppColors.primary,
                  size: isMobile ? 20 : 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Inventário',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        'Nenhum item no inventário',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                      ),
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: isMobile ? 160 : 200,
                      mainAxisExtent: isMobile ? 200 : 200,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                    ),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final entry = items[index];
                      final accessory = allAccessories.firstWhere(
                        (acc) => acc.id == entry.key,
                      );
                      final color = getItemColor(accessory);
                      final colorValue = getItemColorValue(accessory);

                      final equipped = ref.watch(equippedAccessoriesProvider);
                      final equippedCount =
                          equipped.where((id) => id == entry.key).length;
                      final availableQuantity = entry.value - equippedCount;

                      return Container(
                        decoration: BoxDecoration(
                          color: color.color.withAlpha(20),
                          borderRadius: BorderRadius.circular(AppRadii.md),
                          border: Border.all(
                            color: color.color.withAlpha(150),
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: color.color.withAlpha(60),
                              blurRadius: 8,
                              spreadRadius: 0,
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                            child: Padding(
                              padding: EdgeInsets.all(
                                isMobile ? AppSpacing.xs : AppSpacing.sm,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: isMobile ? 44 : 48,
                                        height: isMobile ? 44 : 48,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF0F1115),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: color.color.withAlpha(200),
                                            width: 2,
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: color.color.withAlpha(80),
                                              blurRadius: 8,
                                              spreadRadius: 0,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Text(
                                            accessory.emoji,
                                            style: TextStyle(
                                              fontSize: isMobile ? 20 : 24,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 0,
                                        right: 0,
                                        child: Container(
                                          width: isMobile ? 25 : 28,
                                          height: isMobile ? 25 : 28,
                                          decoration: BoxDecoration(
                                            color: color.color,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: const Color(0xFF0F1115),
                                              width: 2,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: color.color.withAlpha(150),
                                                blurRadius: 4,
                                                spreadRadius: 0,
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: Text(
                                              '+$colorValue',
                                              style: TextStyle(
                                                color: AppColors.foreground,
                                                fontSize: isMobile ? 11 : 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Text(
                                    accessory.name,
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.foreground,
                                          fontSize: isMobile ? 10 : 11,
                                        ),
                                  ),
                                  const SizedBox(height: AppSpacing.xs),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Tem  ',
                                        style: TextStyle(
                                          color: AppColors.emerald500
                                              .withAlpha(100),
                                          fontSize: isMobile ? 9 : 10,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: AppSpacing.xs,
                                          vertical: 2,
                                        ),
                                        decoration: BoxDecoration(
                                          color: availableQuantity > 0
                                              ? AppColors.emerald500
                                                  .withAlpha(30)
                                              : AppColors.destructive
                                                  .withAlpha(30),
                                          borderRadius: BorderRadius.circular(
                                              AppRadii.sm),
                                          border: Border.all(
                                            color: availableQuantity > 0
                                                ? AppColors.emerald500
                                                    .withAlpha(100)
                                                : AppColors.destructive
                                                    .withAlpha(100),
                                            width: 1,
                                          ),
                                        ),
                                        child: Text(
                                          '${availableQuantity}x',
                                          style: TextStyle(
                                            color: availableQuantity > 0
                                                ? AppColors.emerald500
                                                : AppColors.destructive,
                                            fontSize: isMobile ? 8 : 9,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: isMobile
                                        ? AppSpacing.xs
                                        : AppSpacing.sm,
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Expanded(
                                        child: _buildAddButton(
                                          '+1',
                                          1,
                                          availableQuantity,
                                          accessory,
                                          isMobile,
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? 3 : 4),
                                      Expanded(
                                        child: _buildAddButton(
                                          '+10',
                                          10,
                                          availableQuantity,
                                          accessory,
                                          isMobile,
                                        ),
                                      ),
                                      SizedBox(width: isMobile ? 3 : 4),
                                      Expanded(
                                        child: _buildAddButton(
                                          'MAX',
                                          availableQuantity,
                                          availableQuantity,
                                          accessory,
                                          isMobile,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailablePotions(List<Potion> potions, bool isMobile) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Icon(
                  Icons.science,
                  color: AppColors.fuchsia500,
                  size: isMobile ? 20 : 24,
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Poções Disponíveis',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.foreground,
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: potions.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Text(
                        'Nenhuma poção disponível\nAdicione itens ao caldeirão',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                      ),
                    ),
                  )
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    itemCount: potions.length,
                    itemBuilder: (context, index) {
                      final potion = potions[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.xs,
                          vertical: AppSpacing.xs,
                        ),
                        child: InkWell(
                          onTap: () {
                            final potionNotifier =
                                ref.read(potionNotifierProvider);
                            final activeCount =
                                ref.read(activePotionCountProvider);
                            final currentCount = activeCount[potion.id] ?? 0;

                            if (currentCount >= 10) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      '❌ Limite de 10 poções iguais atingido!'),
                                  backgroundColor: AppColors.destructive,
                                ),
                              );
                              return;
                            }

                            potionNotifier.brewPotion(potion);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('✅ ${potion.name} criada!'),
                                backgroundColor: AppColors.emerald500,
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(AppRadii.lg),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primary.withAlpha(30),
                                  AppColors.fuchsia500.withAlpha(20),
                                ],
                              ),
                              borderRadius: BorderRadius.circular(AppRadii.lg),
                              border: Border.all(
                                color: AppColors.primary.withAlpha(100),
                                width: 1,
                              ),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: AppSpacing.sm,
                              ),
                              leading: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.primary.withAlpha(80),
                                      AppColors.fuchsia500.withAlpha(60),
                                    ],
                                  ),
                                  borderRadius:
                                      BorderRadius.circular(AppRadii.md),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withAlpha(80),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    potion.emoji,
                                    style: const TextStyle(fontSize: 24),
                                  ),
                                ),
                              ),
                              title: Text(
                                potion.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.foreground,
                                    ),
                              ),
                              subtitle: Padding(
                                padding:
                                    const EdgeInsets.only(top: AppSpacing.xs),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      potion.description,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppColors.mutedForeground,
                                          ),
                                    ),
                                    const SizedBox(height: AppSpacing.xs),
                                    Wrap(
                                      spacing: AppSpacing.xs,
                                      runSpacing: AppSpacing.xs,
                                      children: potion.effects.map((effect) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: AppSpacing.xs,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: AppColors.emerald500
                                                .withAlpha(40),
                                            borderRadius: BorderRadius.circular(
                                                AppRadii.sm),
                                          ),
                                          child: Text(
                                            effect.description,
                                            style: const TextStyle(
                                              color: AppColors.emerald500,
                                              fontSize: 9,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                                size: 16,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _showDebugPotionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug: Ativar Efeito de Poção'),
        backgroundColor: AppColors.card,
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: allPotions.length,
            itemBuilder: (context, index) {
              final potion = allPotions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: ListTile(
                  leading: Text(
                    potion.emoji,
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    potion.name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.foreground,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        potion.description,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.mutedForeground,
                            ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ...potion.effects.map((effect) {
                        return Container(
                          margin: const EdgeInsets.only(bottom: AppSpacing.xs),
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.emerald500.withAlpha(40),
                            borderRadius: BorderRadius.circular(AppRadii.sm),
                          ),
                          child: Text(
                            effect.description,
                            style: const TextStyle(
                              color: AppColors.emerald500,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                  onTap: () {
                    ref
                        .read(potionNotifierProvider)
                        .activatePotionEffectDebug(potion);
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('✅ ${potion.name} ativada!'),
                        backgroundColor: AppColors.emerald500,
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(potionNotifierProvider).clearAllEffects();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🗑️ Todos os efeitos foram removidos!'),
                  backgroundColor: AppColors.amber500,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: AppColors.destructive,
            ),
            child: const Text('Limpar Todos os Efeitos'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}
