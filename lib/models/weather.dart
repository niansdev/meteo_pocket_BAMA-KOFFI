class HourlyWeather {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int precipitationProbability;
  final double windSpeed;

  const HourlyWeather({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.precipitationProbability,
    required this.windSpeed,
  });
}

class DailyWeather {
  final DateTime date;
  final int weatherCode;
  final double minTemperature;
  final double maxTemperature;
  final double precipitation;
  final double uvIndex;
  final DateTime sunrise;
  final DateTime sunset;

  const DailyWeather({
    required this.date,
    required this.weatherCode,
    required this.minTemperature,
    required this.maxTemperature,
    required this.precipitation,
    required this.uvIndex,
    required this.sunrise,
    required this.sunset,
  });
}

class Weather {
  final String cityName;
  final double temperature;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double pressure;
  final double visibility;
  final double precipitation;
  final double uvIndex;
  final int weatherCode;
  final DateTime time;
  final List<HourlyWeather> hourly;
  final List<DailyWeather> daily;

  const Weather({
    required this.cityName,
    required this.temperature,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.pressure,
    required this.visibility,
    required this.precipitation,
    required this.uvIndex,
    required this.weatherCode,
    required this.time,
    required this.hourly,
    required this.daily,
  });

  String get description => weatherDescription(weatherCode);
  String get icon => weatherIcon(weatherCode);

  String get windDirectionLabel {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    final index = ((windDirection + 22.5) ~/ 45) % directions.length;
    return directions[index];
  }

  static String weatherDescription(int code) {
    switch (code) {
      case 0:
        return 'Ciel dégagé';
      case 1:
        return 'Principalement dégagé';
      case 2:
        return 'Partiellement nuageux';
      case 3:
        return 'Couvert';
      case 45:
      case 48:
        return 'Brouillard';
      case 51:
      case 53:
      case 55:
        return 'Bruine';
      case 56:
      case 57:
        return 'Bruine verglaçante';
      case 61:
      case 63:
      case 65:
        return 'Pluie';
      case 66:
      case 67:
        return 'Pluie verglaçante';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Neige';
      case 80:
      case 81:
      case 82:
        return 'Averses';
      case 85:
      case 86:
        return 'Averses de neige';
      case 95:
        return 'Orage';
      case 96:
      case 99:
        return 'Orage avec grêle';
      default:
        return 'Conditions inconnues';
    }
  }

  static String weatherIcon(int code) {
    if (code == 0) return '☀️';
    if (code == 1) return '🌤️';
    if (code == 2) return '⛅';
    if (code == 3) return '☁️';
    if (code == 45 || code == 48) return '🌫️';
    if (code >= 51 && code <= 57) return '🌦️';
    if (code >= 61 && code <= 67) return '🌧️';
    if (code >= 71 && code <= 77) return '❄️';
    if (code >= 80 && code <= 86) return '🌦️';
    if (code >= 95) return '⛈️';
    return '🌤️';
  }

  factory Weather.fromJson(
    Map<String, dynamic> json, {
    required String cityName,
  }) {
    final current = _map(json['current']);
    final hourly = _parseHourly(_map(json['hourly']));
    final daily = _parseDaily(_map(json['daily']));

    return Weather(
      cityName: cityName,
      temperature: _number(current['temperature_2m']),
      feelsLike: _number(current['apparent_temperature']),
      humidity: _number(current['relative_humidity_2m']).round(),
      windSpeed: _number(current['wind_speed_10m']),
      windDirection: _number(current['wind_direction_10m']).round(),
      pressure: _number(current['surface_pressure']),
      visibility: _number(current['visibility']),
      precipitation: _number(current['precipitation']),
      uvIndex: _number(current['uv_index']),
      weatherCode: _number(current['weather_code']).round(),
      time: DateTime.parse(current['time'].toString()),
      hourly: hourly,
      daily: daily,
    );
  }

  static List<HourlyWeather> _parseHourly(Map<String, dynamic> data) {
    final times = _strings(data['time']);
    final temperatures = _numbers(data['temperature_2m']);
    final codes = _numbers(data['weather_code']);
    final rain = _numbers(data['precipitation_probability']);
    final wind = _numbers(data['wind_speed_10m']);

    return [
      for (var i = 0; i < times.length; i++)
        HourlyWeather(
          time: DateTime.parse(times[i]),
          temperature: _at(temperatures, i),
          weatherCode: _at(codes, i).round(),
          precipitationProbability: _at(rain, i).round(),
          windSpeed: _at(wind, i),
        ),
    ];
  }

  static List<DailyWeather> _parseDaily(Map<String, dynamic> data) {
    final dates = _strings(data['time']);
    final codes = _numbers(data['weather_code']);
    final min = _numbers(data['temperature_2m_min']);
    final max = _numbers(data['temperature_2m_max']);
    final rain = _numbers(data['precipitation_sum']);
    final uv = _numbers(data['uv_index_max']);
    final sunrises = _strings(data['sunrise']);
    final sunsets = _strings(data['sunset']);

    return [
      for (var i = 0; i < dates.length; i++)
        DailyWeather(
          date: DateTime.parse(dates[i]),
          weatherCode: _at(codes, i).round(),
          minTemperature: _at(min, i),
          maxTemperature: _at(max, i),
          precipitation: _at(rain, i),
          uvIndex: _at(uv, i),
          sunrise: DateTime.parse(_atString(sunrises, i)),
          sunset: DateTime.parse(_atString(sunsets, i)),
        ),
    ];
  }

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map) return value.cast<String, dynamic>();
    return {};
  }

  static List<num> _numbers(dynamic value) {
    if (value is List) return value.whereType<num>().toList();
    return const [];
  }

  static List<String> _strings(dynamic value) {
    if (value is List) return value.map((item) => item.toString()).toList();
    return const [];
  }

  static double _number(dynamic value) =>
      value is num ? value.toDouble() : 0;

  static double _at(List<num> values, int index) =>
      index < values.length ? values[index].toDouble() : 0;

  static String _atString(List<String> values, int index) =>
      index < values.length ? values[index] : '1970-01-01T00:00';
}
