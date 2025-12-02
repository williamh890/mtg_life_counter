class PlayerStats {
  // Total damage dealt to others
  final int totalDamageDealt;

  // Total damage received from others
  final int totalDamageReceived;

  // Map of targetId -> damage dealt to that target
  final Map<int, int> damageDealtTo;

  // Map of sourceId -> damage received from that source
  final Map<int, int> damageReceivedFrom;

  // Total infect damage dealt
  final int totalInfectDamageDealt;

  // Map of targetId -> infect damage dealt
  final Map<int, int> infectDamageDealtTo;

  // Total healing given to others
  final int totalHealingGiven;

  // Map of targetId -> healing given
  final Map<int, int> healingGivenTo;

  PlayerStats({
    this.totalDamageDealt = 0,
    this.totalDamageReceived = 0,
    Map<int, int>? damageDealtTo,
    Map<int, int>? damageReceivedFrom,
    this.totalInfectDamageDealt = 0,
    Map<int, int>? infectDamageDealtTo,
    this.totalHealingGiven = 0,
    Map<int, int>? healingGivenTo,
  }) : damageDealtTo = damageDealtTo ?? {},
       damageReceivedFrom = damageReceivedFrom ?? {},
       infectDamageDealtTo = infectDamageDealtTo ?? {},
       healingGivenTo = healingGivenTo ?? {};

  PlayerStats copyWith({
    int? totalDamageDealt,
    int? totalDamageReceived,
    Map<int, int>? damageDealtTo,
    Map<int, int>? damageReceivedFrom,
    int? totalInfectDamageDealt,
    Map<int, int>? infectDamageDealtTo,
    int? totalHealingGiven,
    Map<int, int>? healingGivenTo,
  }) {
    return PlayerStats(
      totalDamageDealt: totalDamageDealt ?? this.totalDamageDealt,
      totalDamageReceived: totalDamageReceived ?? this.totalDamageReceived,
      damageDealtTo: damageDealtTo ?? this.damageDealtTo,
      damageReceivedFrom: damageReceivedFrom ?? this.damageReceivedFrom,
      totalInfectDamageDealt:
          totalInfectDamageDealt ?? this.totalInfectDamageDealt,
      infectDamageDealtTo: infectDamageDealtTo ?? this.infectDamageDealtTo,
      totalHealingGiven: totalHealingGiven ?? this.totalHealingGiven,
      healingGivenTo: healingGivenTo ?? this.healingGivenTo,
    );
  }

  /// Record damage dealt to a target
  PlayerStats recordDamageDealt(int targetId, int amount) {
    final newDamageDealtTo = Map<int, int>.from(damageDealtTo)
      ..update(targetId, (v) => v + amount, ifAbsent: () => amount);

    return copyWith(
      totalDamageDealt: totalDamageDealt + amount,
      damageDealtTo: newDamageDealtTo,
    );
  }

  /// Record damage received from a source
  PlayerStats recordDamageReceived(int sourceId, int amount) {
    final newDamageReceivedFrom = Map<int, int>.from(damageReceivedFrom)
      ..update(sourceId, (v) => v + amount, ifAbsent: () => amount);

    return copyWith(
      totalDamageReceived: totalDamageReceived + amount,
      damageReceivedFrom: newDamageReceivedFrom,
    );
  }

  /// Record infect damage dealt to a target
  PlayerStats recordInfectDamageDealt(int targetId, int amount) {
    final newInfectDamageDealtTo = Map<int, int>.from(infectDamageDealtTo)
      ..update(targetId, (v) => v + amount, ifAbsent: () => amount);

    return copyWith(
      totalInfectDamageDealt: totalInfectDamageDealt + amount,
      infectDamageDealtTo: newInfectDamageDealtTo,
    );
  }

  /// Record healing given to a target
  PlayerStats recordHealingGiven(int targetId, int amount) {
    final newHealingGivenTo = Map<int, int>.from(healingGivenTo)
      ..update(targetId, (v) => v + amount, ifAbsent: () => amount);

    return copyWith(
      totalHealingGiven: totalHealingGiven + amount,
      healingGivenTo: newHealingGivenTo,
    );
  }

  /// Get damage dealt to a specific target
  int getDamageDealtTo(int targetId) => damageDealtTo[targetId] ?? 0;

  /// Get damage received from a specific source
  int getDamageReceivedFrom(int sourceId) => damageReceivedFrom[sourceId] ?? 0;

  /// Get infect damage dealt to a specific target
  int getInfectDamageDealtTo(int targetId) =>
      infectDamageDealtTo[targetId] ?? 0;

  /// Get healing given to a specific target
  int getHealingGivenTo(int targetId) => healingGivenTo[targetId] ?? 0;

  /// Get the player who dealt the most damage to this player
  int? getTopAttacker() {
    if (damageReceivedFrom.isEmpty) return null;
    return damageReceivedFrom.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }

  /// Get the player who received the most damage from this player
  int? getTopVictim() {
    if (damageDealtTo.isEmpty) return null;
    return damageDealtTo.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;
  }
}

class PlayersStats {
  final Map<int, PlayerStats> stats;

  PlayersStats({Map<int, PlayerStats>? stats}) : stats = stats ?? {};

  PlayersStats copyWith({Map<int, PlayerStats>? stats}) {
    return PlayersStats(stats: stats ?? this.stats);
  }

  /// Initialize stats for a given number of players
  factory PlayersStats.initialize(int playerCount) {
    return PlayersStats(
      stats: Map.fromEntries(
        List.generate(playerCount, (i) => MapEntry(i, PlayerStats())),
      ),
    );
  }

  /// Get stats for a specific player
  PlayerStats getPlayerStats(int playerId) {
    return stats[playerId] ?? PlayerStats();
  }

  /// Record damage from source to target
  PlayersStats recordDamage(int sourceId, int targetId, int amount) {
    final newStats = Map<int, PlayerStats>.from(stats);

    // Update source's damage dealt
    final sourceStats = getPlayerStats(sourceId);
    newStats[sourceId] = sourceStats.recordDamageDealt(targetId, amount);

    // Update target's damage received
    final targetStats = getPlayerStats(targetId);
    newStats[targetId] = targetStats.recordDamageReceived(sourceId, amount);

    return copyWith(stats: newStats);
  }

  /// Record infect damage from source to target
  PlayersStats recordInfectDamage(int sourceId, int targetId, int amount) {
    final newStats = Map<int, PlayerStats>.from(stats);

    final sourceStats = getPlayerStats(sourceId);
    newStats[sourceId] = sourceStats.recordInfectDamageDealt(targetId, amount);

    return copyWith(stats: newStats);
  }

  /// Record healing from source to target
  PlayersStats recordHealing(int sourceId, int targetId, int amount) {
    final newStats = Map<int, PlayerStats>.from(stats);

    final sourceStats = getPlayerStats(sourceId);
    newStats[sourceId] = sourceStats.recordHealingGiven(targetId, amount);

    return copyWith(stats: newStats);
  }

  /// Record damage from source to multiple targets
  PlayersStats recordDamageToMultiple(
    int sourceId,
    List<int> targetIds,
    int amount,
  ) {
    var updatedStats = this;
    for (final targetId in targetIds) {
      updatedStats = updatedStats.recordDamage(sourceId, targetId, amount);
    }
    return updatedStats;
  }

  /// Record infect damage from source to multiple targets
  PlayersStats recordInfectDamageToMultiple(
    int sourceId,
    List<int> targetIds,
    int amount,
  ) {
    var updatedStats = this;
    for (final targetId in targetIds) {
      updatedStats = updatedStats.recordInfectDamage(
        sourceId,
        targetId,
        amount,
      );
    }
    return updatedStats;
  }

  /// Record healing from source to multiple targets
  PlayersStats recordHealingToMultiple(
    int sourceId,
    List<int> targetIds,
    int amount,
  ) {
    var updatedStats = this;
    for (final targetId in targetIds) {
      updatedStats = updatedStats.recordHealing(sourceId, targetId, amount);
    }
    return updatedStats;
  }

  /// Get total damage dealt by a player
  int getTotalDamageDealt(int playerId) {
    return getPlayerStats(playerId).totalDamageDealt;
  }

  /// Get total damage received by a player
  int getTotalDamageReceived(int playerId) {
    return getPlayerStats(playerId).totalDamageReceived;
  }

  /// Get damage dealt from source to target
  int getDamageDealt(int sourceId, int targetId) {
    return getPlayerStats(sourceId).getDamageDealtTo(targetId);
  }

  /// Get damage received by target from source
  int getDamageReceived(int targetId, int sourceId) {
    return getPlayerStats(targetId).getDamageReceivedFrom(sourceId);
  }

  /// Get total infect damage dealt by a player
  int getTotalInfectDamageDealt(int playerId) {
    return getPlayerStats(playerId).totalInfectDamageDealt;
  }

  /// Get infect damage dealt from source to target
  int getInfectDamageDealt(int sourceId, int targetId) {
    return getPlayerStats(sourceId).getInfectDamageDealtTo(targetId);
  }

  /// Get total healing given by a player
  int getTotalHealingGiven(int playerId) {
    return getPlayerStats(playerId).totalHealingGiven;
  }

  /// Get healing given from source to target
  int getHealingGiven(int sourceId, int targetId) {
    return getPlayerStats(sourceId).getHealingGivenTo(targetId);
  }

  /// Get the player who dealt the most damage to a specific player
  int? getTopAttacker(int playerId) {
    return getPlayerStats(playerId).getTopAttacker();
  }

  /// Get the player who received the most damage from a specific player
  int? getTopVictim(int playerId) {
    return getPlayerStats(playerId).getTopVictim();
  }

  /// Get the player who dealt the most total damage in the game
  int? getMostDamagingPlayer() {
    if (stats.isEmpty) return null;
    return stats.entries
        .reduce(
          (a, b) => a.value.totalDamageDealt > b.value.totalDamageDealt ? a : b,
        )
        .key;
  }

  /// Get all players sorted by total damage dealt (descending)
  List<MapEntry<int, int>> getPlayersByDamageDealt() {
    return stats.entries
        .map((e) => MapEntry(e.key, e.value.totalDamageDealt))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }

  /// Get all players sorted by total damage received (descending)
  List<MapEntry<int, int>> getPlayersByDamageReceived() {
    return stats.entries
        .map((e) => MapEntry(e.key, e.value.totalDamageReceived))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }
}
