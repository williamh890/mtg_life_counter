import 'package:flutter/material.dart';

import 'package:mtg_life_counter/screens/game_page.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const LifeCounterApp());
}

class LifeCounterApp extends StatelessWidget {
  const LifeCounterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Life Counter',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => HomePage(title: ('Player Select')),
        '/game': (context) => GamePage(),
      },
    );
  }
}
