import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/services/api_service.dart';
import 'package:fuba_clicker/app/services/save_service.dart';
import 'package:fuba_clicker/app/providers/game_providers.dart';
import 'package:fuba_clicker/app/providers/accessory_provider.dart';
import 'package:fuba_clicker/app/providers/achievement_provider.dart';
import 'package:fuba_clicker/app/providers/rebirth_provider.dart';
import 'package:fuba_clicker/app/providers/rebirth_upgrade_provider.dart';
import 'package:fuba_clicker/app/providers/forus_upgrade_provider.dart';
import 'package:fuba_clicker/app/providers/auth_provider.dart';
import 'package:fuba_clicker/app/models/fuba_generator.dart';
import 'package:fuba_clicker/app/models/rebirth_data.dart';
import 'package:fuba_clicker/app/core/utils/efficient_number.dart';
import 'package:fuba_clicker/app/modules/home/home_page.dart';

class InscribedPage extends ConsumerStatefulWidget {
  const InscribedPage({super.key});

  @override
  ConsumerState<InscribedPage> createState() => _InscribedPageState();
}

class _InscribedPageState extends ConsumerState<InscribedPage> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;

  Future<void> _handleInscription() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A0E27),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: Colors.deepOrange.withAlpha(150),
            width: 2,
          ),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.deepOrange,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              '⚠️ ATENÇÃO: Reset Completo',
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ao se inscrever no Ranking Especial, TODOS os seus dados serão resetados!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Isso inclui:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                '• Todo o fubá\n'
                '• Todos os geradores\n'
                '• Todos os acessórios\n'
                '• Todas as conquistas\n'
                '• Todos os upgrades\n'
                '• Todos os rebirths\n'
                '• Todos os tokens celestiais\n'
                '• Todas as estatísticas',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 16),
              Text(
                'Você começará do ZERO, mas poderá competir no Ranking Especial exclusivo para jogadores inscritos!',
                style: TextStyle(
                  color: Colors.amber,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Esta ação NÃO PODE ser desfeita!',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'CONFIRMAR INSCRIÇÃO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _apiService.inscribeUser();

      ref.read(fubaProvider.notifier).state = const EfficientNumber.zero();

      ref.read(generatorsProvider.notifier).state = List.filled(
        availableGenerators.length,
        0,
      );

      ref.read(inventoryProvider.notifier).state = <String, int>{};

      ref.read(equippedAccessoriesProvider.notifier).state = <String>[];

      ref.read(rebirthDataProvider.notifier).state = const RebirthData();

      ref.read(unlockedAchievementsProvider.notifier).state = <String>[];

      ref.read(achievementStatsProvider.notifier).state = <String, double>{};

      ref.read(upgradesLevelProvider.notifier).state = <String, int>{};

      ref.read(forusUpgradesOwnedProvider.notifier).state = <String>{};

      final saveService = SaveService();
      await saveService.clearSave();

      await ref.read(authNotifierProvider.notifier).refreshUserData();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(
            builder: (context) => const HomePage(),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao se inscrever: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Ranking Especial'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0A0E27),
                  Color(0xFF2D1B4E),
                  Color(0xFF0F172A),
                ],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.deepOrange.withAlpha(30),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.deepOrange.withAlpha(150),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.emoji_events,
                      size: 80,
                      color: Colors.deepOrange,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Ranking Especial',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Participe de um ranking exclusivo e ganhe cupom de 50% da DevScout!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.deepOrange.withAlpha(100),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.deepOrange,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Como funciona:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        _buildInfoItem(
                          '✓',
                          'Você compete apenas com outros jogadores inscritos',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          '✓',
                          'Todos os dados são resetados para garantir igualdade',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          '✓',
                          'Ranking separado do ranking geral',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          '🎁',
                          'Ganhe cupom de 50% da DevScout para o primeiro lugar no rank até dia 12/04',
                        ),
                        const SizedBox(height: 12),
                        _buildInfoItem(
                          '⚠',
                          'Ação irreversível - todos os progressos serão perdidos',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleInscription,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'Inscrever-se no Ranking Especial',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          icon,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ),
      ],
    );
  }
}

