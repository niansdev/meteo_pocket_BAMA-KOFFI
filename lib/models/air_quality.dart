class AirQuality {
  final double pm10;
  final double pm2_5;
  final double europeanAqi;
  final double usAqi;
  final DateTime time;

  const AirQuality({
    required this.pm10,
    required this.pm2_5,
    required this.europeanAqi,
    required this.usAqi,
    required this.time,
  });

  String get label {
    if (europeanAqi <= 20) return 'Très bonne';
    if (europeanAqi <= 40) return 'Bonne';
    if (europeanAqi <= 60) return 'Moyenne';
    if (europeanAqi <= 80) return 'Médiocre';
    if (europeanAqi <= 100) return 'Mauvaise';
    return 'Très mauvaise';
  }

  String get advice {
    if (europeanAqi <= 40) return 'Qualité de l’air favorable aux activités extérieures.';
    if (europeanAqi <= 60) return 'Les personnes sensibles peuvent réduire les efforts prolongés.';
    return 'Privilégiez la prudence lors des activités extérieures prolongées.';
  }

  factory AirQuality.fromJson(Map<String, dynamic> json) {
    final current = (json['current'] as Map?)?.cast<String, dynamic>() ?? {};
    return AirQuality(
      pm10: (current['pm10'] as num? ?? 0).toDouble(),
      pm2_5: (current['pm2_5'] as num? ?? 0).toDouble(),
      europeanAqi: (current['european_aqi'] as num? ?? 0).toDouble(),
      usAqi: (current['us_aqi'] as num? ?? 0).toDouble(),
      time: DateTime.tryParse(current['time']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
