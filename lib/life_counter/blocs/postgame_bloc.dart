import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mtg_life_counter/life_counter/models/player.dart';
import 'package:mtg_life_counter/life_counter/blocs/players_bloc.dart';
import 'package:mtg_life_counter/life_counter/models/player_rating.dart';
import 'package:mtg_life_counter/life_counter/models/postgame_phase.dart';

// Events
abstract class PostGameEvent {}

class InitializePostGame extends PostGameEvent {
  final PlayersState gameState;

  InitializePostGame(this.gameState);
}

class CancelPostGame extends PostGameEvent {
  CancelPostGame();
}

class ToggleWinner extends PostGameEvent {
  final int playerId;

  ToggleWinner(this.playerId);
}

class ConfirmWinners extends PostGameEvent {}

class PostGameState {
  final PostGamePhase phase;
  final Map<int, Player> players;
  final Map<int, PlayerRating> ratings;
  final Set<int> selectedWinners;

  PostGameState({
    required this.phase,
    required this.players,
    required this.ratings,
    required this.selectedWinners,
  });

  PostGameState copyWith({
    PostGamePhase? phase,
    Map<int, Player>? players,
    Map<int, PlayerRating>? ratings,
    Set<int>? selectedWinners,
  }) {
    return PostGameState(
      phase: phase ?? this.phase,
      players: players ?? this.players,
      ratings: ratings ?? this.ratings,
      selectedWinners: selectedWinners ?? this.selectedWinners,
    );
  }

  bool isWinner(int playerId) => selectedWinners.contains(playerId);
  bool get hasWinners => selectedWinners.isNotEmpty;
}

// Bloc
class PostGameBloc extends Bloc<PostGameEvent, PostGameState> {
  PostGameBloc()
    : super(
        PostGameState(
          phase: PostGamePhase.notStarted,
          players: {},
          ratings: {},
          selectedWinners: {},
        ),
      ) {
    on<InitializePostGame>((event, emit) {
      emit(
        PostGameState(
          phase: PostGamePhase.winners,
          players: event.gameState.players,
          ratings: _generatePlayerRatings(event.gameState.players),
          selectedWinners: {},
        ),
      );
    });

    on<CancelPostGame>((event, emit) {
      emit(
        PostGameState(
          phase: PostGamePhase.notStarted,
          players: {},
          ratings: {},
          selectedWinners: {},
        ),
      );
    });

    on<ToggleWinner>((event, emit) {
      if (state.phase != PostGamePhase.winners) return;

      final newSelectedWinners = Set<int>.from(state.selectedWinners);

      if (newSelectedWinners.contains(event.playerId)) {
        newSelectedWinners.remove(event.playerId);
      } else {
        newSelectedWinners.add(event.playerId);
      }

      emit(state.copyWith(selectedWinners: newSelectedWinners));
    });

    on<ConfirmWinners>((event, emit) {
      if (state.phase != PostGamePhase.winners) return;

      emit(state.copyWith(phase: PostGamePhase.rating));
    });
  }

  static Map<int, PlayerRating> _generatePlayerRatings(
    Map<int, Player> players,
  ) {
    final ratings = {
      for (var player in players.values)
        player.id: PlayerRating(player.id, null, null, null),
    };
    return ratings;
  }
}
