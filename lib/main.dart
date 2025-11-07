import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/blocs/players_bloc.dart';
import 'package:mtg_life_counter/ui/life_counter_page.dart';
import 'ui/player_setup_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PlayersBloc(playerCount: 0),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: _appRouter.onGenerateRoute,
      ),
    );
  }
}

class AppRouter {
  Route onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const PlayerSetupPage());
      case '/life_counter':
        return MaterialPageRoute(builder: (_) => LifeCounterPage());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold());
    }
  }
}
