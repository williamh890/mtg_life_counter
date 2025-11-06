// blocs/life_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

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

abstract class LifeEvent {}

class UpdateLife extends LifeEvent {
  final int playerId;
  final int delta;
  UpdateLife(this.playerId, this.delta);
}

class LifeState {
  final Map<int, Player> players;
  LifeState(this.players);

  LifeState copyWith({Map<int, Player>? players}) =>
      LifeState(players ?? this.players);
}

class LifeBloc extends Bloc<LifeEvent, LifeState> {
  LifeBloc({required int playerCount})
    : super(
        LifeState(
          List.generate(playerCount, (index) {
            return Player(id: index, name: "Player ${index + 1}", life: 40);
          }).asMap(),
        ),
      ) {
    on<UpdateLife>((event, emit) {
      final players = Map<int, Player>.from(state.players);
      Player player = players[event.playerId]!;

      if (player.isDead) return; // cannot damage dead players

      players[player.id] = player.copyWith(life: player.life + event.delta);

      emit(state.copyWith(players: players));
    });
  }
}
