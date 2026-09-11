import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/air_quality.dart';
import '../models/city.dart';
import '../services/air_quality_service.dart';

final airQualityServiceProvider = Provider<AirQualityService>(
  (ref) => AirQualityService(),
);

final airQualityProvider =
    FutureProvider.autoDispose.family<AirQuality, City>((ref, city) {
  final service = ref.watch(airQualityServiceProvider);
  return service.getAirQuality(city);
});
