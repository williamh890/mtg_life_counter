import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/blocs/postgame_bloc.dart';
import 'package:mtg_life_counter/life_counter/models/player.dart';

class SelectWinnerTile extends StatelessWidget {
  final Player player;
  final bool isWinner;

  const SelectWinnerTile({
    super.key,
    required this.player,
    required this.isWinner,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: isWinner
          ? Colors.grey.withValues(alpha: 0.7)
          : Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: ElevatedButton(
          onPressed: () {
            context.read<PostGameBloc>().add(ToggleWinner(player.id));
          },
          child: Text(isWinner ? 'Winner' : 'Loser'),
        ),
      ),
    );
  }
}
