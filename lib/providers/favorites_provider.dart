import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/city.dart';

class FavoritesNotifier extends Notifier<List<City>> {
  static const _key = 'favorites';

  @override
  List<City> build() {
    _restore();
    return const [];
  }

  Future<void> _restore() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const <String>[];

    try {
      final cities = raw
          .map((item) => City.fromJson(jsonDecode(item) as Map<String, dynamic>))
          .toList();
      state = cities;
    } catch (_) {
      state = const [];
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      state.map((city) => jsonEncode(city.toJson())).toList(),
    );
  }

  bool isFavorite(City city) => state.contains(city);

  Future<void> toggleFavorite(City city) async {
    if (isFavorite(city)) {
      state = state.where((item) => item != city).toList();
    } else {
      state = [...state, city];
    }
    await _persist();
  }

  Future<void> removeFavorite(City city) async {
    state = state.where((item) => item != city).toList();
    await _persist();
  }

  Future<void> clearAll() async {
    state = const [];
    await _persist();
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<City>>(FavoritesNotifier.new);
