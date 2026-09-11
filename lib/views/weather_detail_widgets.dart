import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../core/app_colors.dart';
import '../models/city.dart';
import '../models/weather.dart';
import '../providers/air_quality_provider.dart';
import '../services/city_images.dart';

class HeroCity extends StatelessWidget {
  final City city;
  final Weather weather;

  const HeroCity({super.key, required this.city, required this.weather});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: CityImages.getImageUrl(city),
      builder: (context, snapshot) {
        final url = snapshot.data;

        return Container(
          height: 200,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (url != null)
                Image.network(
                  url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _fallback();
                  },
                )
              else
                _fallback(),

              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xCC000000)],
                  ),
                ),
              ),

              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: Colors.white,
                      size: 22,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        '${city.name}, ${city.country}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _fallback() {
    return Container(
      color: AppColors.navy,
      alignment: Alignment.center,
      child: Text(weather.icon, style: const TextStyle(fontSize: 64)),
    );
  }
}

class CurrentWeather extends StatelessWidget {
  final Weather weather;

  const CurrentWeather({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .08)
              : Colors.black.withValues(alpha: .06),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(
                Icons.calendar_today_outlined,
                color: AppColors.orange,
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  DateFormat('EEEE d MMMM', 'fr_FR').format(weather.time),
                  style: TextStyle(
                    color: theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                DateFormat('HH:mm').format(weather.time),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(weather.icon, style: const TextStyle(fontSize: 55)),
              const SizedBox(width: 12),
              Text(
                '${weather.temperature.round()}°',
                style: TextStyle(
                  color: isDark ? const Color(0xFFF5F7FA) : AppColors.navy,
                  fontSize: 54,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            weather.description,
            style: TextStyle(
              color: isDark ? const Color(0xFFF5F7FA) : AppColors.navy,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            'Ressenti ${weather.feelsLike.round()}°C',
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: MiniStat(
                  icon: Icons.water_drop_outlined,
                  label: 'Humidité',
                  value: '${weather.humidity}%',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  icon: Icons.air_outlined,
                  label: 'Vent',
                  value: '${weather.windSpeed.round()} km/h',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: MiniStat(
                  icon: Icons.umbrella_outlined,
                  label: 'Pluie',
                  value: '${weather.precipitation.toStringAsFixed(1)} mm',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const MiniStat({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: .45),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Column(
        children: [
          const SizedBox(height: 1),
          Icon(icon, color: AppColors.green, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherAlert extends StatelessWidget {
  final Weather weather;

  const WeatherAlert({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final severe =
        weather.weatherCode >= 95 ||
        weather.windSpeed >= 55 ||
        weather.uvIndex >= 8;

    if (!severe) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.green.withValues(alpha: .07),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            Icon(
              Icons.check_circle_outline_rounded,
              color: AppColors.green,
              size: 21,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Aucune alerte météo majeure détectée actuellement.',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ),
          ],
        ),
      );
    }

    final text = weather.weatherCode >= 95
        ? 'Risque d’orage : restez prudent et limitez '
              'les activités exposées.'
        : weather.windSpeed >= 55
        ? 'Vent fort : soyez prudent lors des déplacements.'
        : 'Indice UV élevé : protégez-vous du soleil.';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: .08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_outlined, color: Colors.red, size: 21),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class AirQualityCard extends ConsumerWidget {
  final City city;

  const AirQualityCard({super.key, required this.city});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(airQualityProvider(city));

    return async.when(
      loading: () => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Analyse de la qualité de l’air…'),
          ],
        ),
      ),
      error: (error, stackTrace) => const SizedBox.shrink(),
      data: (aq) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .08)
                  : Colors.black.withValues(alpha: .06),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.air_outlined, color: AppColors.green),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Qualité de l’air',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    aq.label,
                    style: const TextStyle(
                      color: AppColors.green,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  Expanded(
                    child: AirMetric(
                      label: 'AQI Europe',
                      value: aq.europeanAqi.toStringAsFixed(0),
                    ),
                  ),
                  Expanded(
                    child: AirMetric(
                      label: 'PM2.5',
                      value: '${aq.pm2_5.toStringAsFixed(1)} µg/m³',
                    ),
                  ),
                  Expanded(
                    child: AirMetric(
                      label: 'PM10',
                      value: '${aq.pm10.toStringAsFixed(1)} µg/m³',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 11),

              Text(
                aq.advice,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AirMetric extends StatelessWidget {
  final String label;
  final String value;

  const AirMetric({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class TemperatureChart extends StatelessWidget {
  final Weather weather;

  const TemperatureChart({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final points = weather.hourly.take(12).toList();

    if (points.length < 2) {
      return const SizedBox.shrink();
    }

    final min = points
        .map((e) => e.temperature)
        .reduce((a, b) => a < b ? a : b);

    final max = points
        .map((e) => e.temperature)
        .reduce((a, b) => a > b ? a : b);

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .08)
              : Colors.black.withValues(alpha: .06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.show_chart_rounded,
                color: AppColors.orange,
                size: 21,
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Évolution de la température',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                '${min.round()}° — ${max.round()}°',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: TemperaturePainter(
                points.map((e) => e.temperature).toList(),
                theme.colorScheme.primary,
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: points
                .map(
                  (e) => Text(
                    DateFormat('HH').format(e.time),
                    style: TextStyle(
                      fontSize: 9,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class TemperaturePainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;

  TemperaturePainter(this.values, this.lineColor);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) {
      return;
    }

    final min = values.reduce((a, b) => a < b ? a : b);

    final max = values.reduce((a, b) => a > b ? a : b);

    final range = (max - min).abs() < 0.1 ? 1.0 : max - min;

    final path = Path();
    final fill = Path();

    Offset point(int i) {
      final x = i * size.width / (values.length - 1);

      final y =
          size.height - 20 - ((values[i] - min) / range) * (size.height - 45);

      return Offset(x, y);
    }

    for (var i = 0; i < values.length; i++) {
      final p = point(i);

      if (i == 0) {
        path.moveTo(p.dx, p.dy);

        fill.moveTo(p.dx, size.height);

        fill.lineTo(p.dx, p.dy);
      } else {
        final previous = point(i - 1);
        final midX = (previous.dx + p.dx) / 2;

        path.cubicTo(midX, previous.dy, midX, p.dy, p.dx, p.dy);

        fill.cubicTo(midX, previous.dy, midX, p.dy, p.dx, p.dy);
      }
    }

    fill.lineTo(size.width, size.height);
    fill.close();

    final gridPaint = Paint()
      ..color = lineColor.withValues(alpha: .08)
      ..strokeWidth = 1;

    for (var i = 1; i < 4; i++) {
      final y = i * size.height / 4;

      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    canvas.drawPath(fill, Paint()..color = lineColor.withValues(alpha: .08));

    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );

    final dotPaint = Paint()..color = lineColor;

    for (var i = 0; i < values.length; i++) {
      canvas.drawCircle(point(i), i == 0 ? 4 : 2.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant TemperaturePainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.lineColor != lineColor;
  }
}

class HourlyList extends StatelessWidget {
  final Weather weather;

  const HourlyList({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather.hourly.isEmpty) {
      return const EmptyCard(message: 'Prévisions horaires indisponibles.');
    }

    return SizedBox(
      height: 137,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: weather.hourly.length,
        separatorBuilder: (context, index) => const SizedBox(width: 9),
        itemBuilder: (context, index) {
          final item = weather.hourly[index];

          final isNow = index == 0;

          final theme = Theme.of(context);

          return Container(
            width: 88,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            decoration: BoxDecoration(
              color: isNow ? AppColors.navy : theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isNow
                    ? AppColors.navy
                    : (theme.brightness == Brightness.dark
                          ? Colors.white.withValues(alpha: .08)
                          : Colors.black.withValues(alpha: .06)),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isNow ? 'Maintenant' : DateFormat('HH:mm').format(item.time),
                  style: TextStyle(
                    color: isNow
                        ? Colors.white70
                        : theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 7),

                Text(
                  Weather.weatherIcon(item.weatherCode),
                  style: const TextStyle(fontSize: 26),
                ),

                const SizedBox(height: 5),

                Text(
                  '${item.temperature.round()}°',
                  style: TextStyle(
                    color: isNow ? Colors.white : theme.colorScheme.onSurface,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  '${item.precipitationProbability}% pluie',
                  style: TextStyle(
                    color: isNow
                        ? Colors.white70
                        : theme.colorScheme.onSurfaceVariant,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DailyList extends StatelessWidget {
  final Weather weather;

  const DailyList({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    if (weather.daily.isEmpty) {
      return const EmptyCard(message: 'Prévisions quotidiennes indisponibles.');
    }

    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .08)
              : Colors.black.withValues(alpha: .06),
        ),
      ),
      child: Column(
        children: weather.daily.asMap().entries.map((entry) {
          final index = entry.key;
          final day = entry.value;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 11,
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 76,
                      child: Text(
                        index == 0
                            ? "Aujourd'hui"
                            : DateFormat('EEE d', 'fr_FR').format(day.date),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),

                    Text(
                      Weather.weatherIcon(day.weatherCode),
                      style: const TextStyle(fontSize: 25),
                    ),

                    const SizedBox(width: 11),

                    Expanded(
                      child: Text(
                        Weather.weatherDescription(day.weatherCode),
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontSize: 11,
                        ),
                      ),
                    ),

                    Text(
                      '${day.maxTemperature.round()}°',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(width: 7),

                    Text(
                      '${day.minTemperature.round()}°',
                      style: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              if (index < weather.daily.length - 1)
                Divider(
                  height: 1,
                  indent: 14,
                  endIndent: 14,
                  color: isDark
                      ? Colors.white.withValues(alpha: .07)
                      : Colors.black.withValues(alpha: .06),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class DetailsGrid extends StatelessWidget {
  final Weather weather;

  const DetailsGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 9,
      mainAxisSpacing: 9,
      childAspectRatio: 1.7,
      children: [
        DetailCard(
          icon: Icons.air_outlined,
          title: 'Direction du vent',
          value:
              '${weather.windDirectionLabel} '
              '${weather.windDirection}°',
          accent: AppColors.green,
        ),
        DetailCard(
          icon: Icons.speed_outlined,
          title: 'Pression',
          value: '${weather.pressure.round()} hPa',
          accent: AppColors.navy,
        ),
        DetailCard(
          icon: Icons.visibility_outlined,
          title: 'Visibilité',
          value: '${(weather.visibility / 1000).toStringAsFixed(1)} km',
          accent: AppColors.orange,
        ),
        DetailCard(
          icon: Icons.wb_sunny_outlined,
          title: 'Indice UV',
          value: (today?.uvIndex ?? weather.uvIndex).toStringAsFixed(1),
          accent: const Color(0xFFE6A700),
        ),
        DetailCard(
          icon: Icons.wb_twilight_outlined,
          title: 'Lever du soleil',
          value: today == null
              ? '--:--'
              : DateFormat('HH:mm').format(today.sunrise),
          accent: AppColors.orange,
        ),
        DetailCard(
          icon: Icons.nights_stay_outlined,
          title: 'Coucher du soleil',
          value: today == null
              ? '--:--'
              : DateFormat('HH:mm').format(today.sunset),
          accent: AppColors.navy,
        ),
      ],
    );
  }
}

class DetailCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color accent;

  const DetailCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: .08)
              : Colors.black.withValues(alpha: .06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: .09),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 19),
          ),

          const SizedBox(width: 9),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isDark ? const Color(0xFFF5F7FA) : AppColors.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;

  const SectionTitle({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: .10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.orange, size: 19),
        ),

        const SizedBox(width: 9),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? const Color(0xFFF5F7FA) : AppColors.navy,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class UpdateBanner extends StatelessWidget {
  final Weather weather;

  const UpdateBanner({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: .07),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.cloud_done_outlined,
            color: AppColors.green,
            size: 21,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Données mises à jour à '
              '${DateFormat('HH:mm').format(weather.time)}. '
              'Tirez vers le bas pour actualiser.',
              style: TextStyle(
                color: isDark
                    ? const Color(0xFF6EE7A8)
                    : const Color(0xFF176B4A),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class LoadingState extends StatelessWidget {
  const LoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.orange),
          SizedBox(height: 15),
          Text(
            'Récupération des données météo…',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const ErrorState({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: .08)
                  : Colors.black.withValues(alpha: .06),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.orange.withValues(alpha: .10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  color: AppColors.orange,
                  size: 34,
                ),
              ),

              const SizedBox(height: 17),

              Text(
                'Oups, la météo est indisponible',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? const Color(0xFFF5F7FA) : AppColors.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                  fontSize: 12,
                ),
              ),

              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmptyCard extends StatelessWidget {
  final String message;

  const EmptyCard({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          fontSize: 12,
        ),
      ),
    );
  }
}
