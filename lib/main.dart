import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mtg_life_counter/life_counter/blocs/players_bloc.dart';
import 'package:mtg_life_counter/life_counter/blocs/postgame_bloc.dart';
import 'package:mtg_life_counter/life_counter/life_counter_page.dart';
import 'package:mtg_life_counter/main_menu/main_menu_page.dart';
import 'package:mtg_life_counter/player_setup/blocs/game_setup_bloc.dart';
import 'package:mtg_life_counter/profiles/blocs/profiles_bloc.dart';
import 'package:mtg_life_counter/profiles/components/profile_detail.dart';
import 'package:mtg_life_counter/profiles/profiles_page.dart';
import 'package:path_provider/path_provider.dart';
import 'player_setup/player_setup_page.dart';
import 'package:flutter/rendering.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  debugPaintSizeEnabled = false;

  final storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory(
            (await getApplicationDocumentsDirectory()).path,
          ),
  );

  HydratedBloc.storage = storage;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final AppRouter _appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProfilesBloc()),
        BlocProvider(create: (_) => GameSetupBloc()),
        BlocProvider(
          create: (_) => PlayersBloc(startingLife: 40, playerCount: 4),
        ),
        BlocProvider(create: (_) => PostGameBloc()),
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
        return MaterialPageRoute(builder: (_) => const MainMenuPage());
      case '/profiles':
        return MaterialPageRoute(builder: (_) => const ProfilesPage());
      case '/profile_detail':
        final profileId = settings.arguments as int;
        return MaterialPageRoute(
          builder: (_) => ProfileDetailPage(profileId: profileId),
        );
      case '/player_setup':
        return MaterialPageRoute(builder: (_) => const PlayerSetupPage());
      case '/life_counter':
        return MaterialPageRoute(builder: (_) => LifeCounterPage());
      default:
        return MaterialPageRoute(builder: (_) => const Scaffold());
    }
  }
}
