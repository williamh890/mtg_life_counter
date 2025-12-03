import 'dart:math';

import 'package:mtg_life_counter/profiles/models/deck.dart';

class Profile {
  final int id;
  final String username;
  final List<Deck> decks;
  
  Profile(this.id, this.username, this.decks);
  
  factory Profile.create(String username) {
    return Profile(_generateUniqueId(), username, []);
  }
  
  Profile copyWith({
    int? id,
    String? username,
    List<Deck>? decks,
  }) {
    return Profile(
      id ?? this.id,
      username ?? this.username,
      decks ?? this.decks,
    );
  }
  
  static int _generateUniqueId() {
    return Random().nextInt(1000000000);
  }
}