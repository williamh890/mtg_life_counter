import 'package:mtg_life_counter/services/image_store.dart';

class CardInfo {
  final String name;
  final String? manaCost;
  final String typeLine;

  final PersistedImage art;
  final PersistedImage card;

  CardInfo({
    required this.name,
    this.manaCost,
    required this.typeLine,
    required this.art,
    required this.card,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    String artUrl = '';
    String cardUrl = '';

    if (json['image_uris'] != null) {
      artUrl = json['image_uris']['art_crop'] ?? '';
      cardUrl = json['image_uris']['border_crop'] ?? '';
    } else if (json['card_faces'] != null) {
      final face = json['card_faces'][0];
      artUrl = face['image_uris']['art_crop'] ?? '';
      cardUrl = face['image_uris']['border_crop'] ?? '';
    }

    return CardInfo(
      name: json['name'],
      manaCost: json['mana_cost'],
      typeLine: json['type_line'],
      art: PersistedImage(url: artUrl),
      card: PersistedImage(url: cardUrl),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'mana_cost': manaCost,
    'type_line': typeLine,
    'art': art.toJson(),
    'card': card.toJson(),
  };

  factory CardInfo.fromHydratedJson(Map<String, dynamic> json) {
    return CardInfo(
      name: json['name'],
      manaCost: json['mana_cost'],
      typeLine: json['type_line'],
      art: PersistedImage.fromJson(json['art']),
      card: PersistedImage.fromJson(json['card']),
    );
  }
}
