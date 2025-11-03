import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/services/api_service.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_desktop.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_compact.dart';

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
      backgroundColor: const Color(0xFF0A0E27),
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
      body: Stack(
        children: [
          _buildBackgroundEffects(),
          _buildBody(),
        ],
      ),
    );
  }

  Widget _buildBackgroundEffects() {
    return Stack(
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
        Positioned(
          left: MediaQuery.of(context).size.width * 0.25,
          top: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFBBF24).withValues(alpha: 0.2),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 128, sigmaY: 128),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        Positioned(
          right: MediaQuery.of(context).size.width * 0.25,
          bottom: 0,
          child: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF22D3EE).withValues(alpha: 0.2),
            ),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 128, sigmaY: 128),
              child: Container(color: Colors.transparent),
            ),
          ),
        ),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0.5, 0.5),
                radius: 0.5,
                colors: [
                  const Color(0xFFFFD700).withValues(alpha: 0.1),
                  Colors.transparent,
                ],
                stops: const [0.0, 0.5],
              ),
            ),
          ),
        ),
      ],
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
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                if (constraints.maxWidth < 900) {
                  return Column(
                    children: [
                      if (ranking.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RankingCardDesktop(
                            entry: ranking[0],
                            rank: 1,
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 100.ms)
                              .slideY(
                                begin: -0.3,
                                end: 0,
                                duration: 500.ms,
                                delay: 100.ms,
                              ),
                        ),
                      if (ranking.length >= 2)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RankingCardDesktop(
                            entry: ranking[1],
                            rank: 2,
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .slideX(
                                begin: -0.3,
                                end: 0,
                                duration: 500.ms,
                                delay: 200.ms,
                              ),
                        ),
                      if (ranking.length >= 3)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: RankingCardDesktop(
                            entry: ranking[2],
                            rank: 3,
                          )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 300.ms)
                              .slideX(
                                begin: 0.3,
                                end: 0,
                                duration: 500.ms,
                                delay: 300.ms,
                              ),
                        ),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      flex: 1,
                      child: ranking.length >= 2
                          ? RankingCardDesktop(
                              entry: ranking[1],
                              rank: 2,
                            )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 200.ms)
                              .slideX(
                                begin: -0.3,
                                end: 0,
                                duration: 500.ms,
                                delay: 200.ms,
                              )
                          : const SizedBox(),
                    ),
                    Expanded(
                      flex: 1,
                      child: ranking.isNotEmpty
                          ? Padding(
                              padding: const EdgeInsets.only(bottom: 32),
                              child: RankingCardDesktop(
                                entry: ranking[0],
                                rank: 1,
                              ),
                            )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 100.ms)
                              .slideY(
                                begin: -0.3,
                                end: 0,
                                duration: 500.ms,
                                delay: 100.ms,
                              )
                          : const SizedBox(),
                    ),
                    Expanded(
                      flex: 1,
                      child: ranking.length >= 3
                          ? RankingCardDesktop(
                              entry: ranking[2],
                              rank: 3,
                            )
                              .animate()
                              .fadeIn(duration: 500.ms, delay: 300.ms)
                              .slideX(
                                begin: 0.3,
                                end: 0,
                                duration: 500.ms,
                                delay: 300.ms,
                              )
                          : const SizedBox(),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                for (int index = 0; index < ranking.length - 3; index++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: RankingCardCompact(
                      entry: ranking[index + 3],
                      rank: index + 4,
                    )
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: (600 + index * 50).ms,
                        )
                        .slideX(
                          begin: -0.2,
                          end: 0,
                          duration: 400.ms,
                          delay: (600 + index * 50).ms,
                        ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(List<RankingEntry> ranking) {
    return RefreshIndicator(
      onRefresh: _loadRanking,
      child: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: SizedBox(
              height: 40,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final entry = ranking[index];
                  final rank = index + 1;

                  if (rank <= 3) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: RankingCardDesktop(
                        entry: entry,
                        rank: rank,
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: RankingCardCompact(
                        entry: entry,
                        rank: rank,
                      ),
                    );
                  }
                },
                childCount: ranking.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
