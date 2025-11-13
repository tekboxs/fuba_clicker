import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fuba_clicker/app/core/utils/constants.dart';
import 'package:fuba_clicker/app/core/utils/avatar_helper.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';
import 'package:fuba_clicker/app/modules/ranking/utils/ranking_utils.dart';

class RankingCardCompact extends StatefulWidget {
  final RankingEntry entry;
  final int rank;

  const RankingCardCompact({
    super.key,
    required this.entry,
    required this.rank,
  });

  @override
  State<RankingCardCompact> createState() => _RankingCardCompactState();
}

class _RankingCardCompactState extends State<RankingCardCompact> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF22D3EE).withValues(alpha: 0.5)
                : const Color(0xFF475569).withValues(alpha: 0.5),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              spreadRadius: 0,
            ),
            if (_isHovered)
              BoxShadow(
                color: const Color(0xFF22D3EE).withValues(alpha: 0.2),
                blurRadius: 20,
                spreadRadius: 0,
              ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF0F172A).withValues(alpha: 0.8),
                    const Color(0xFF1E293B).withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: _isHovered
                      ? LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF22D3EE).withValues(alpha: 0.05),
                            Colors.transparent,
                            const Color(0xFFA855F7).withValues(alpha: 0.05),
                          ],
                        )
                      : null,
                ),
                padding: const EdgeInsets.all(16),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final isDesktop = constraints.maxWidth > 640;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1E293B),
                                    Color(0xFF0F172A),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _isHovered
                                      ? const Color(0xFF22D3EE)
                                          .withValues(alpha: 0.5)
                                      : const Color(0xFF475569)
                                          .withValues(alpha: 0.5),
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  '#${widget.rank}',
                                  style: const TextStyle(
                                    color: Color(0xFF22D3EE),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF22D3EE),
                                    Color(0xFFA855F7),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _isHovered
                                        ? const Color(0xFF22D3EE)
                                            .withValues(alpha: 0.5)
                                        : Colors.black.withValues(alpha: 0.3),
                                    blurRadius: _isHovered ? 12 : 8,
                                    spreadRadius: 0,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: widget.entry.profilePicture.isEmpty
                                    ? Container(
                                        decoration: const BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [
                                              Color(0xFF22D3EE),
                                              Color(0xFFA855F7),
                                            ],
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            widget.entry.username.isNotEmpty
                                                ? widget.entry.username
                                                    .substring(0, 1)
                                                    .toUpperCase()
                                                : '--',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w900,
                                              fontSize: 24,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Image.asset(
                                        AvatarHelper.getAvatarPath(
                                            widget.entry.profilePicture),
                                        width: 56,
                                        height: 56,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Container(
                                            decoration: const BoxDecoration(
                                              gradient: LinearGradient(
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                                colors: [
                                                  Color(0xFF22D3EE),
                                                  Color(0xFFA855F7),
                                                ],
                                              ),
                                            ),
                                            child: Center(
                                              child: Text(
                                                widget.entry.username.isNotEmpty
                                                    ? widget.entry.username
                                                        .substring(0, 1)
                                                        .toUpperCase()
                                                    : '--',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 24,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    RankingUtils.formatWalletId(
                                        widget.entry.username),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Text('🌽'),
                                      const SizedBox(width: 4),
                                      Flexible(
                                        child: Text(
                                          GameConstants.formatNumber(
                                              widget.entry.fuba),
                                          style: const TextStyle(
                                            color: Color(0xFFFBBF24),
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'fubá',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            if (isDesktop) ...[
                              const SizedBox(width: 8),
                              _buildStatBadge(
                                label: 'Forus',
                                value: widget.entry.furuborusCount.toString(),
                                color: const Color(0xFFF59E0B),
                              ),
                              const SizedBox(width: 8),
                              _buildStatBadge(
                                label: 'Ascensões',
                                value: widget.entry.ascensionCount.toString(),
                                color: const Color(0xFFA855F7),
                              ),
                              const SizedBox(width: 8),
                              _buildStatBadge(
                                label: 'Rebirts',
                                value: widget.entry.rebirthCount.toString(),
                                color: const Color(0xFF22D3EE),
                              ),
                              const SizedBox(width: 8),
                              _buildStatBadge(
                                label: 'Conquistas',
                                value: widget.entry.achievementCount.toString(),
                                color: const Color(0xFFEC4899),
                              ),
                            ],
                          ],
                        ),
                        if (!isDesktop) ...[
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildStatBadge(
                                label: 'Forus',
                                value: widget.entry.furuborusCount.toString(),
                                color: const Color(0xFFF59E0B),
                                isCompact: true,
                              ),
                              _buildStatBadge(
                                label: 'Ascensões',
                                value: widget.entry.ascensionCount.toString(),
                                color: const Color(0xFFA855F7),
                                isCompact: true,
                              ),
                              _buildStatBadge(
                                label: 'Rebirts',
                                value: widget.entry.rebirthCount.toString(),
                                color: const Color(0xFF22D3EE),
                                isCompact: true,
                              ),
                              _buildStatBadge(
                                label: 'Conquistas',
                                value: widget.entry.achievementCount.toString(),
                                color: const Color(0xFFEC4899),
                                isCompact: true,
                              ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required String label,
    required String value,
    required Color color,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 12,
        vertical: isCompact ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF475569).withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white70,
              fontSize: isCompact ? 9 : 10,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: isCompact ? 14 : 16,
            ),
          ),
        ],
      ),
    );
  }
}
