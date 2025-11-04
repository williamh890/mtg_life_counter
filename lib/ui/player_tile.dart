import 'package:flutter/material.dart';
import '../blocs/life_bloc.dart';

class PlayerTile extends StatelessWidget {
  final int playerIndex;
  final int life;
  final TextEditingController adjustController;
  final Color backgroundColor;
  final LifeBloc bloc; // explicitly passed

  const PlayerTile({
    super.key,
    required this.playerIndex,
    required this.life,
    required this.adjustController,
    required this.backgroundColor,
    required this.bloc,
  });

  @override
  Widget build(BuildContext context) {
    final int amt = int.tryParse(adjustController.text) ?? 1;

    return DragTarget<int>(
      builder: (context, candidateData, rejectedData) {
        return Draggable<int>(
          data: playerIndex,
          feedback: Material(
            child: PlayerTile(
              playerIndex: playerIndex,
              life: life,
              adjustController: adjustController,
              backgroundColor: backgroundColor.withAlpha((0.8 * 255).toInt()),
              bloc: bloc, // pass bloc to feedback as well
            ),
          ),
          childWhenDragging: Container(
            color: Colors.grey.shade300,
            child: const Center(
              child: Text('Dragging...', style: TextStyle(fontSize: 20)),
            ),
          ),
          child: Container(
            color: backgroundColor,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Player ${playerIndex + 1}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold)),
                  Text('$life',
                      style: const TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(Icons.remove),
                        onPressed: () => bloc.add(UpdateLife(playerIndex, -amt)),
                      ),
                      IconButton(
                        iconSize: 36,
                        icon: const Icon(Icons.add),
                        onPressed: () => bloc.add(UpdateLife(playerIndex, amt)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
      onWillAcceptWithDetails: (details) {
        return details.data != playerIndex;
      },
      onAcceptWithDetails: (details) {
        final fromIndex = details.data;
        final amt = int.tryParse(adjustController.text) ?? 1;
        bloc.add(UpdateLife(fromIndex, -amt));
        bloc.add(UpdateLife(playerIndex, amt));
      },
    );
  }
}
