import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mtg_life_counter/profiles/models/card_info.dart';

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
