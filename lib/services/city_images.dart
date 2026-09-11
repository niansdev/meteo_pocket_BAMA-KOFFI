import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/city.dart';

class CityImages {
  static const _timeout = Duration(seconds: 8);
  static final Map<String, String?> _cache = {};

  static const Map<String, String> _monuments = {
    'Abidjan': 'Cathédrale Saint-Paul Abidjan',
    'Yamoussoukro': 'Basilique Notre-Dame de la Paix Yamoussoukro',
    'Bouaké': 'Bouaké Côte d Ivoire',
    'Dakar': 'Monument de la Renaissance Africaine Dakar',
    'Paris': 'Tour Eiffel Paris',
    'Londres': 'Big Ben London',
    'New York': 'Statue of Liberty New York',
    'Tokyo': 'Tokyo Skytree',
    'Dubaï': 'Burj Khalifa Dubai',
    'Casablanca': 'Mosquée Hassan II Casablanca',
    'Accra': 'Kwame Nkrumah Memorial Accra',
    'Lagos': 'Lagos Nigeria landmark',
    'Nairobi': 'Nairobi Kenya landmark',
    'Cotonou': 'Place de l Amazone Cotonou',
    'Ouagadougou': 'Monument des Héros Nationaux Ouagadougou',
    'Bamako': 'Monument de l Indépendance Bamako',
    'Rome': 'Colisée Rome',
    'Madrid': 'Palais Royal Madrid',
    'Berlin': 'Porte de Brandebourg Berlin',
    'Sydney': 'Opéra de Sydney',
    'Montréal': 'Montréal landmark',
    'Lyon': 'Basilique Notre-Dame de Fourvière Lyon',
  };

  static Future<String?> getImageUrl(City city) async {
    final key = '${city.name}|${city.latitude}|${city.longitude}';
    if (_cache.containsKey(key)) return _cache[key];

    try {
      final query = _monuments[city.name] ?? '${city.name} ${city.country} landmark';
      final url = await _searchWikimedia(query);
      _cache[key] = url;
      return url;
    } catch (_) {
      _cache[key] = null;
      return null;
    }
  }

  static Future<String?> _searchWikimedia(String query) async {
    final uri = Uri.https('commons.wikimedia.org', '/w/api.php', {
      'action': 'query',
      'generator': 'search',
      'gsrsearch': query,
      'gsrnamespace': '6',
      'gsrlimit': '8',
      'prop': 'imageinfo',
      'iiprop': 'url|mime',
      'iiurlwidth': '1200',
      'format': 'json',
      'origin': '*',
    });

    final response = await http.get(
      uri,
      headers: {
        'Accept': 'application/json',
        'User-Agent': 'MeteoPocket/2.0 Flutter academic project',
      },
    ).timeout(_timeout);

    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;

    final queryData = decoded['query'];
    if (queryData is! Map<String, dynamic>) return null;

    final pages = queryData['pages'];
    if (pages is! Map) return null;

    for (final rawPage in pages.values) {
      if (rawPage is! Map<String, dynamic>) continue;
      final infoList = rawPage['imageinfo'];
      if (infoList is! List || infoList.isEmpty) continue;
      final info = infoList.first;
      if (info is! Map<String, dynamic>) continue;
      final mime = info['mime']?.toString() ?? '';
      if (!mime.startsWith('image/')) continue;
      final thumb = info['thumburl']?.toString();
      if (thumb != null && thumb.isNotEmpty) return thumb;
      final original = info['url']?.toString();
      if (original != null && original.isNotEmpty) return original;
    }
    return null;
  }

  static void clearCache() => _cache.clear();
}
