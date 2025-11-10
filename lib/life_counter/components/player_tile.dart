// lib/ui/life_counter_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/players_bloc.dart';

class PlayerTile extends StatelessWidget {
  final Player player;
  final bool isPlayersTurn;

  const PlayerTile({
    super.key,
    required this.player,
    required this.isPlayersTurn,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.read<PlayersBloc>().state;

    return Center(
      child: Stack(
        children: [
          // Main column centered
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min, // shrink to content
              children: [
                Text(
                  player.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${player.life}',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (isPlayersTurn) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onPanStart: (_) {},
                    onPanUpdate: (_) {},
                    onPanEnd: (_) {},
                    child: ElevatedButton(
                      onPressed: () {
                        context.read<PlayersBloc>().add(PassTurn());
                      },
                      child: const Text('Pass Turn'),
                    ),
                  ),
                ],
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: player.commanderDamage.entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Chip(
                      backgroundColor: state.players[e.key]!.getColor(),
                      label: Text('${e.value}'),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
