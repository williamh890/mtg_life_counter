// blocs/life_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';

abstract class LifeEvent {}
class UpdateLife extends LifeEvent {
  final int playerIndex;
  final int delta;
  UpdateLife(this.playerIndex, this.delta);
}

class LifeState {
  final List<int> lives;
  final List<bool> dead;
  LifeState(this.lives, this.dead);

  LifeState copyWith({List<int>? lives, List<bool>? dead}) =>
      LifeState(lives ?? this.lives, dead ?? this.dead);
}

class LifeBloc extends Bloc<LifeEvent, LifeState> {
  LifeBloc({required int playerCount})
      : super(LifeState(List.filled(playerCount, 40), List.filled(playerCount, false))) {
    on<UpdateLife>((event, emit) {
      final lives = List<int>.from(state.lives);
      final dead = List<bool>.from(state.dead);

      if (dead[event.playerIndex]) return; // cannot damage dead players

      lives[event.playerIndex] = (lives[event.playerIndex] + event.delta).clamp(0, 9999);
      if (lives[event.playerIndex] <= 0) {
        lives[event.playerIndex] = 0;
        dead[event.playerIndex] = true;
      }

      emit(state.copyWith(lives: lives, dead: dead));
    });
  }
}
