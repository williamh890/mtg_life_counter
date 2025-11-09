// blocs/life_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';

enum DamageMode {
  damage("Damage"),
  healing("Healing"),
  lifelink("Lifelink");

  final String label;

  const DamageMode(this.label);
}

class Player {
  final int id;
  String name;
  int life;
  bool isDead;

  Player({
    required this.id,
    required this.name,
    required this.life,
    this.isDead = false,
  });

  Player copyWith({int? id, String? name, int? life, bool? isDead}) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      life: life ?? this.life,
      isDead: isDead ?? this.isDead,
    );
  }
}

abstract class PlayerEvent {}

class SetStartingLife extends PlayerEvent {
  final int startingLife;

  SetStartingLife(this.startingLife);
}

class ResetPlayers extends PlayerEvent {
  final int playerCount;

  ResetPlayers(this.playerCount);
}

class DamagePlayer extends PlayerEvent {
  final int targetId;
  final int delta;

  DamagePlayer(this.targetId, this.delta);
}

class HealPlayer extends PlayerEvent {
  final int targetId;
  final int delta;

  HealPlayer(this.targetId, this.delta);
}

class LifelinkDamagePlayer extends PlayerEvent {
  final int attackerId;
  final int targetId;
  final int delta;

  LifelinkDamagePlayer(this.attackerId, this.targetId, this.delta);
}

class PlayersState {
  final int startingLife;
  final Map<int, Player> players;

  PlayersState(this.startingLife, this.players);

  PlayersState copyWith({int? startingLife, Map<int, Player>? players}) =>
      PlayersState(startingLife ?? this.startingLife, players ?? this.players);
}

class PlayersBloc extends Bloc<PlayerEvent, PlayersState> {
  PlayersBloc({required startingLife, required int playerCount})
    : super(
        PlayersState(startingLife, _generatePlayers(playerCount, startingLife)),
      ) {
    on<ResetPlayers>((event, emit) {
      final players = _generatePlayers(event.playerCount, state.startingLife);

      emit(state.copyWith(players: players));
    });

    on<SetStartingLife>((event, emit) {
      emit(state.copyWith(startingLife: event.startingLife));
    });

    on<DamagePlayer>((event, emit) {
      final players = Map<int, Player>.from(state.players)
        ..update(event.targetId, (player) {
          final life = player.life - event.delta;
          final isDead = life <= 0;
          return player.copyWith(life: life, isDead: isDead);
        });

      emit(state.copyWith(players: players));
    });

    on<HealPlayer>((event, emit) {
      final players = Map<int, Player>.from(state.players)
        ..update(
          event.targetId,
          (player) => player.copyWith(life: player.life + event.delta),
        );

      emit(state.copyWith(players: players));
    });

    on<LifelinkDamagePlayer>((event, emit) {
      final players = Map<int, Player>.from(state.players)
        ..update(event.targetId, (player) {
          final life = player.life - event.delta;
          final isDead = life <= 0;
          return player.copyWith(life: life, isDead: isDead);
        })
        ..update(
          event.attackerId,
          (player) => player.copyWith(life: player.life + event.delta),
        );

      emit(state.copyWith(players: players));
    });
  }

  static Map<int, Player> _generatePlayers(int playerCount, int startingLife) =>
      List.generate(
        playerCount,
        (i) => Player(id: i, name: 'Player ${i + 1}', life: startingLife),
      ).fold<Map<int, Player>>({}, (map, player) => map..[player.id] = player);
}
