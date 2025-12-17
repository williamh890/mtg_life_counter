import 'dart:convert';
import 'package:http/http.dart' as http;

class CardInfo {
  final String name;
  final String? manaCost;
  final String typeLine;

  final String artImageUrl;
  final String cardImageUrl;

  CardInfo({
    required this.name,
    this.manaCost,
    required this.typeLine,
    required this.artImageUrl,
    required this.cardImageUrl,
  });

  factory CardInfo.fromJson(Map<String, dynamic> json) {
    // Handle cases where 'image_uris' might be missing (e.g., double-faced cards)
    String artImageUrl = '';
    String cardImageUrl = '';

    if (json.containsKey('image_uris') && json['image_uris'] != null) {
      artImageUrl = json['image_uris']['art_crop'] ?? '';
      cardImageUrl = json['image_uris']['border_crop'] ?? '';
    } else if (json.containsKey('card_faces')) {
      // For double-faced cards, usually the first face has the image
      final faces = json['card_faces'] as List;
      if (faces.isNotEmpty && faces[0].containsKey('image_uris')) {
        artImageUrl = faces[0]['image_uris']['art_crop'] ?? '';
        cardImageUrl = faces[0]['image_uris']['border_crop'] ?? '';
      }
    }

    return CardInfo(
      name: json['name'] as String,
      manaCost: json['mana_cost'] as String?,
      typeLine: json['type_line'] as String,
      artImageUrl: artImageUrl,
      cardImageUrl: cardImageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "mana_cost": manaCost,
      "type_line": typeLine,
      "image_uris": {"art_crop": artImageUrl, "border_crop": cardImageUrl},
    };
  }
}

Future<List<CardInfo>> searchCards(String query) async {
  if (query.trim().isEmpty) {
    return [];
  }

  final String finalQuery = 'name:$query t:legendary t:creature';

  final uri = Uri.https('api.scryfall.com', '/cards/search', {
    'q': finalQuery,
    'unique': 'cards',
  });
  print(uri);
  try {
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> cardsJson = data['data'];

      // Map the JSON list to CardInfo objects and take the first 10
      return cardsJson
          .take(10) // Limit to 10 results immediately
          .map((json) => CardInfo.fromJson(json))
          .toList();
    } else {
      // Scryfall returns 404 if no cards match the search
      return [];
    }
  } catch (e) {
    return [];
  }
}
