// lib/ui/life_counter_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/models/player.dart';
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

    final damageDisplay = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
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
              ],
            ),
          ],
        ),
      ],
    );

    final commanderDamageDisplay = Column(
      mainAxisSize: MainAxisSize.min,
      children: player.commanderDamage.entries.map((e) {
        return Padding(
          padding: EdgeInsets.zero,
          child: Chip(
            backgroundColor: state.players[e.key]!.getColor(),
            label: Text(
              '${e.value}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        );
      }).toList(),
    );

    final infectChip = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Padding(
        padding: EdgeInsets.zero,
        child: Chip(
          backgroundColor: Colors.black,
          label: Text(
            'i ${player.infect}',
            style: TextStyle(color: Colors.green),
          ),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );

    final passTurnButton = SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onPanStart: (_) {},
        onPanUpdate: (_) {},
        onPanEnd: (_) {},
        child: Row(
          children: [
            BlocBuilder<PlayersBloc, PlayersState>(
              builder: (context, state) {
                return IconButton(
                  icon: const Icon(Icons.undo),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black, // Icon color
                  ),
                  tooltip: 'Undo',
                  onPressed: state.canUndo
                      ? () => context.read<PlayersBloc>().add(UndoAction())
                      : null,
                );
              },
            ),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  context.read<PlayersBloc>().add(PassTurn());
                },
                child: const Text('Pass Turn'),
              ),
            ),
          ],
        ),
      ),
    );

    final bottomContent = Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (player.commanderDamage.isNotEmpty) commanderDamageDisplay,
              if (player.infect > 0) infectChip,
            ],
          ),
          if (isPlayersTurn) passTurnButton,
        ],
      ),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Stack(
        children: [
          Center(child: damageDisplay),
          bottomContent,
        ],
      ),
    );
  }
}
