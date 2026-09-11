import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

final locationServiceProvider = Provider<LocationService>(
  (ref) => LocationService(),
);

final currentLocationProvider = FutureProvider.autoDispose<Position>((ref) {
  final service = ref.watch(locationServiceProvider);
  return service.getCurrentPosition();
});
