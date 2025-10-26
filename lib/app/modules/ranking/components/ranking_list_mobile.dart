import 'package:flutter/material.dart';
import 'package:fuba_clicker/app/models/ranking_entry.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_desktop.dart';
import 'package:fuba_clicker/app/modules/ranking/components/ranking_card_compact.dart';

class RankingListMobile extends StatelessWidget {
  final List<RankingEntry> ranking;

  const RankingListMobile({
    super.key,
    required this.ranking,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: ranking.length,
      itemBuilder: (context, index) {
        final entry = ranking[index];
        final rank = index + 1;

        if (rank <= 3) {
          return RankingCardDesktop(
            entry: entry,
            rank: rank,
          );
        } else {
          return RankingCardCompact(
            entry: entry,
            rank: rank,
          );
        }
      },
    );
  }
}
