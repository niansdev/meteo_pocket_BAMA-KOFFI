import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_colors.dart';
import '../models/city.dart';
import '../providers/city_provider.dart';
import '../providers/favorites_provider.dart';
import '../providers/location_provider.dart';
import '../providers/theme_provider.dart';
import '../services/city_images.dart';
import 'favorites_screen.dart';
import 'settings_screen.dart';
import 'weather_detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  Timer? _searchTimer;

  String _query = '';

  bool _showAllPopularCities = false;

  late final List<City> _displayedPopularCities;

  // Cache utilisé pour conserver les quatre favoris tirés au hasard
  // pendant les rebuilds de l'écran.
  List<City> _randomFavorites = [];
  String _favoritesSignature = '';

  final List<City> _popularCities = const [
    // Côte d'Ivoire
    City(
      name: 'Abidjan',
      latitude: 5.36,
      longitude: -4.01,
      country: "Côte d'Ivoire",
    ),
    City(
      name: 'Bouaké',
      latitude: 7.69,
      longitude: -5.03,
      country: "Côte d'Ivoire",
    ),
    City(
      name: 'Yamoussoukro',
      latitude: 6.83,
      longitude: -5.29,
      country: "Côte d'Ivoire",
    ),

    // Afrique
    City(name: 'Accra', latitude: 5.56, longitude: -0.20, country: 'Ghana'),
    City(
      name: 'Addis-Abeba',
      latitude: 9.03,
      longitude: 38.74,
      country: 'Éthiopie',
    ),
    City(
      name: 'Casablanca',
      latitude: 33.57,
      longitude: -7.59,
      country: 'Maroc',
    ),
    City(name: 'Dakar', latitude: 14.72, longitude: -17.47, country: 'Sénégal'),
    City(
      name: 'Johannesburg',
      latitude: -26.20,
      longitude: 28.05,
      country: 'Afrique du Sud',
    ),
    City(
      name: 'Le Caire',
      latitude: 30.04,
      longitude: 31.24,
      country: 'Égypte',
    ),
    City(name: 'Lagos', latitude: 6.52, longitude: 3.38, country: 'Nigeria'),
    City(
      name: 'Marrakech',
      latitude: 31.63,
      longitude: -8.00,
      country: 'Maroc',
    ),
    City(name: 'Nairobi', latitude: -1.29, longitude: 36.82, country: 'Kenya'),
    City(name: 'Tunis', latitude: 36.81, longitude: 10.18, country: 'Tunisie'),
    City(
      name: 'Cape Town',
      latitude: -33.92,
      longitude: 18.42,
      country: 'Afrique du Sud',
    ),

    // Europe
    City(
      name: 'Amsterdam',
      latitude: 52.37,
      longitude: 4.90,
      country: 'Pays-Bas',
    ),
    City(name: 'Athènes', latitude: 37.98, longitude: 23.73, country: 'Grèce'),
    City(
      name: 'Barcelone',
      latitude: 41.39,
      longitude: 2.17,
      country: 'Espagne',
    ),
    City(
      name: 'Berlin',
      latitude: 52.52,
      longitude: 13.40,
      country: 'Allemagne',
    ),
    City(
      name: 'Bruxelles',
      latitude: 50.85,
      longitude: 4.35,
      country: 'Belgique',
    ),
    City(
      name: 'Copenhague',
      latitude: 55.68,
      longitude: 12.57,
      country: 'Danemark',
    ),
    City(name: 'Dublin', latitude: 53.35, longitude: -6.26, country: 'Irlande'),
    City(
      name: 'Lisbonne',
      latitude: 38.72,
      longitude: -9.14,
      country: 'Portugal',
    ),
    City(
      name: 'Londres',
      latitude: 51.51,
      longitude: -0.13,
      country: 'Royaume-Uni',
    ),
    City(name: 'Madrid', latitude: 40.42, longitude: -3.70, country: 'Espagne'),
    City(name: 'Milan', latitude: 45.46, longitude: 9.19, country: 'Italie'),
    City(name: 'Moscou', latitude: 55.76, longitude: 37.62, country: 'Russie'),
    City(
      name: 'Munich',
      latitude: 48.14,
      longitude: 11.58,
      country: 'Allemagne',
    ),
    City(name: 'Oslo', latitude: 59.91, longitude: 10.75, country: 'Norvège'),
    City(name: 'Paris', latitude: 48.86, longitude: 2.35, country: 'France'),
    City(
      name: 'Prague',
      latitude: 50.08,
      longitude: 14.44,
      country: 'République tchèque',
    ),
    City(name: 'Rome', latitude: 41.90, longitude: 12.50, country: 'Italie'),
    City(
      name: 'Stockholm',
      latitude: 59.33,
      longitude: 18.07,
      country: 'Suède',
    ),
    City(
      name: 'Vienne',
      latitude: 48.21,
      longitude: 16.37,
      country: 'Autriche',
    ),
    City(name: 'Zurich', latitude: 47.38, longitude: 8.54, country: 'Suisse'),

    // Asie
    City(
      name: 'Bangkok',
      latitude: 13.76,
      longitude: 100.50,
      country: 'Thaïlande',
    ),
    City(name: 'Hanoï', latitude: 21.03, longitude: 105.85, country: 'Vietnam'),
    City(
      name: 'Hong Kong',
      latitude: 22.32,
      longitude: 114.17,
      country: 'Hong Kong',
    ),
    City(
      name: 'Jakarta',
      latitude: -6.21,
      longitude: 106.85,
      country: 'Indonésie',
    ),
    City(
      name: 'Kuala Lumpur',
      latitude: 3.14,
      longitude: 101.69,
      country: 'Malaisie',
    ),
    City(
      name: 'Manille',
      latitude: 14.60,
      longitude: 120.98,
      country: 'Philippines',
    ),
    City(name: 'Mumbai', latitude: 19.08, longitude: 72.88, country: 'Inde'),
    City(name: 'New Delhi', latitude: 28.61, longitude: 77.21, country: 'Inde'),
    City(name: 'Osaka', latitude: 34.69, longitude: 135.50, country: 'Japon'),
    City(
      name: 'Séoul',
      latitude: 37.57,
      longitude: 126.98,
      country: 'Corée du Sud',
    ),
    City(
      name: 'Shanghai',
      latitude: 31.23,
      longitude: 121.47,
      country: 'Chine',
    ),
    City(
      name: 'Singapour',
      latitude: 1.35,
      longitude: 103.82,
      country: 'Singapour',
    ),
    City(name: 'Taipei', latitude: 25.03, longitude: 121.57, country: 'Taïwan'),
    City(name: 'Tokyo', latitude: 35.68, longitude: 139.69, country: 'Japon'),

    // Moyen-Orient
    City(
      name: 'Abou Dabi',
      latitude: 24.45,
      longitude: 54.38,
      country: 'Émirats arabes unis',
    ),
    City(name: 'Amman', latitude: 31.95, longitude: 35.93, country: 'Jordanie'),
    City(name: 'Bagdad', latitude: 33.31, longitude: 44.37, country: 'Irak'),
    City(name: 'Doha', latitude: 25.29, longitude: 51.53, country: 'Qatar'),
    City(
      name: 'Dubaï',
      latitude: 25.20,
      longitude: 55.27,
      country: 'Émirats arabes unis',
    ),
    City(
      name: 'Jérusalem',
      latitude: 31.77,
      longitude: 35.21,
      country: 'Israël',
    ),
    City(
      name: 'La Mecque',
      latitude: 21.42,
      longitude: 39.83,
      country: 'Arabie saoudite',
    ),
    City(
      name: 'Médine',
      latitude: 24.47,
      longitude: 39.61,
      country: 'Arabie saoudite',
    ),
    City(
      name: 'Riyad',
      latitude: 24.71,
      longitude: 46.68,
      country: 'Arabie saoudite',
    ),

    // Amérique du Nord
    City(
      name: 'Atlanta',
      latitude: 33.75,
      longitude: -84.39,
      country: 'États-Unis',
    ),
    City(
      name: 'Boston',
      latitude: 42.36,
      longitude: -71.06,
      country: 'États-Unis',
    ),
    City(
      name: 'Chicago',
      latitude: 41.88,
      longitude: -87.63,
      country: 'États-Unis',
    ),
    City(
      name: 'Las Vegas',
      latitude: 36.17,
      longitude: -115.14,
      country: 'États-Unis',
    ),
    City(
      name: 'Los Angeles',
      latitude: 34.05,
      longitude: -118.24,
      country: 'États-Unis',
    ),
    City(
      name: 'Miami',
      latitude: 25.76,
      longitude: -80.19,
      country: 'États-Unis',
    ),
    City(
      name: 'Montréal',
      latitude: 45.50,
      longitude: -73.57,
      country: 'Canada',
    ),
    City(
      name: 'New York',
      latitude: 40.71,
      longitude: -74.01,
      country: 'États-Unis',
    ),
    City(
      name: 'San Francisco',
      latitude: 37.77,
      longitude: -122.42,
      country: 'États-Unis',
    ),
    City(
      name: 'Toronto',
      latitude: 43.65,
      longitude: -79.38,
      country: 'Canada',
    ),
    City(
      name: 'Vancouver',
      latitude: 49.28,
      longitude: -123.12,
      country: 'Canada',
    ),
    City(
      name: 'Washington',
      latitude: 38.91,
      longitude: -77.04,
      country: 'États-Unis',
    ),

    // Amérique du Sud
    City(
      name: 'Buenos Aires',
      latitude: -34.60,
      longitude: -58.38,
      country: 'Argentine',
    ),
    City(name: 'Lima', latitude: -12.05, longitude: -77.04, country: 'Pérou'),
    City(
      name: 'Medellín',
      latitude: 6.25,
      longitude: -75.56,
      country: 'Colombie',
    ),
    City(
      name: 'Rio de Janeiro',
      latitude: -22.91,
      longitude: -43.17,
      country: 'Brésil',
    ),
    City(
      name: 'Santiago',
      latitude: -33.45,
      longitude: -70.67,
      country: 'Chili',
    ),
    City(
      name: 'São Paulo',
      latitude: -23.55,
      longitude: -46.63,
      country: 'Brésil',
    ),

    // Océanie
    City(
      name: 'Auckland',
      latitude: -36.85,
      longitude: 174.76,
      country: 'Nouvelle-Zélande',
    ),
    City(
      name: 'Melbourne',
      latitude: -37.81,
      longitude: 144.96,
      country: 'Australie',
    ),
    City(
      name: 'Sydney',
      latitude: -33.87,
      longitude: 151.21,
      country: 'Australie',
    ),
  ];

  @override
  void initState() {
    super.initState();

    _displayedPopularCities = [..._popularCities]..shuffle(Random());
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _searchTimer?.cancel();

    _searchTimer = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) {
        return;
      }

      setState(() {
        _query = value.trim();
      });
    });
  }

  void _openWeather(City city) {
    FocusManager.instance.primaryFocus?.unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WeatherDetailScreen(city: city)),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  void _openFavorites() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const FavoritesScreen()),
    );
  }

  Future<void> _openCurrentLocation() async {
    try {
      final position = await ref.read(currentLocationProvider.future);

      if (!mounted) {
        return;
      }

      final city = City(
        name: 'Ma position',
        latitude: position.latitude,
        longitude: position.longitude,
        country: 'Position actuelle',
      );

      _openWeather(city);
    } catch (error) {
      if (!mounted) {
        return;
      }

      final message = error.toString().replaceFirst('Exception: ', '');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
    }
  }

  List<City> _getDisplayedFavorites(List<City> favorites) {
    final signature = favorites
        .map((city) => '${city.name}|${city.latitude}|${city.longitude}')
        .join('||');

    // Le tirage est recalculé uniquement lorsque la liste des favoris
    // change. Ainsi, les cartes ne changent pas à chaque rebuild.
    if (signature != _favoritesSignature) {
      _favoritesSignature = signature;

      _randomFavorites = [...favorites]..shuffle(Random());

      if (_randomFavorites.length > 4) {
        _randomFavorites = _randomFavorites.take(4).toList();
      }
    }

    return _randomFavorites;
  }

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

    final searchResults = _query.length >= 2
        ? ref.watch(citySearchProvider(_query))
        : null;

    final visiblePopularCities = _showAllPopularCities
        ? _displayedPopularCities
        : _displayedPopularCities.take(4).toList();

    final visibleFavorites = _getDisplayedFavorites(favorites);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _buildHeader(favorites.length),
            ),
            const SizedBox(height: 18),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearch(),
            ),
            const SizedBox(height: 4),
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  if (_query.length >= 2)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                      sliver: SliverToBoxAdapter(
                        child: _buildSearchResults(searchResults!),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: _sectionTitleWithAction(
                          title: 'Villes populaires',
                          subtitle: 'Quelques destinations pour commencer',
                          icon: Icons.public_rounded,
                          buttonText: _showAllPopularCities
                              ? 'Voir moins'
                              : 'Voir plus',
                          onPressed: () {
                            setState(() {
                              _showAllPopularCities = !_showAllPopularCities;
                            });
                          },
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _cityCard(visiblePopularCities[index]);
                        }, childCount: visiblePopularCities.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.18,
                            ),
                      ),
                    ),
                    if (favorites.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: _sectionTitleWithAction(
                            title: 'Vos favoris',
                            subtitle: _favoriteSubtitle(favorites.length),
                            icon: Icons.favorite_rounded,
                            buttonText: 'Voir tout',
                            onPressed: _openFavorites,
                          ),
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: visibleFavorites
                                .map(_favoritePreview)
                                .toList(),
                          ),
                        ),
                      ),
                    ] else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 30),
                        sliver: SliverToBoxAdapter(
                          child: _emptyFavoritesHint(),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _favoriteSubtitle(int count) {
    if (count == 1) {
      return '1 ville enregistrée';
    }

    return '$count villes enregistrées';
  }

  Widget _buildHeader(int favoriteCount) {
    final hour = DateTime.now().hour;

    final greeting = hour < 12
        ? 'Bonjour 👋'
        : hour < 18
        ? 'Bon après-midi ☀️'
        : 'Bonsoir 🌙';

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Météo Pocket',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.navy,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'La météo de vos villes, simplement.',
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _headerAction(
              icon: Icons.my_location_rounded,
              color: AppColors.orange,
              tooltip: 'Ma position',
              onTap: _openCurrentLocation,
            ),
            const SizedBox(width: 7),
            Consumer(
              builder: (context, ref, child) {
                final isDarkMode = ref.watch(themeProvider) == ThemeMode.dark;

                return _headerAction(
                  icon: isDarkMode
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: isDark ? Colors.white70 : AppColors.navy,
                  tooltip: isDarkMode ? 'Mode clair' : 'Mode sombre',
                  onTap: () {
                    ref.read(themeProvider.notifier).toggle();
                  },
                );
              },
            ),
            const SizedBox(width: 7),
            _headerAction(
              icon: Icons.settings_outlined,
              color: isDark ? Colors.white70 : AppColors.navy,
              tooltip: 'Paramètres',
              onTap: _openSettings,
            ),
            const SizedBox(width: 7),
            _favoriteButton(favoriteCount),
          ],
        ),
      ],
    );
  }

  Widget _headerAction({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(13),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, color: color, size: 21),
          ),
        ),
      ),
    );
  }

  Widget _favoriteButton(int favoriteCount) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Tooltip(
      message: 'Favoris',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _openFavorites,
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.07)
                      : AppColors.green.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  favoriteCount > 0
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: favoriteCount > 0
                      ? AppColors.orange
                      : isDark
                      ? Colors.white70
                      : AppColors.green,
                  size: 21,
                ),
              ),
              if (favoriteCount > 0)
                Positioned(
                  top: -3,
                  right: -3,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 17,
                      minHeight: 17,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: const BoxDecoration(
                      color: AppColors.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$favoriteCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearch() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : const Color(0xFFF3F5F7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.06)
              : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: 'Rechercher une ville…',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: theme.colorScheme.onSurfaceVariant,
            size: 22,
          ),
          suffixIcon: _query.isNotEmpty
              ? IconButton(
                  tooltip: 'Effacer',
                  onPressed: _clearSearch,
                  icon: Icon(
                    Icons.close_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 19,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  void _clearSearch() {
    _searchTimer?.cancel();
    _searchController.clear();

    setState(() {
      _query = '';
    });
  }

  Widget _buildSearchResults(AsyncValue<List<City>> result) {
    return result.when(
      loading: () => const _SearchLoading(),
      error: (error, stackTrace) {
        return _SearchMessage(
          icon: Icons.cloud_off_outlined,
          message: error.toString().replaceFirst('Exception: ', ''),
        );
      },
      data: (cities) {
        if (cities.isEmpty) {
          return const _SearchMessage(
            icon: Icons.location_off_outlined,
            message: 'Aucune ville trouvée.\nEssayez un autre nom.',
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Résultats de recherche',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            ...cities.map(_searchCityCard),
          ],
        );
      },
    );
  }

  Widget _searchCityCard(City city) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<String?>(
      future: CityImages.getImageUrl(city),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;

        return Container(
          height: 145,
          margin: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => _openWeather(city),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(
                    imageUrl: imageUrl,
                    isDark: isDark,
                    fallback: _searchFallbackBackground(isDark),
                  ),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x15000000), Color(0xD9000000)],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 14,
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.28),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.location_on_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 25,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: 14,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          city.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          city.country,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      imageUrl == null)
                    const Positioned.fill(
                      child: IgnorePointer(
                        child: Center(
                          child: SizedBox(
                            width: 26,
                            height: 26,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImage({
    required String? imageUrl,
    required bool isDark,
    required Widget fallback,
  }) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return fallback;
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.high,
      loadingBuilder: (context, child, progress) {
        if (progress == null) {
          return child;
        }

        return fallback;
      },
      errorBuilder: (context, error, stackTrace) {
        return fallback;
      },
    );
  }

  Widget _searchFallbackBackground(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF18232F) : const Color(0xFFE9EEF1),
      child: Center(
        child: Icon(
          Icons.location_city_outlined,
          size: 48,
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : AppColors.navy.withValues(alpha: 0.12),
        ),
      ),
    );
  }

  Widget _cityCard(City city) {
    final favorites = ref.watch(favoritesProvider);
    final isFavorite = favorites.contains(city);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<String?>(
      future: CityImages.getImageUrl(city),
      builder: (context, snapshot) {
        final imageUrl = snapshot.data;

        return Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => _openWeather(city),
            child: Stack(
              fit: StackFit.expand,
              children: [
                _buildImage(
                  imageUrl: imageUrl,
                  isDark: isDark,
                  fallback: _cityFallbackBackground(isDark),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: [0.35, 1.0],
                      colors: [Colors.transparent, Color(0xCC000000)],
                    ),
                  ),
                ),
                Positioned(
                  top: 11,
                  right: 11,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.28),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFavorite ? AppColors.orange : Colors.white,
                      size: 18,
                    ),
                  ),
                ),
                Positioned(
                  left: 13,
                  right: 13,
                  bottom: 12,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        city.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        city.country,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (snapshot.connectionState == ConnectionState.waiting &&
                    imageUrl == null)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Center(
                        child: Container(
                          width: 28,
                          height: 28,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.30),
                            shape: BoxShape.circle,
                          ),
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _cityFallbackBackground(bool isDark) {
    return Container(
      color: isDark ? const Color(0xFF18232F) : const Color(0xFFE9EEF1),
      child: Center(
        child: Icon(
          Icons.location_city_outlined,
          size: 45,
          color: isDark
              ? Colors.white.withValues(alpha: 0.18)
              : AppColors.navy.withValues(alpha: 0.12),
        ),
      ),
    );
  }

  Widget _favoritePreview(City city) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.45)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 13, vertical: 2),
        onTap: () => _openWeather(city),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: AppColors.orange,
            size: 20,
          ),
        ),
        title: Text(
          city.name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        subtitle: Text(city.country, style: const TextStyle(fontSize: 12)),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }

  Widget _emptyFavoritesHint() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.green.withValues(alpha: isDark ? 0.08 : 0.055),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.favorite_border_rounded,
            color: AppColors.green,
            size: 25,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aucune ville favorite',
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF7BE3AD)
                        : const Color(0xFF176B4A),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ajoutez vos villes préférées depuis leur '
                  'page météo pour les retrouver rapidement ici.',
                  style: TextStyle(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitleWithAction({
    required String title,
    required String subtitle,
    required IconData icon,
    required String buttonText,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.orange.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Icon(icon, color: AppColors.orange, size: 20),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.navy,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 11.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              color: AppColors.orange,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SearchLoading extends StatelessWidget {
  const _SearchLoading();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2.2),
          ),
          SizedBox(width: 13),
          Text(
            'Recherche en cours…',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _SearchMessage extends StatelessWidget {
  final IconData icon;
  final String message;

  const _SearchMessage({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 30),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 36,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.45),
          ),
          const SizedBox(height: 11),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
