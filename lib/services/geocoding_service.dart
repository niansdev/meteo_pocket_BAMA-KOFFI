import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/city.dart';

class GeocodingService {
  static const _timeout = Duration(seconds: 8);

  Future<List<City>> searchCities(String query) async {
    final value = query.trim();
    if (value.length < 2) return [];

    final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': value,
      'count': '8',
      'language': 'fr',
      'format': 'json',
    });

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw const CitySearchException('Recherche indisponible.');
      }

      final data = jsonDecode(response.body);
      final results = data is Map<String, dynamic> ? data['results'] : null;
      if (results is! List) return [];

      return results
          .whereType<Map<String, dynamic>>()
          .map(City.fromJson)
          .toList();
    } on CitySearchException {
      rethrow;
    } catch (_) {
      throw const CitySearchException(
        'Impossible de rechercher la ville. Vérifiez votre connexion.',
      );
    }
  }
}

class CitySearchException implements Exception {
  final String message;

  const CitySearchException(this.message);

  @override
  String toString() => message;
}
