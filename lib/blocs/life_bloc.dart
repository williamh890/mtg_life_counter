import 'package:flutter_bloc/flutter_bloc.dart';

// Event
class UpdateLife {
  final int playerIndex;
  final int delta; // positive or negative
  UpdateLife(this.playerIndex, this.delta);
}

// Bloc
class LifeBloc extends Bloc<UpdateLife, List<int>> {
  LifeBloc({required int playerCount})
      : super(List.filled(playerCount, 40)) {
    on<UpdateLife>((event, emit) {
      final newState = List<int>.from(state);
      newState[event.playerIndex] += event.delta;
      emit(newState);
    });
  }
}