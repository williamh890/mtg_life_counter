import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';

class Profile {
  final int id;
  final String username;

  Profile(this.id, this.username);

  factory Profile.create(String username) {
    return Profile(_generateUniqueId(), username);
  }

  static int _generateUniqueId() {
    return Random().nextInt(1000000000);
  }
}

// Events
abstract class ProfilesEvent {}

class LoadProfiles extends ProfilesEvent {}

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
}

// Bloc
class ProfilesBloc extends Bloc<ProfilesEvent, ProfilesState> {
  ProfilesBloc() : super(ProfilesState(profiles: [
        Profile.create('William'),
        Profile.create('Kelvin'),
        Profile.create('Brady'),
  ])) {
    on<LoadProfiles>((event, emit) {
      // Load default profiles
      final defaultProfiles = [
        Profile.create('William'),
        Profile.create('Kelvin'),
        Profile.create('Brady'),
      ];

      emit(state.copyWith(profiles: defaultProfiles));
    });

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
          return Profile(p.id, event.newUsername);
        }
        return p;
      }).toList();

      emit(state.copyWith(profiles: updatedProfiles));
    });
  }
}
