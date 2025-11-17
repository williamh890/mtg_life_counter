import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/blocs/players_bloc.dart';
import 'package:mtg_life_counter/life_counter/life_counter_page.dart';
import 'package:mtg_life_counter/player_setup/blocs/game_setup_bloc.dart';
import 'player_setup/player_setup_page.dart';
import 'package:flutter/rendering.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  debugPaintSizeEnabled = false;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GameSetupBloc()),
        BlocProvider(
          create: (_) => PlayersBloc(startingLife: 40, playerCount: 4),
        ),
      ],
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
