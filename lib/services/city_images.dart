import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/city.dart';

class CityImages {
  static const _requestTimeout = Duration(seconds: 8);

  static final Map<String, String?> _cache = {};

  static const Map<String, String> _monuments = {
    // Côte d'Ivoire
    'Abidjan': 'Cathédrale Saint-Paul Abidjan',
    'Bouaké': 'Bouaké Côte d Ivoire',
    'Yamoussoukro': 'Basilique Notre-Dame de la Paix Yamoussoukro',

    // Afrique
    'Accra': 'Kwame Nkrumah Memorial Accra',
    'Addis-Abeba': 'Holy Trinity Cathedral Addis Ababa',
    'Casablanca': 'Mosquée Hassan II Casablanca',
    'Dakar': 'Monument de la Renaissance Africaine Dakar',
    'Johannesburg': 'Constitution Hill Johannesburg',
    'Le Caire': 'Pyramides de Gizeh Cairo',
    'Lagos': 'National Arts Theatre Lagos Nigeria',
    'Marrakech': 'Mosquée Koutoubia Marrakech',
    'Nairobi': 'Nairobi National Park landmark',
    'Tunis': 'Mosquée Zitouna Tunis',
    'Cape Town': 'Table Mountain Cape Town',

    // Europe
    'Amsterdam': 'Rijksmuseum Amsterdam',
    'Athènes': 'Acropole Athènes',
    'Barcelone': 'Sagrada Familia Barcelona',
    'Berlin': 'Porte de Brandebourg Berlin',
    'Bruxelles': 'Atomium Brussels',
    'Copenhague': 'Little Mermaid Copenhagen',
    'Dublin': 'Dublin Castle Ireland',
    'Lisbonne': 'Tour de Belém Lisbon',
    'Londres': 'Big Ben London',
    'Madrid': 'Palais Royal Madrid',
    'Milan': 'Duomo Milan',
    'Moscou': 'Place Rouge Moscou',
    'Munich': 'Marienplatz Munich',
    'Oslo': 'Opera House Oslo',
    'Paris': 'Tour Eiffel Paris',
    'Prague': 'Pont Charles Prague',
    'Rome': 'Colisée Rome',
    'Stockholm': 'Hôtel de Ville Stockholm',
    'Vienne': 'Palais de Schönbrunn Vienna',
    'Zurich': 'Grossmünster Zurich',

    // Asie
    'Bangkok': 'Grand Palais Bangkok',
    'Hanoï': 'Temple de la Littérature Hanoi',
    'Hong Kong': 'Victoria Harbour Hong Kong',
    'Jakarta': 'Monument National Monas Jakarta',
    'Kuala Lumpur': 'Petronas Twin Towers Kuala Lumpur',
    'Manille': 'Intramuros Manila',
    'Mumbai': 'Gateway of India Mumbai',
    'New Delhi': 'India Gate New Delhi',
    'Osaka': 'Château d Osaka Japan',
    'Séoul': 'Gyeongbokgung Palace Seoul',
    'Shanghai': 'Shanghai Tower',
    'Singapour': 'Marina Bay Sands Singapore',
    'Taipei': 'Taipei 101',
    'Tokyo': 'Tokyo Skytree',

    // Moyen-Orient
    'Abou Dabi': 'Sheikh Zayed Grand Mosque Abu Dhabi',
    'Amman': 'Amman Citadel Jordan',
    'Bagdad': 'Baghdad Iraq landmark',
    'Doha': 'Museum of Islamic Art Doha',
    'Dubaï': 'Burj Khalifa Dubai',
    'Jérusalem': 'Dôme du Rocher Jerusalem',
    'La Mecque': 'Grande Mosquée de La Mecque',
    'Médine': 'Mosquée du Prophète Medina',
    'Riyad': 'Kingdom Centre Riyadh',

    // Amérique du Nord
    'Atlanta': 'Atlanta Georgia landmark',
    'Boston': 'Boston Massachusetts landmark',
    'Chicago': 'Cloud Gate Chicago',
    'Las Vegas': 'Las Vegas Strip',
    'Los Angeles': 'Hollywood Sign Los Angeles',
    'Miami': 'Miami Beach Florida',
    'Montréal': 'Montreal landmark',
    'New York': 'Statue of Liberty New York',
    'San Francisco': 'Golden Gate Bridge San Francisco',
    'Toronto': 'CN Tower Toronto',
    'Vancouver': 'Canada Place Vancouver',
    'Washington': 'Washington Monument Washington DC',

    // Amérique du Sud
    'Buenos Aires': 'Obelisk Buenos Aires',
    'Lima': 'Plaza de Armas Lima Peru',
    'Medellín': 'Plaza Botero Medellin',
    'Rio de Janeiro': 'Christ the Redeemer Rio de Janeiro',
    'Santiago': 'Costanera Center Santiago Chile',
    'São Paulo': 'Paulista Avenue Sao Paulo',

    // Océanie
    'Auckland': 'Sky Tower Auckland',
    'Melbourne': 'Flinders Street Station Melbourne',
    'Sydney': 'Sydney Opera House',
  };

  static Future<String?> getImageUrl(City city) async {
    final key = _cacheKey(city);

    if (_cache.containsKey(key)) {
      return _cache[key];
    }

    try {
      String? imageUrl;

      final monument = _findMonument(city);

      if (monument != null) {
        imageUrl = await _searchWikimedia(monument);
      }

      imageUrl ??= await _searchCityImages(city);

      _cache[key] = imageUrl;
      return imageUrl;
    } catch (_) {
      _cache[key] = null;
      return null;
    }
  }

  static String? _findMonument(City city) {
    final name = _normalize(city.name);

    for (final entry in _monuments.entries) {
      if (_normalize(entry.key) == name) {
        return entry.value;
      }
    }

    return null;
  }

  static Future<String?> _searchCityImages(City city) async {
    final queries = [
      '${city.name} ${city.country} famous landmark',
      '${city.name} ${city.country} monument',
      '${city.name} ${city.country} landmark',
      '${city.name} ${city.country} famous building',
      '${city.name} ${city.country}',
    ];

    for (final query in queries) {
      final imageUrl = await _searchWikimedia(query);

      if (imageUrl != null && imageUrl.isNotEmpty) {
        return imageUrl;
      }
    }

    return null;
  }

  static Future<String?> _searchWikimedia(String query) async {
    final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
      'action': 'query',
      'generator': 'search',
      'gsrsearch': query,
      'gsrnamespace': '6',
      'gsrlimit': '10',
      'prop': 'imageinfo',
      'iiprop': 'url|mime',
      'iiurlwidth': '1200',
      'format': 'json',
      'origin': '*',
    });

    final response = await http
        .get(
          uri,
          headers: const {
            'Accept': 'application/json',
            'User-Agent': 'MeteoPocket/2.0 Flutter academic project',
          },
        )
        .timeout(_requestTimeout);

    if (response.statusCode != 200) {
      return null;
    }

    final data = jsonDecode(response.body);

    if (data is! Map<String, dynamic>) {
      return null;
    }

    final queryData = data['query'];

    if (queryData is! Map<String, dynamic>) {
      return null;
    }

    final pages = queryData['pages'];

    if (pages is! Map) {
      return null;
    }

    for (final page in pages.values) {
      if (page is! Map<String, dynamic>) {
        continue;
      }

      final imageInfo = page['imageinfo'];

      if (imageInfo is! List || imageInfo.isEmpty) {
        continue;
      }

      final firstInfo = imageInfo.first;

      if (firstInfo is! Map<String, dynamic>) {
        continue;
      }

      final mimeType = firstInfo['mime']?.toString() ?? '';

      if (!mimeType.startsWith('image/')) {
        continue;
      }

      final thumbnail = firstInfo['thumburl']?.toString();

      if (thumbnail != null && thumbnail.isNotEmpty) {
        return thumbnail;
      }

      final original = firstInfo['url']?.toString();

      if (original != null && original.isNotEmpty) {
        return original;
      }
    }

    return null;
  }

  static String _cacheKey(City city) {
    return '${city.name}|${city.latitude}|${city.longitude}';
  }

  static String _normalize(String value) {
    return value
        .toLowerCase()
        .trim()
        .replaceAll('é', 'e')
        .replaceAll('è', 'e')
        .replaceAll('ê', 'e')
        .replaceAll('ë', 'e')
        .replaceAll('à', 'a')
        .replaceAll('â', 'a')
        .replaceAll('ä', 'a')
        .replaceAll('î', 'i')
        .replaceAll('ï', 'i')
        .replaceAll('ô', 'o')
        .replaceAll('ö', 'o')
        .replaceAll('ù', 'u')
        .replaceAll('û', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ç', 'c');
  }

  static void clearCache() {
    _cache.clear();
  }
}
