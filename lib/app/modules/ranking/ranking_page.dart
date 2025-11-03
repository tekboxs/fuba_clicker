import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/services/api_service.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_desktop.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_compact.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_list_mobile.dart';
import 'package:fuba_clicker/app/modules/ranking/utils/ranking_utils.dart';

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

    List<RankingEntry> ranking = _ranking;

    // ranking.sort((a, b) {
    //   final scoreA = RankingUtils.calculateMockFuba(a);
    //   final scoreB = RankingUtils.calculateMockFuba(b);
    //   return scoreB.compareTo(scoreA);
    // });
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
                if (ranking.isNotEmpty && ranking.isNotEmpty)
                  Expanded(
                    child: RankingCardDesktop(
                      entry: ranking[0],
                      rank: 1,
                    ),
                  ),
                if (ranking.length >= 2)
                  Expanded(
                    child: RankingCardDesktop(
                      entry: ranking[1],
                      rank: 2,
                    ),
                  ),
                if (ranking.length >= 3)
                  Expanded(
                    child: RankingCardDesktop(
                      entry: ranking[2],
                      rank: 3,
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
