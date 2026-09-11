class City {
  final String name;
  final double latitude;
  final double longitude;
  final String country;
  final String? admin1;

  const City({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.country,
    this.admin1,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: (json['name'] ?? '').toString(),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: (json['country'] ?? '').toString(),
      admin1: json['admin1']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'admin1': admin1,
      };

  String get subtitle {
    if (admin1 != null && admin1!.isNotEmpty && admin1 != country) {
      return '$admin1, $country';
    }
    return country;
  }

  @override
  bool operator ==(Object other) =>
      other is City &&
      name == other.name &&
      latitude == other.latitude &&
      longitude == other.longitude;

  @override
  int get hashCode => Object.hash(name, latitude, longitude);
}
