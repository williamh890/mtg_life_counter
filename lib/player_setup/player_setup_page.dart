import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../life_counter/blocs/players_bloc.dart';

class PlayerSetupPage extends StatelessWidget {
  const PlayerSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Settings')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Starting Life Total',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            BlocBuilder<PlayersBloc, PlayersState>(
              builder: (context, state) => _startingLifeSelector(context),
            ),
            const SizedBox(height: 20),
            const Text(
              'Choose Player Count',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 10,
              children: List.generate(8, (i) {
                final count = i + 1;
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 24,
                    ),
                    textStyle: const TextStyle(fontSize: 18),
                  ),
                  onPressed: () {
                    final bloc = context.read<PlayersBloc>();
                    bloc.add(ResetPlayers(count));
                    Navigator.pushNamed(context, '/life_counter');
                  },
                  child: Text('$count Player${count == 1 ? '' : 's'}'),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _startingLifeSelector(BuildContext context) {
    final bloc = context.read<PlayersBloc>();
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
