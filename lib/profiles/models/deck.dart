import 'dart:math';

class Deck {
  int id;
  String name;
  String commander;

  Deck(this.id, this.name, this.commander);

  factory Deck.create(String name, String commander) {
    return Deck(_generateUniqueId(), name, commander);
  }

  static int _generateUniqueId() {
    return Random().nextInt(1000000000);
  }
}
