import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/city.dart';
import '../models/weather.dart';

class WeatherService {
  static const _host = 'api.open-meteo.com';
  static const _timeout = Duration(seconds: 12);

  Future<Weather> getWeather(City city) async {
    final uri = Uri.https(_host, '/v1/forecast', {
      'latitude': city.latitude.toString(),
      'longitude': city.longitude.toString(),
      'current':
          'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m,wind_direction_10m,surface_pressure,visibility,uv_index',
      'hourly':
          'temperature_2m,weather_code,precipitation_probability,wind_speed_10m',
      'daily':
          'weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,uv_index_max,sunrise,sunset',
      'forecast_days': '7',
      'forecast_hours': '12',
      'timezone': 'auto',
    });

    try {
      final response = await http
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(_timeout);

      if (response.statusCode != 200) {
        throw WeatherException(
          'Le service météo est momentanément indisponible (${response.statusCode}).',
        );
      }

      final data = jsonDecode(response.body);
      if (data is! Map<String, dynamic> || data['current'] == null) {
        throw const WeatherException('Réponse météo invalide.');
      }

      return Weather.fromJson(data, cityName: city.name);
    } on WeatherException {
      rethrow;
    } catch (_) {
      throw const WeatherException(
        'Impossible de charger la météo. Vérifiez votre connexion Internet.',
      );
    }
  }
}

class WeatherException implements Exception {
  final String message;

  const WeatherException(this.message);

  @override
  String toString() => message;
}
