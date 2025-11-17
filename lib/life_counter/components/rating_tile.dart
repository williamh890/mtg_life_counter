import 'package:flutter/material.dart';

class RatingTile extends StatelessWidget {
  final int playerId;

  const RatingTile({super.key, required this.playerId});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Center(child: Text('Rate the game')),
    );
  }
}
