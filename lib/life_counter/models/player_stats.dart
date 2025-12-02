class PlayerStats {
  final Map<int, int> damageDealtTo;
  final Map<int, int> infectDamageDealtTo;
  final Map<int, int> healingGivenTo;

  PlayerStats({
    Map<int, int>? damageDealtTo,
    Map<int, int>? infectDamageDealtTo,
    Map<int, int>? healingGivenTo,
  }) : damageDealtTo = damageDealtTo ?? {},
       infectDamageDealtTo = infectDamageDealtTo ?? {},
       healingGivenTo = healingGivenTo ?? {};

  PlayerStats copyWith({
    Map<int, int>? damageDealtTo,
    Map<int, int>? damageReceivedFrom,
    Map<int, int>? infectDamageDealtTo,
    Map<int, int>? healingGivenTo,
  }) {
    return PlayerStats(
      damageDealtTo: damageDealtTo ?? this.damageDealtTo,
      infectDamageDealtTo: infectDamageDealtTo ?? this.infectDamageDealtTo,
      healingGivenTo: healingGivenTo ?? this.healingGivenTo,
    );
  }

  int get totalDamageDealt {
    return damageDealtTo.values.fold(0, (total, value) => total + value);
  }

  int get totalHealingGiven {
    return healingGivenTo.values.fold(0, (total, value) => total + value);
  }

  int get totalInfectDamageDealt {
    return infectDamageDealtTo.values.fold(0, (total, value) => total + value);
  }

  PlayerStats recordDamageDealt(int targetId, int amount) {
    final newDamageDealtTo = Map<int, int>.from(damageDealtTo)
      ..update(targetId, (v) => v + amount, ifAbsent: () => amount);

    return copyWith(damageDealtTo: newDamageDealtTo);
  }

  /// Record infect damage dealt to a target
  PlayerStats recordInfectDamageDealt(int targetId, int amount) {
    final newInfectDamageDealtTo = Map<int, int>.from(infectDamageDealtTo)
      ..update(targetId, (v) => v + amount, ifAbsent: () => amount);

    return copyWith(infectDamageDealtTo: newInfectDamageDealtTo);
  }

  /// Record healing given to a target
  PlayerStats recordHealingGiven(int targetId, int amount) {
    final newHealingGivenTo = Map<int, int>.from(healingGivenTo)
      ..update(targetId, (v) => v + amount, ifAbsent: () => amount);

    return copyWith(healingGivenTo: newHealingGivenTo);
  }

  /// Get damage dealt to a specific target
  int getDamageDealtTo(int targetId) => damageDealtTo[targetId] ?? 0;

  /// Get infect damage dealt to a specific target
  int getInfectDamageDealtTo(int targetId) =>
      infectDamageDealtTo[targetId] ?? 0;

  /// Get healing given to a specific target
  int getHealingGivenTo(int targetId) => healingGivenTo[targetId] ?? 0;
}

class PlayersStats {
  final Map<int, PlayerStats> stats;

  PlayersStats({Map<int, PlayerStats>? stats}) : stats = stats ?? {};

  PlayersStats copyWith({Map<int, PlayerStats>? stats}) {
    return PlayersStats(stats: stats ?? this.stats);
  }

  factory PlayersStats.initialize(int playerCount) {
    return PlayersStats(
      stats: Map.fromEntries(
        List.generate(playerCount, (i) => MapEntry(i, PlayerStats())),
      ),
    );
  }

  PlayerStats getPlayerStats(int playerId) {
    return stats[playerId] ?? PlayerStats();
  }

  PlayersStats recordDamage(int sourceId, int targetId, int amount) {
    final newStats = Map<int, PlayerStats>.from(stats);

    final sourceStats = getPlayerStats(sourceId);
    newStats[sourceId] = sourceStats.recordDamageDealt(targetId, amount);

    return copyWith(stats: newStats);
  }

  PlayersStats recordInfectDamage(int sourceId, int targetId, int amount) {
    final newStats = Map<int, PlayerStats>.from(stats);

    final sourceStats = getPlayerStats(sourceId);
    newStats[sourceId] = sourceStats.recordInfectDamageDealt(targetId, amount);

    return copyWith(stats: newStats);
  }

  PlayersStats recordHealing(int sourceId, int targetId, int amount) {
    final newStats = Map<int, PlayerStats>.from(stats);

    final sourceStats = getPlayerStats(sourceId);
    newStats[sourceId] = sourceStats.recordHealingGiven(targetId, amount);

    return copyWith(stats: newStats);
  }

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

  int getTotalDamageDealt(int playerId) {
    return getPlayerStats(playerId).totalDamageDealt;
  }

  /// Get damage dealt from source to target
  int getDamageDealt(int sourceId, int targetId) {
    return getPlayerStats(sourceId).getDamageDealtTo(targetId);
  }

  int getTotalInfectDamageDealt(int playerId) {
    return getPlayerStats(playerId).totalInfectDamageDealt;
  }

  int getInfectDamageDealt(int sourceId, int targetId) {
    return getPlayerStats(sourceId).getInfectDamageDealtTo(targetId);
  }

  int getTotalHealingGiven(int playerId) {
    return getPlayerStats(playerId).totalHealingGiven;
  }

  int getHealingGiven(int sourceId, int targetId) {
    return getPlayerStats(sourceId).getHealingGivenTo(targetId);
  }

  int? getMostDamagingPlayer() {
    if (stats.isEmpty) return null;
    return stats.entries
        .reduce(
          (a, b) => a.value.totalDamageDealt > b.value.totalDamageDealt ? a : b,
        )
        .key;
  }

  List<MapEntry<int, int>> getPlayersByDamageDealt() {
    return stats.entries
        .map((e) => MapEntry(e.key, e.value.totalDamageDealt))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
  }
}
