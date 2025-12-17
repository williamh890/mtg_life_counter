import 'dart:math';

import 'package:mtg_life_counter/profiles/services/scryfall_service.dart';

class Deck {
  int id;
  String name;
  CardInfo commander;

  Deck(this.id, this.name, this.commander);

  factory Deck.create(String name, CardInfo commander) {
    return Deck(_generateUniqueId(), name, commander);
  }

  static int _generateUniqueId() {
    return Random().nextInt(1000000000);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "commander": commander.toJson()};
  }

  static Deck fromJson(Map<String, dynamic> json) {
    return Deck(
      json["id"] as int,
      json["name"] as String,
      CardInfo.fromJson(json["commander"] as Map<String, dynamic>),
    );
  }
}