// lib/ui/life_counter_page.dart
import 'package:flutter/material.dart';
import '../blocs/players_bloc.dart';

class PlayerTile extends StatefulWidget {
  final Player player;

  const PlayerTile({super.key, required this.player});

  @override
  State<PlayerTile> createState() => _PlayerTileState();
}

class _PlayerTileState extends State<PlayerTile> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            widget.player.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.player.life}',
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
