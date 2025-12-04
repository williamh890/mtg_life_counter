import 'package:flutter/material.dart';

enum GameRating {
  veryUnhappy('Very Unhappy', Icons.sentiment_very_dissatisfied, Colors.red),
  unhappy('Unhappy', Icons.sentiment_dissatisfied, Colors.orange),
  neutral('Neutral', Icons.sentiment_neutral, Colors.amber),
  happy('Happy', Icons.sentiment_satisfied, Colors.lightGreen),
  veryHappy('Very Happy', Icons.sentiment_very_satisfied, Colors.green);

  final String label;
  final IconData icon;
  final Color color;

  const GameRating(this.label, this.icon, this.color);
}

class PlayerRating {
  final int playerId;
  final GameRating? gameRating;
  final int? saltiness;
  final int? commendedPlayerId;
  final int? cringePlayerId;

  PlayerRating(
    this.playerId,
    this.gameRating,
    this.saltiness,
    this.commendedPlayerId,
    this.cringePlayerId,
  );

  PlayerRating copyWith({
    int? playerId,
    GameRating? gameRating,
    int? saltiness,
    int? commendedPlayerId,
    int? cringePlayerId,
  }) {
    return PlayerRating(
      playerId ?? this.playerId,
      gameRating ?? this.gameRating,
      saltiness ?? this.saltiness,
      commendedPlayerId ?? this.commendedPlayerId,
      cringePlayerId ?? this.cringePlayerId,
    );
  }
}
