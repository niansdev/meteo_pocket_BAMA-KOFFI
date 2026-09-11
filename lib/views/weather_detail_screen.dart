import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../models/city.dart';
import '../providers/favorites_provider.dart';
import '../providers/weather_provider.dart';
import '../services/city_images.dart';
import 'weather_detail_widgets.dart';

class WeatherDetailScreen extends ConsumerWidget {
  final City city;

  const WeatherDetailScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weatherProvider(city));
    final isFavorite = ref.watch(favoritesProvider).contains(city);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          city.name,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            tooltip: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
            onPressed: () async {
              await ref.read(favoritesProvider.notifier).toggleFavorite(city);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      isFavorite
                          ? '${city.name} retirée des favoris'
                          : '${city.name} ajoutée aux favoris',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: Icon(
              isFavorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              color: isFavorite
                  ? AppColors.orange
                  : Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorState(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () {
            ref.invalidate(weatherProvider(city));
          },
        ),
        data: (weather) => RefreshIndicator(
          color: AppColors.orange,
          onRefresh: () async {
            CityImages.clearCache();
            ref.invalidate(weatherProvider(city));
            await ref.read(weatherProvider(city).future);
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 32),
            children: [
              HeroCity(city: city, weather: weather),
              const SizedBox(height: 16),
              CurrentWeather(weather: weather),
              const SizedBox(height: 14),
              WeatherAlert(weather: weather),
              const SizedBox(height: 14),
              AirQualityCard(city: city),
              const SizedBox(height: 20),
              TemperatureChart(weather: weather),
              const SizedBox(height: 24),
              const SectionTitle(
                title: 'Prévisions horaires',
                subtitle: 'Les 12 prochaines heures',
                icon: Icons.schedule_outlined,
              ),
              const SizedBox(height: 10),
              HourlyList(weather: weather),
              const SizedBox(height: 24),
              const SectionTitle(
                title: 'Prévisions sur 7 jours',
                subtitle: 'Tendance météo quotidienne',
                icon: Icons.calendar_month_outlined,
              ),
              const SizedBox(height: 10),
              DailyList(weather: weather),
              const SizedBox(height: 24),
              const SectionTitle(
                title: 'Détails météo',
                subtitle: 'Informations complémentaires',
                icon: Icons.info_outline_rounded,
              ),
              const SizedBox(height: 10),
              DetailsGrid(weather: weather),
              const SizedBox(height: 20),
              UpdateBanner(weather: weather),
            ],
          ),
        ),
      ),
    );
  }
}

