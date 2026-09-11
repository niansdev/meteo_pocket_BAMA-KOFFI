import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/city.dart';
import '../models/weather.dart';
import '../services/weather_service.dart';

final weatherServiceProvider = Provider<WeatherService>(
  (ref) => WeatherService(),
);

final weatherProvider = FutureProvider.autoDispose.family<Weather, City>(
  (ref, city) {
    final service = ref.watch(weatherServiceProvider);
    return service.getWeather(city);
  },
);
