import 'package:flutter/material.dart';

class Player {
  final int id;
  String name;
  int life;
  int infect;
  Map<int, int> commanderDamage;

  static const List<Color> _colors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.yellowAccent,
    Colors.cyanAccent,
    Colors.pinkAccent,
  ];

  Player({
    required this.id,
    required this.name,
    required this.life,
    required this.infect,
    required this.commanderDamage,
  });

  Player copyWith({
    int? id,
    String? name,
    int? life,
    int? infect,
    Map<int, int>? commanderDamage,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      life: life ?? this.life,
      infect: infect ?? this.infect,
      commanderDamage: commanderDamage ?? this.commanderDamage,
    );
  }

  bool isDead() {
    return life <= 0 || commanderDamage.values.any((v) => v >= 21) || infect >= 11;
  }

  Color getColor() {
    return _colors[id % _colors.length];
  }
}
