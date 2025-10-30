import 'package:flutter/material.dart';
import '../widgets/player.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  @override
  Widget build(BuildContext context) {
    final int numPlayers = ModalRoute.of(context)!.settings.arguments as int;
    List<Widget> playerWidgets = List.generate(
      numPlayers,
      (i) => PlayerCounter(),
    );

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: playerWidgets,
      ),
    );
  }
}
