import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/air_quality.dart';
import '../models/city.dart';

class AirQualityService {
  static const _timeout = Duration(seconds: 10);

  Future<AirQuality> getAirQuality(City city) async {
    final uri = Uri.https('air-quality-api.open-meteo.com', '/v1/air-quality', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current': 'pm10,pm2_5,european_aqi,us_aqi',
      'timezone': 'auto',
    });

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw const AirQualityException(
          'Qualité de l’air momentanément indisponible.',
        );
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic>) {
        throw const AirQualityException('Réponse qualité de l’air invalide.');
      }

      return AirQuality.fromJson(data);
    } on AirQualityException {
      rethrow;
    } catch (_) {
      throw const AirQualityException(
        'Impossible de charger la qualité de l’air.',
      );
    }
  }
}

class AirQualityException implements Exception {
  final String message;

  const AirQualityException(this.message);

  @override
  String toString() => message;
}
