class PlayerRating {
  final int playerId;
  final int? rating;
  final int? saltiness;
  final int? commendedPlayerId;

  PlayerRating(
    this.playerId,
    this.rating,
    this.saltiness,
    this.commendedPlayerId,
  );

  PlayerRating copyWith({
    int? playerId,
    int? rating,
    int? saltiness,
    int? commendedPlayerId,
  }) {
    return PlayerRating(
      playerId ?? this.playerId,
      rating ?? this.rating,
      saltiness ?? this.saltiness,
      commendedPlayerId ?? this.commendedPlayerId,
    );
  }
}
