import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/city.dart';
import '../services/geocoding_service.dart';

final geocodingServiceProvider = Provider<GeocodingService>(
  (ref) => GeocodingService(),
);

final citySearchProvider =
    FutureProvider.autoDispose.family<List<City>, String>((ref, query) {
  final service = ref.watch(geocodingServiceProvider);
  return service.searchCities(query);
});
