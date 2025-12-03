import 'package:flutter/material.dart';

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Life Counter',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/player_setup');
              },
              icon: const Icon(Icons.play_arrow, size: 28),
              label: const Text('Start Game', style: TextStyle(fontSize: 20)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                minimumSize: const Size(200, 60),
              ),
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/profiles');
              },
              icon: const Icon(Icons.person, size: 28),
              label: const Text('Profiles', style: TextStyle(fontSize: 20)),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
                minimumSize: const Size(200, 60),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
