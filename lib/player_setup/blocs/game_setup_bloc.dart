import 'package:flutter_bloc/flutter_bloc.dart';

// Events
abstract class GameSetupEvent {}

class SetPlayerCount extends GameSetupEvent {
  final int playerCount;

  SetPlayerCount(this.playerCount);
}

class SetStartingLife extends GameSetupEvent {
  final int startingLife;

  SetStartingLife(this.startingLife);
}

class ResetSetup extends GameSetupEvent {}

// State
class GameSetupState {
  final int playerCount;
  final int startingLife;

  GameSetupState({required this.playerCount, required this.startingLife});

  GameSetupState copyWith({int? playerCount, int? startingLife}) {
    return GameSetupState(
      playerCount: playerCount ?? this.playerCount,
      startingLife: startingLife ?? this.startingLife,
    );
  }
}

// Bloc
class GameSetupBloc extends Bloc<GameSetupEvent, GameSetupState> {
  GameSetupBloc({int initialPlayerCount = 4, int initialStartingLife = 40})
    : super(
        GameSetupState(
          playerCount: initialPlayerCount,
          startingLife: initialStartingLife,
        ),
      ) {
    on<SetPlayerCount>((event, emit) {
      emit(state.copyWith(playerCount: event.playerCount));
    });

    on<SetStartingLife>((event, emit) {
      emit(state.copyWith(startingLife: event.startingLife));
    });

    on<ResetSetup>((event, emit) {
      emit(GameSetupState(playerCount: 4, startingLife: 40));
    });
  }
}
