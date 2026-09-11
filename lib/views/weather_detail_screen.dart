import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    final weatherAsync = ref.watch(weatherProvider(city));
    final isFavorite = ref.watch(favoritesProvider).contains(city);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          city.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _FavoriteButton(
              isFavorite: isFavorite,
              onPressed: () => _toggleFavorite(context, ref, isFavorite),
            ),
          ),
        ],
      ),
      body: weatherAsync.when(
        loading: () => const LoadingState(),
        error: (error, _) => ErrorState(
          message: error.toString().replaceFirst('Exception: ', ''),
          onRetry: () {
            HapticFeedback.mediumImpact();
            ref.invalidate(weatherProvider(city));
          },
        ),
        data: (weather) {
          return RefreshIndicator(
            color: AppColors.orange,
            backgroundColor: theme.colorScheme.surface,
            strokeWidth: 2.5,
            onRefresh: () => _refreshWeather(context, ref),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
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
          );
        },
      ),
    );
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    bool isFavorite,
  ) async {
    HapticFeedback.lightImpact();

    await ref.read(favoritesProvider.notifier).toggleFavorite(city);

    if (!context.mounted) return;

    HapticFeedback.mediumImpact();

    final message = isFavorite
        ? '${city.name} retirée des favoris'
        : '${city.name} ajoutée aux favoris';

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(
                isFavorite
                    ? Icons.favorite_border_rounded
                    : Icons.favorite_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(child: Text(message)),
            ],
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Future<void> _refreshWeather(BuildContext context, WidgetRef ref) async {
    HapticFeedback.lightImpact();

    CityImages.clearCache();
    ref.invalidate(weatherProvider(city));

    try {
      await ref.read(weatherProvider(city).future);

      if (context.mounted) {
        HapticFeedback.mediumImpact();
      }
    } catch (_) {
      if (context.mounted) {
        HapticFeedback.heavyImpact();
      }
      rethrow;
    }
  }
}

class _FavoriteButton extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onPressed;

  const _FavoriteButton({required this.isFavorite, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: isFavorite ? 'Retirer des favoris' : 'Ajouter aux favoris',
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: onPressed,
          onLongPress: () {
            HapticFeedback.mediumImpact();
          },
          child: SizedBox(
            width: 44,
            height: 44,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 220),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Icon(
                  isFavorite
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  key: ValueKey(isFavorite),
                  color: isFavorite
                      ? AppColors.orange
                      : theme.colorScheme.onSurface,
                  size: 23,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
