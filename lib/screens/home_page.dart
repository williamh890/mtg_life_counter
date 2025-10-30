import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<int> numPlayers = [1, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player Select'),
        backgroundColor: Colors.amberAccent,
      ),
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: numPlayers.map((n) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/game', arguments: n);
                },
                child: Text(n.toString()),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
