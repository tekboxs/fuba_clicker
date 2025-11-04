import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fuba_clicker/app/services/api_service.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_desktop.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_compact.dart';
import 'package:fuba_clicker/app/modules/ranking/inscribed_page.dart';
import 'package:fuba_clicker/app/modules/account/account_settings.dart';
import 'package:fuba_clicker/app/providers/auth_provider.dart';

class RankingPage extends ConsumerStatefulWidget {
  const RankingPage({super.key});

  @override
  ConsumerState<RankingPage> createState() => _RankingPageState();
}

class _RankingPageState extends ConsumerState<RankingPage>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  late TabController _tabController;
  
  List<RankingEntry> _normalRanking = [];
  List<RankingEntry> _inscribedRanking = [];
  bool _isLoadingNormal = true;
  bool _isLoadingInscribed = true;
  String? _errorNormal;
  String? _errorInscribed;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadNormalRanking();
    _loadInscribedRanking();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNormalRanking() async {
    setState(() {
      _isLoadingNormal = true;
      _errorNormal = null;
    });

    try {
      final ranking = await _apiService.getRanking();

      setState(() {
        _normalRanking = ranking;
        _isLoadingNormal = false;
      });
    } catch (e) {
      setState(() {
        _errorNormal = e.toString();
        _isLoadingNormal = false;
      });
    }
  }

  Future<void> _loadInscribedRanking() async {
    setState(() {
      _isLoadingInscribed = true;
      _errorInscribed = null;
    });

    try {
      final ranking = await _apiService.getInscribedRanking();

      setState(() {
        _inscribedRanking = ranking;
        _isLoadingInscribed = false;
      });
    } catch (e) {
      setState(() {
        _errorInscribed = e.toString();
        _isLoadingInscribed = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider);
    final isInscribed = currentUser?.isInscribed ?? false;

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27),
      appBar: AppBar(
        title: const Text('Ranking'),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {
              if (_tabController.index == 0) {
                _loadNormalRanking();
              } else {
                _loadInscribedRanking();
              }
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: _FloatingNav(
        currentIndex: _tabController.index,
        onIndexChange: (index) {
          setState(() {
            _tabController.index = index;
          });
        },
      ),
      body: Stack(
        children: [
          _buildBackgroundEffects(),
          TabBarView(
            controller: _tabController,
            children: [
              _buildNormalRankingTab(),
              _buildInscribedRankingTab(isInscribed),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNormalRankingTab() {
    return Column(
      children: [
        Expanded(child: _buildBody(_normalRanking, _isLoadingNormal, _errorNormal, _loadNormalRanking)),
      ],
    );
  }

  Widget _buildInscribedRankingTab(bool isInscribed) {
    return Column(
      children: [
        if (!isInscribed) _buildInscriptionButton(),
        Expanded(child: _buildBody(_inscribedRanking, _isLoadingInscribed, _errorInscribed, _loadInscribedRanking)),
      ],
    );
  }

  Widget _buildInscriptionButton() {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);

    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF6B35),
            Color(0xFFFF8C42),
            Color(0xFFFFB347),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.deepOrange.withAlpha(150),
            blurRadius: 20,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (!isAuthenticated) {
              _showLoginRequiredDialog();
              return;
            }

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const InscribedPage(),
              ),
            ).then((_) {
              _loadInscribedRanking();
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: const Padding(
            padding: EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Colors.white,
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Ranking Especial',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Inscreva-se e compita para ganhar cupom de 50% da DevScout!',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate(
      onPlay: (controller) => controller.repeat(),
    ).shimmer(
      delay: 2.seconds,
      duration: 3.seconds,
      color: Colors.white.withAlpha(100),
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

  Widget _buildBody(List<RankingEntry> ranking, bool isLoading, String? error, VoidCallback onRefresh) {
    if (isLoading) {
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

    if (error != null) {
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
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white70,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRefresh,
              child: const Text('Tentar novamente'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return _buildDesktopLayout(ranking);
        } else {
          return _buildMobileLayout(ranking, onRefresh);
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

  Widget _buildMobileLayout(List<RankingEntry> ranking, VoidCallback onRefresh) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
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

  void _showLoginRequiredDialog() {
    showDialog(
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
              Icons.login,
              color: Colors.deepOrange,
              size: 28,
            ),
            SizedBox(width: 8),
            Text(
              'Login Necessário',
              style: TextStyle(
                color: Colors.deepOrange,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        content: const Text(
          'Você precisa estar logado para se inscrever no Ranking Especial.',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => Scaffold(
                    appBar: AppBar(
                      title: const Text('Conta'),
                      backgroundColor: Colors.deepOrange,
                      foregroundColor: Colors.white,
                    ),
                    body: const AccountSettings(),
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrange,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Ir para Login',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FloatingNav extends StatefulWidget {
  final int currentIndex;
  final ValueChanged<int> onIndexChange;

  const _FloatingNav({
    required this.currentIndex,
    required this.onIndexChange,
  });

  @override
  State<_FloatingNav> createState() => _FloatingNavState();
}

class _FloatingNavState extends State<_FloatingNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFF18181B).withOpacity(0.9),
              const Color(0xFF27272A).withOpacity(0.9),
            ],
          ),
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: Colors.orange.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x80000000),
              blurRadius: 32,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _NavButton(
                icon: Icons.leaderboard,
                label: 'Normal',
                isSelected: widget.currentIndex == 0,
                selectedGradient: const LinearGradient(
                  colors: [Color(0xFFEA580C), Color(0xFFF97316)],
                ),
                selectedShadowColor: Colors.orange.withOpacity(0.5),
                onTap: () => widget.onIndexChange(0),
              ),
              const SizedBox(width: 12),
              _NavButton(
                icon: Icons.emoji_events,
                label: 'Especial',
                isSelected: widget.currentIndex == 1,
                selectedGradient: const LinearGradient(
                  colors: [Color(0xFFFBBF24), Color(0xFFFCD34D)],
                ),
                selectedShadowColor: Colors.amber.withOpacity(0.5),
                onTap: () => widget.onIndexChange(1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final LinearGradient selectedGradient;
  final Color selectedShadowColor;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.selectedGradient,
    required this.selectedShadowColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? selectedGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: selectedShadowColor,
                    blurRadius: 16,
                    offset: const Offset(0, 0),
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [
            if (isSelected)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: selectedGradient,
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 20,
                  color:
                      isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
