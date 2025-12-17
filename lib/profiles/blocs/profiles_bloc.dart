import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'package:mtg_life_counter/profiles/models/deck.dart';
import 'package:mtg_life_counter/profiles/models/profile.dart';

// Events
abstract class ProfilesEvent {}

class AddProfile extends ProfilesEvent {
  final String username;

  AddProfile(this.username);
}

class RemoveProfile extends ProfilesEvent {
  final int profileId;

  RemoveProfile(this.profileId);
}

class UpdateProfile extends ProfilesEvent {
  final int profileId;
  final String newUsername;

  UpdateProfile(this.profileId, this.newUsername);
}

class AddDeck extends ProfilesEvent {
  final int profileId;
  final Deck deck;

  AddDeck(this.profileId, this.deck);
}

class RemoveDeck extends ProfilesEvent {
  final int profileId;
  final int deckId;

  RemoveDeck(this.profileId, this.deckId);
}

class UpdateDeck extends ProfilesEvent {
  final int profileId;
  final int deckId;
  final String newName;
  final String newCommander;

  UpdateDeck(this.profileId, this.deckId, this.newName, this.newCommander);
}

// State
class ProfilesState {
  final List<Profile> profiles;

  ProfilesState({required this.profiles});

  ProfilesState copyWith({List<Profile>? profiles}) {
    return ProfilesState(profiles: profiles ?? this.profiles);
  }

  bool hasProfile(String username) {
    return profiles.any((p) => p.username == username);
  }

  Profile? getProfile(int profileId) {
    try {
      return profiles.firstWhere((p) => p.id == profileId);
    } catch (e) {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
    "profiles": profiles.map((p) => p.toJson()).toList(),
  };

  // deserialize ← json
  static ProfilesState fromJson(Map<String, dynamic> json) {
    return ProfilesState(
      profiles: (json["profiles"] as List<dynamic>)
          .map((p) => Profile.fromJson(p))
          .toList(),
    );
  }
}

// Bloc
class ProfilesBloc extends HydratedBloc<ProfilesEvent, ProfilesState> {
  ProfilesBloc()
    : super(
        ProfilesState(
          profiles: [
            Profile.create('William'),
            Profile.create('Kelvin'),
            Profile.create('Brady'),
          ],
        ),
      ) {
    on<AddProfile>((event, emit) {
      final updatedProfiles = List<Profile>.from(state.profiles)
        ..add(Profile.create(event.username));

      emit(state.copyWith(profiles: updatedProfiles));
    });

    on<RemoveProfile>((event, emit) {
      final updatedProfiles = state.profiles
          .where((p) => p.id != event.profileId)
          .toList();

      emit(state.copyWith(profiles: updatedProfiles));
    });

    on<UpdateProfile>((event, emit) {
      final updatedProfiles = state.profiles.map((p) {
        if (p.id == event.profileId) {
          return Profile(p.id, event.newUsername, p.decks);
        }
        return p;
      }).toList();

      emit(state.copyWith(profiles: updatedProfiles));
    });

    on<AddDeck>((event, emit) {
      final updatedProfiles = state.profiles.map((p) {
        if (p.id == event.profileId) {
          final updatedDecks = List<Deck>.from(p.decks)..add(event.deck);
          return p.copyWith(decks: updatedDecks);
        }
        return p;
      }).toList();

      emit(state.copyWith(profiles: updatedProfiles));
    });

    on<RemoveDeck>((event, emit) {
      final updatedProfiles = state.profiles.map((p) {
        if (p.id == event.profileId) {
          final updatedDecks = p.decks
              .where((d) => d.id != event.deckId)
              .toList();
          return p.copyWith(decks: updatedDecks);
        }
        return p;
      }).toList();

      emit(state.copyWith(profiles: updatedProfiles));
    });
  }

  @override
  ProfilesState? fromJson(Map<String, dynamic> json) {
    return ProfilesState.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(ProfilesState state) {
    return state.toJson();
  }
}
