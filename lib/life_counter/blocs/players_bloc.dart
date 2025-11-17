// blocs/life_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/models/player.dart';

abstract class PlayerEvent {}

// Events that should be tracked in history
abstract class PlayerHistoryEvent extends PlayerEvent {}

class SetStartingLife extends PlayerEvent {
  final int startingLife;

  SetStartingLife(this.startingLife);
}

class ResetPlayers extends PlayerEvent {
  final int playerCount;

  ResetPlayers(this.playerCount);
}

class DamagePlayer extends PlayerHistoryEvent {
  final int targetId;
  final int delta;

  DamagePlayer(this.targetId, this.delta);
}

class HealPlayer extends PlayerHistoryEvent {
  final int targetId;
  final int delta;

  HealPlayer(this.targetId, this.delta);
}

class HealPlayers extends PlayerHistoryEvent {
  final int delta;

  HealPlayers(this.delta);
}

class HealOpponents extends PlayerHistoryEvent {
  final int sourceId;
  final int delta;

  HealOpponents(this.sourceId, this.delta);
}

class InfectDamagePlayer extends PlayerHistoryEvent {
  final int targetId;
  final int delta;

  InfectDamagePlayer(this.targetId, this.delta);
}

class InfectDamagePlayers extends PlayerHistoryEvent {
  final int delta;

  InfectDamagePlayers(this.delta);
}

class InfectDamageOpponents extends PlayerHistoryEvent {
  final int attackerId;
  final int delta;

  InfectDamageOpponents(this.attackerId, this.delta);
}

class LifelinkDamagePlayer extends PlayerHistoryEvent {
  final int attackerId;
  final int targetId;
  final int delta;

  LifelinkDamagePlayer(this.attackerId, this.targetId, this.delta);
}

class Extort extends PlayerHistoryEvent {
  final int attackerId;
  final int delta;

  Extort(this.attackerId, this.delta);
}

class CommanderDamage extends PlayerHistoryEvent {
  final int attackerId;
  final int targetId;
  final int delta;

  CommanderDamage(this.attackerId, this.targetId, this.delta);
}

class DamagePlayers extends PlayerHistoryEvent {
  final int delta;

  DamagePlayers(this.delta);
}

class DamageOpponents extends PlayerHistoryEvent {
  final int delta;
  final int attackerId;

  DamageOpponents(this.attackerId, this.delta);
}

class PassTurn extends PlayerHistoryEvent {
  PassTurn();
}

class UndoAction extends PlayerEvent {}

class PlayersState {
  final int startingLife;
  final Map<int, Player> players;
  final int turnPlayerId;
  final List<PlayerEvent> eventHistory;

  PlayersState(
    this.startingLife,
    this.players,
    this.turnPlayerId, [
    this.eventHistory = const [],
  ]);

  PlayersState copyWith({
    int? startingLife,
    Map<int, Player>? players,
    int? turnPlayerId,
    List<PlayerEvent>? eventHistory,
  }) => PlayersState(
    startingLife ?? this.startingLife,
    players ?? this.players,
    turnPlayerId ?? this.turnPlayerId,
    eventHistory ?? this.eventHistory,
  );

  bool get canUndo => eventHistory.isNotEmpty;
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
      emit(PlayersState(state.startingLife, players, 0, []));
    });

    on<SetStartingLife>((event, emit) {
      final players = state.players.map(
        (id, player) => MapEntry(id, player.copyWith(life: event.startingLife)),
      );
      emit(PlayersState(event.startingLife, players, state.turnPlayerId, []));
    });

    on<UndoAction>((event, emit) {
      if (state.eventHistory.isEmpty) return;

      final newHistory = List<PlayerEvent>.from(state.eventHistory)
        ..removeLast();

      PlayersState rebuiltState = PlayersState(
        state.startingLife,
        _generatePlayers(state.players.length, state.startingLife),
        0,
        [],
      );

      for (final evt in newHistory) {
        rebuiltState = _applyEvent(rebuiltState, evt);
      }

      emit(rebuiltState.copyWith(eventHistory: newHistory));
    });

    on<PassTurn>((event, emit) {
      _emitWithHistory(emit, _passTurn(state, event), event);
    });

    on<DamagePlayer>((event, emit) {
      _emitWithHistory(emit, _damagePlayer(state, event), event);
    });

    on<DamagePlayers>((event, emit) {
      _emitWithHistory(emit, _damagePlayers(state, event), event);
    });

    on<DamageOpponents>((event, emit) {
      _emitWithHistory(emit, _damageOpponents(state, event), event);
    });

    on<HealPlayer>((event, emit) {
      _emitWithHistory(emit, _healPlayer(state, event), event);
    });

    on<HealPlayers>((event, emit) {
      _emitWithHistory(emit, _healPlayers(state, event), event);
    });

    on<HealOpponents>((event, emit) {
      _emitWithHistory(emit, _healOpponents(state, event), event);
    });

    on<InfectDamagePlayer>((event, emit) {
      _emitWithHistory(emit, _infectDamagePlayer(state, event), event);
    });

    on<InfectDamagePlayers>((event, emit) {
      _emitWithHistory(emit, _infectDamagePlayers(state, event), event);
    });

    on<InfectDamageOpponents>((event, emit) {
      _emitWithHistory(emit, _infectDamageOpponents(state, event), event);
    });

    on<LifelinkDamagePlayer>((event, emit) {
      _emitWithHistory(emit, _lifelinkDamagePlayer(state, event), event);
    });

    on<Extort>((event, emit) {
      _emitWithHistory(emit, _extort(state, event), event);
    });

    on<CommanderDamage>((event, emit) {
      _emitWithHistory(emit, _commanderDamage(state, event), event);
    });
  }

  void _emitWithHistory(
    Emitter<PlayersState> emit,
    PlayersState newState,
    PlayerHistoryEvent event,
  ) {
    final history = List<PlayerEvent>.from(state.eventHistory)..add(event);
    var stateToEmit = newState.copyWith(eventHistory: history);

    // If current player died, automatically pass their turn
    final currentPlayer = stateToEmit.players[stateToEmit.turnPlayerId];
    if (currentPlayer != null && currentPlayer.isDead()) {
      stateToEmit = _passTurn(stateToEmit, PassTurn());
    }

    emit(stateToEmit);
  }

  PlayersState _applyEvent(PlayersState currentState, PlayerEvent event) {
    return switch (event) {
      PassTurn() => _passTurn(currentState, event),
      DamagePlayer() => _damagePlayer(currentState, event),
      DamagePlayers() => _damagePlayers(currentState, event),
      DamageOpponents() => _damageOpponents(currentState, event),
      HealPlayer() => _healPlayer(currentState, event),
      HealPlayers() => _healPlayers(currentState, event),
      HealOpponents() => _healOpponents(currentState, event),
      InfectDamagePlayer() => _infectDamagePlayer(currentState, event),
      InfectDamagePlayers() => _infectDamagePlayers(currentState, event),
      InfectDamageOpponents() => _infectDamageOpponents(currentState, event),
      LifelinkDamagePlayer() => _lifelinkDamagePlayer(currentState, event),
      Extort() => _extort(currentState, event),
      CommanderDamage() => _commanderDamage(currentState, event),
      _ => currentState,
    };
  }

  PlayersState _passTurn(PlayersState state, PassTurn event) {
    int nextPlayerId = (state.turnPlayerId + 1) % state.players.length;

    while (state.players[nextPlayerId]!.isDead() &&
        nextPlayerId != state.turnPlayerId) {
      nextPlayerId = (nextPlayerId + 1) % state.players.length;
    }

    return state.copyWith(turnPlayerId: nextPlayerId);
  }

  PlayersState _damagePlayer(PlayersState state, DamagePlayer event) {
    final players = Map<int, Player>.from(state.players)
      ..update(
        event.targetId,
        (player) => player.copyWith(life: player.life - event.delta),
      );
    return state.copyWith(players: players);
  }

  PlayersState _damagePlayers(PlayersState state, DamagePlayers event) {
    final players = state.players.map(
      (id, player) =>
          MapEntry(id, player.copyWith(life: player.life - event.delta)),
    );
    return state.copyWith(players: players);
  }

  PlayersState _damageOpponents(PlayersState state, DamageOpponents event) {
    final players = state.players.map(
      (id, player) => MapEntry(
        id,
        id == event.attackerId
            ? player
            : player.copyWith(life: player.life - event.delta),
      ),
    );
    return state.copyWith(players: players);
  }

  PlayersState _healPlayer(PlayersState state, HealPlayer event) {
    final players = Map<int, Player>.from(state.players)
      ..update(
        event.targetId,
        (player) => player.copyWith(life: player.life + event.delta),
      );
    return state.copyWith(players: players);
  }

  PlayersState _healPlayers(PlayersState state, HealPlayers event) {
    final players = state.players.map(
      (id, player) =>
          MapEntry(id, player.copyWith(life: player.life + event.delta)),
    );
    return state.copyWith(players: players);
  }

  PlayersState _healOpponents(PlayersState state, HealOpponents event) {
    final players = state.players.map(
      (id, player) => MapEntry(
        id,
        id == event.sourceId
            ? player
            : player.copyWith(life: player.life + event.delta),
      ),
    );
    return state.copyWith(players: players);
  }

  PlayersState _infectDamagePlayer(
    PlayersState state,
    InfectDamagePlayer event,
  ) {
    final players = Map<int, Player>.from(state.players)
      ..update(
        event.targetId,
        (player) => player.copyWith(infect: player.infect + event.delta),
      );
    return state.copyWith(players: players);
  }

  PlayersState _infectDamagePlayers(
    PlayersState state,
    InfectDamagePlayers event,
  ) {
    final players = state.players.map(
      (id, player) =>
          MapEntry(id, player.copyWith(infect: player.infect + event.delta)),
    );
    return state.copyWith(players: players);
  }

  PlayersState _infectDamageOpponents(
    PlayersState state,
    InfectDamageOpponents event,
  ) {
    final players = state.players.map(
      (id, player) => MapEntry(
        id,
        id == event.attackerId
            ? player
            : player.copyWith(infect: player.infect + event.delta),
      ),
    );
    return state.copyWith(players: players);
  }

  PlayersState _lifelinkDamagePlayer(
    PlayersState state,
    LifelinkDamagePlayer event,
  ) {
    final players = Map<int, Player>.from(state.players)
      ..update(
        event.targetId,
        (player) => player.copyWith(life: player.life - event.delta),
      )
      ..update(
        event.attackerId,
        (player) => player.copyWith(life: player.life + event.delta),
      );
    return state.copyWith(players: players);
  }

  PlayersState _extort(PlayersState state, Extort event) {
    final numOpponents = state.players.length - 1;

    final players = state.players.map(
      (id, player) => MapEntry(
        id,
        id == event.attackerId
            ? player.copyWith(life: player.life + event.delta * numOpponents)
            : player.copyWith(life: player.life - event.delta),
      ),
    );
    return state.copyWith(players: players);
  }

  PlayersState _commanderDamage(PlayersState state, CommanderDamage event) {
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
    return state.copyWith(players: players);
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
