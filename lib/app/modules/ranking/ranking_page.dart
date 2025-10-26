import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/services/api_service.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';
import 'package:fuba_clicker/app/models/rebirth_data.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_desktop.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_compact.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_list_mobile.dart';

class RankingPage extends ConsumerStatefulWidget {
  const RankingPage({super.key});

  @override
  ConsumerState<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends ConsumerState<RankingPage> {
  final ApiService _apiService = ApiService();
  List<RankingEntry> _ranking = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final ranking = await _apiService.getRanking();
      setState(() {
        _ranking = ranking;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<RankingEntry> _getMockRanking() {
    return [
      RankingEntry(
        username: 'FubaMaster2024',
        rebirthData: const RebirthData(
          rebirthCount: 5,
          ascensionCount: 2,
          transcendenceCount: 1,
          celestialTokens: 15.5,
        ),
        achievements: [
          'first_click',
          'speed_demon',
          'generator_master',
          'rebirth_king',
          'ascension_lord',
          'transcendence_god',
          'achievement_hunter',
          'fuba_collector',
          'click_master',
          'time_traveler',
          'cosmic_clicker',
          'ultimate_player'
        ],
      ),
      RankingEntry(
        username: 'CornKing',
        rebirthData: const RebirthData(
          rebirthCount: 4,
          ascensionCount: 1,
          transcendenceCount: 0,
          celestialTokens: 8.0,
        ),
        achievements: [
          'first_click',
          'speed_demon',
          'generator_master',
          'rebirth_king',
          'ascension_lord',
          'achievement_hunter',
          'fuba_collector',
          'click_master',
          'time_traveler',
          'cosmic_clicker'
        ],
      ),
      RankingEntry(
        username: 'MaizeLegend',
        rebirthData: const RebirthData(
          rebirthCount: 3,
          ascensionCount: 1,
          transcendenceCount: 0,
          celestialTokens: 5.5,
        ),
        achievements: [
          'first_click',
          'speed_demon',
          'generator_master',
          'rebirth_king',
          'ascension_lord',
          'achievement_hunter',
          'fuba_collector',
          'click_master'
        ],
      ),
      RankingEntry(
        username: 'GoldenGrain',
        rebirthData: const RebirthData(
          rebirthCount: 2,
          ascensionCount: 0,
          transcendenceCount: 0,
          celestialTokens: 3.0,
        ),
        achievements: [
          'first_click',
          'speed_demon',
          'generator_master',
          'rebirth_king',
          'achievement_hunter',
          'fuba_collector'
        ],
      ),
      RankingEntry(
        username: 'FubaFarmer',
        rebirthData: const RebirthData(
          rebirthCount: 2,
          ascensionCount: 0,
          transcendenceCount: 0,
          celestialTokens: 2.5,
        ),
        achievements: [
          'first_click',
          'speed_demon',
          'generator_master',
          'rebirth_king',
          'achievement_hunter'
        ],
      ),
      RankingEntry(
        username: 'CornClicker',
        rebirthData: const RebirthData(
          rebirthCount: 1,
          ascensionCount: 0,
          transcendenceCount: 0,
          celestialTokens: 1.5,
        ),
        achievements: [
          'first_click',
          'speed_demon',
          'generator_master',
          'rebirth_king'
        ],
      ),
      RankingEntry(
        username: 'MaizeMiner',
        rebirthData: const RebirthData(
          rebirthCount: 1,
          ascensionCount: 0,
          transcendenceCount: 0,
          celestialTokens: 1.0,
        ),
        achievements: ['first_click', 'speed_demon', 'generator_master'],
      ),
      RankingEntry(
        username: 'GrainGuru',
        rebirthData: const RebirthData(
          rebirthCount: 0,
          ascensionCount: 0,
          transcendenceCount: 0,
          celestialTokens: 0.5,
        ),
        achievements: ['first_click', 'speed_demon'],
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF222222),
      appBar: AppBar(
        title: const Text('Ranking'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _loadRanking,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Carregando ranking...',
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erro ao carregar ranking',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRanking,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    final ranking = _ranking.isEmpty ? _getMockRanking() : _ranking;
    //  _ranking;

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout(ranking);
        } else {
          return _buildMobileLayout(ranking);
        }
      },
    );
  }

  Widget _buildDesktopLayout(List<RankingEntry> ranking) {
    return Row(
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                for (int i = 0; i < 3 && i < ranking.length; i++)
                  Expanded(
                    child: RankingCardDesktop(
                      entry: ranking[i],
                      rank: i + 1,
                    ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Expanded(
              child: ListView.builder(
                itemCount: ranking.length - 3,
                itemBuilder: (context, index) {
                  final entry = ranking[index + 3];
                  final rank = index + 4;
                  return RankingCardCompact(
                    entry: entry,
                    rank: rank,
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(List<RankingEntry> ranking) {
    return RefreshIndicator(
      onRefresh: _loadRanking,
      child: RankingListMobile(ranking: ranking),
    );
  }
}
