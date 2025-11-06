import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/blocs/players_bloc.dart';
import 'ui/player_setup_page.dart';

void main() => runApp(
  BlocProvider(create: (_) => PlayersBloc(playerCount: 0), child: const MyApp()),
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PlayerSetupPage(),
    );
  }
}
