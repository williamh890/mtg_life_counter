import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/player_setup/blocs/game_setup_bloc.dart';
import '../life_counter/blocs/players_bloc.dart';

class PlayerSetupPage extends StatelessWidget {
  const PlayerSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Settings')),
      body: Center(
        child: BlocBuilder<GameSetupBloc, GameSetupState>(
          builder: (context, gameSetupState) {
            return BlocBuilder<PlayersBloc, PlayersState>(
              builder: (context, playersState) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Starting Life Total',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _startingLifeSelector(context),
                    const SizedBox(height: 20),
                    const Text(
                      'Choose Player Count',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _playerCountSelector(context),
                    const SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            context.read<PlayersBloc>().add(
                              StartGame(
                                gameSetupState.playerCount,
                                gameSetupState.startingLife,
                              ),
                            );
                            Navigator.pushNamed(context, '/life_counter');
                          },
                          child: const Text('Start Game'),
                        ),
                        if (playersState.eventHistory.isNotEmpty &&
                            !playersState.isGameFinished) ...[
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/life_counter');
                            },
                            child: const Text('Continue...'),
                          ),
                        ],
                      ],
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _playerCountSelector(BuildContext context) {
    final maxPlayers = 6;
    final bloc = context.read<GameSetupBloc>();

    return SegmentedButton<int>(
      segments: List.generate(maxPlayers, (i) {
        final playerCount = i + 1;
        return ButtonSegment<int>(
          value: playerCount,
          label: Text('$playerCount player${playerCount > 1 ? 's' : ''}'),
        );
      }).toList(),
      style: ButtonStyle(
        padding: WidgetStateProperty.all(EdgeInsets.symmetric(horizontal: 12)),
      ),
      showSelectedIcon: false,
      selected: <int>{bloc.state.playerCount},
      onSelectionChanged: (Set<int> newSelection) {
        final playerCount = newSelection.first;
        bloc.add(SetPlayerCount(playerCount));
      },
    );
  }

  Widget _startingLifeSelector(BuildContext context) {
    final bloc = context.read<GameSetupBloc>();
    final startingLifes = [20, 25, 40];

    return SegmentedButton<int>(
      segments: startingLifes.map((startingLife) {
        return ButtonSegment<int>(
          value: startingLife,
          label: Text('$startingLife'),
        );
      }).toList(),
      selected: <int>{bloc.state.startingLife},
      onSelectionChanged: (Set<int> newSelection) {
        final startingLife = newSelection.first;
        bloc.add(SetStartingLife(startingLife));
      },
    );
  }
}
