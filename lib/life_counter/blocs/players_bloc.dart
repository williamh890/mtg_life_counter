// blocs/life_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/models/player.dart';

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

class InfectDamagePlayer extends PlayerEvent {
  final int targetId;
  final int delta;

  InfectDamagePlayer(this.targetId, this.delta);
}

class LifelinkDamagePlayer extends PlayerEvent {
  final int attackerId;
  final int targetId;
  final int delta;

  LifelinkDamagePlayer(this.attackerId, this.targetId, this.delta);
}

class CommanderDamage extends PlayerEvent {
  final int attackerId;
  final int targetId;
  final int delta;

  CommanderDamage(this.attackerId, this.targetId, this.delta);
}

class PassTurn extends PlayerEvent {
  PassTurn();
}

class PlayersState {
  final int startingLife;
  final Map<int, Player> players;
  final int turnPlayerId;

  PlayersState(this.startingLife, this.players, this.turnPlayerId);

  PlayersState copyWith({
    int? startingLife,
    Map<int, Player>? players,
    int? turnPlayerId,
  }) => PlayersState(
    startingLife ?? this.startingLife,
    players ?? this.players,
    turnPlayerId ?? this.turnPlayerId,
  );
}

class PlayersBloc extends Bloc<PlayerEvent, PlayersState> {
  PlayersBloc({required startingLife, required int playerCount})
    : super(
        PlayersState(
          startingLife,
          _generatePlayers(playerCount, startingLife),
          0,
        ),
      ) {
    on<ResetPlayers>((event, emit) {
      final players = _generatePlayers(event.playerCount, state.startingLife);

      emit(state.copyWith(players: players));
    });

    on<SetStartingLife>((event, emit) {
      final players = state.players.map(
        (id, player) => MapEntry(id, player.copyWith(life: event.startingLife)),
      );

      emit(state.copyWith(players: players, startingLife: event.startingLife));
    });
    on<PassTurn>((event, emit) {
      int nextPlayer = state.turnPlayerId + 1;
      if (nextPlayer > state.players.length - 1) {
        nextPlayer = 0;
      }

      emit(state.copyWith(turnPlayerId: nextPlayer));
    });

    on<DamagePlayer>((event, emit) {
      final players = Map<int, Player>.from(state.players)
        ..update(
          event.targetId,
          (player) => player.copyWith(life: player.life - event.delta),
        );

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

    on<InfectDamagePlayer>((event, emit) {
      final players = Map<int, Player>.from(state.players)
        ..update(
          event.targetId,
          (player) => player.copyWith(infect: player.infect + event.delta),
        );

      emit(state.copyWith(players: players));
    });

    on<LifelinkDamagePlayer>((event, emit) {
      final players = Map<int, Player>.from(state.players)
        ..update(
          event.targetId,
          (player) => player.copyWith(life: player.life - event.delta),
        )
        ..update(
          event.attackerId,
          (player) => player.copyWith(life: player.life + event.delta),
        );

      emit(state.copyWith(players: players));
    });

    on<CommanderDamage>((event, emit) {
      final players = Map<int, Player>.from(state.players)
        ..update(event.targetId, (player) {
          final commanderDamage = Map<int, int>.from(player.commanderDamage)
            ..update(
              event.attackerId,
              (value) => value + event.delta,
              ifAbsent: () => event.delta,
            );

          return player.copyWith(commanderDamage: commanderDamage);
        });

      emit(state.copyWith(players: players));
    });
  }

  static Map<int, Player> _generatePlayers(int playerCount, int startingLife) =>
      List.generate(
        playerCount,
        (i) => Player(
          id: i,
          name: 'Player ${i + 1}',
          life: startingLife,
          infect: 0,
          commanderDamage: {},
        ),
      ).fold<Map<int, Player>>({}, (map, player) => map..[player.id] = player);
}
