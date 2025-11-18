import 'package:flutter/material.dart';
import 'package:mtg_life_counter/life_counter/models/player.dart';

class GameOverviewTile extends StatelessWidget {
  final Player player;

  const GameOverviewTile({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text('Game Overview for ${player.name}')],
      ),
    );
  }
}
