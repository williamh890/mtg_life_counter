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

    final damageDisplay = Expanded(
      child: Column(
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
      ),
    );

    final cmdDamage = Align(
      alignment: Alignment.bottomLeft,
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
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
            if (player.infect > 0)
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Chip(
                      backgroundColor: Colors.black,
                      label: Text(
                        'i ${player.infect}',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );

    final passTurnButton = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: GestureDetector(
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
        ),
      ],
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [damageDisplay, cmdDamage, if (isPlayersTurn) passTurnButton],
      ),
    );
  }
}
