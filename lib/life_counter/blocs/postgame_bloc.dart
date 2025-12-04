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

class PreviousPostGameStep extends PostGameEvent {}

class NextPostgameStep extends PostGameEvent {}

class ToggleWinner extends PostGameEvent {
  final int playerId;

  ToggleWinner(this.playerId);
}

class SetRating extends PostGameEvent {
  final int playerId;
  final GameRating? gameRating;

  SetRating(this.playerId, this.gameRating);
}

class SetSaltiness extends PostGameEvent {
  final int playerId;
  final int? salt;

  SetSaltiness(this.playerId, this.salt);
}

class SetCommendedPlayer extends PostGameEvent {
  final int playerId;
  final int? commendedPlayerId;

  SetCommendedPlayer(this.playerId, this.commendedPlayerId);
}

class SetCringePlayer extends PostGameEvent {
  final int playerId;
  final int? cringePlayerId;

  SetCringePlayer(this.playerId, this.cringePlayerId);
}

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

    on<PreviousPostGameStep>((event, emit) {
      final previousPhase = switch (state.phase) {
        PostGamePhase.completed => PostGamePhase.overview,
        PostGamePhase.overview => PostGamePhase.rating,
        PostGamePhase.rating => PostGamePhase.winners,
        PostGamePhase.winners => PostGamePhase.notStarted,
        PostGamePhase.notStarted => PostGamePhase.notStarted,
      };

      if (previousPhase == PostGamePhase.notStarted) {
        emit(
          PostGameState(
            phase: PostGamePhase.notStarted,
            players: {},
            ratings: {},
            selectedWinners: {},
          ),
        );
      } else {
        emit(state.copyWith(phase: previousPhase));
      }
    });

    on<NextPostgameStep>((event, emit) {
      final nextPhase = switch (state.phase) {
        PostGamePhase.notStarted => PostGamePhase.winners,
        PostGamePhase.winners => PostGamePhase.rating,
        PostGamePhase.rating => PostGamePhase.overview,
        PostGamePhase.overview => PostGamePhase.completed,
        PostGamePhase.completed => PostGamePhase.notStarted,
      };

      emit(state.copyWith(phase: nextPhase));
    });

    on<ToggleWinner>((event, emit) {
      final newSelectedWinners = Set<int>.from(state.selectedWinners);

      if (newSelectedWinners.contains(event.playerId)) {
        newSelectedWinners.remove(event.playerId);
      } else {
        newSelectedWinners.add(event.playerId);
      }

      emit(state.copyWith(selectedWinners: newSelectedWinners));
    });

    on<SetRating>((event, emit) {
      final updatedRatings = Map<int, PlayerRating>.from(state.ratings);
      final currentRating = updatedRatings[event.playerId]!;

      updatedRatings[event.playerId] = currentRating.copyWith(
        gameRating: event.gameRating,
      );

      emit(state.copyWith(ratings: updatedRatings));
    });

    on<SetSaltiness>((event, emit) {
      final updatedRatings = Map<int, PlayerRating>.from(state.ratings);
      final currentRating = updatedRatings[event.playerId]!;

      updatedRatings[event.playerId] = currentRating.copyWith(
        saltiness: event.salt,
      );

      emit(state.copyWith(ratings: updatedRatings));
    });

    on<SetCommendedPlayer>((event, emit) {
      final updatedRatings = Map<int, PlayerRating>.from(state.ratings);
      final currentRating = updatedRatings[event.playerId]!;

      updatedRatings[event.playerId] = currentRating.copyWith(
        commendedPlayerId: event.commendedPlayerId,
      );

      emit(state.copyWith(ratings: updatedRatings));
    });

    on<SetCringePlayer>((event, emit) {
      final updatedRatings = Map<int, PlayerRating>.from(state.ratings);
      final currentRating = updatedRatings[event.playerId]!;

      updatedRatings[event.playerId] = currentRating.copyWith(
        cringePlayerId: event.cringePlayerId,
      );

      emit(state.copyWith(ratings: updatedRatings));
    });
  }

  static Map<int, PlayerRating> _generatePlayerRatings(
    Map<int, Player> players,
  ) {
    final ratings = {
      for (var player in players.values)
        player.id: PlayerRating(player.id, null, null, null, null),
    };
    return ratings;
  }
}
