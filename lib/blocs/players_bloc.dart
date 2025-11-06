// blocs/life_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

enum DamageMode {
  damage("Damage"),
  healing("Healing");

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

class SetPlayers extends PlayerEvent {
  final int numPlayers;

  SetPlayers(this.numPlayers);
}

class DamagePlayer extends PlayerEvent {
  final int playerId;
  final int delta;

  DamagePlayer(this.playerId, this.delta);
}

class HealPlayer extends PlayerEvent {
  final int playerId;
  final int delta;

  HealPlayer(this.playerId, this.delta);
}

class PlayersState {
  final Map<int, Player> players;
  PlayersState(this.players);

  PlayersState copyWith({Map<int, Player>? players}) =>
      PlayersState(players ?? this.players);
}

class PlayersBloc extends Bloc<PlayerEvent, PlayersState> {
  PlayersBloc({required int playerCount})
    : super(
        PlayersState(
          List.generate(playerCount, (index) {
            return Player(id: index, name: "Player ${index + 1}", life: 40);
          }).asMap(),
        ),
      ) {
    on<SetPlayers>((event, emit) {
      final players = List.generate(event.numPlayers, (index) {
        return Player(id: index, name: "Player ${index + 1}", life: 40);
      }).asMap();

      emit(state.copyWith(players: players));
    });
    on<DamagePlayer>((event, emit) {
      final players = Map<int, Player>.from(state.players);
      Player player = players[event.playerId]!;

      int newLifeTotal = player.life - event.delta;
      bool isDead = newLifeTotal <= 0;

      players[player.id] = player.copyWith(life: newLifeTotal, isDead: isDead);

      emit(state.copyWith(players: players));
    });
    on<HealPlayer>((event, emit) {
      final players = Map<int, Player>.from(state.players);
      Player player = players[event.playerId]!;

      int newLifeTotal = player.life + event.delta;

      players[player.id] = player.copyWith(life: newLifeTotal);

      emit(state.copyWith(players: players));
    });
  }
}
