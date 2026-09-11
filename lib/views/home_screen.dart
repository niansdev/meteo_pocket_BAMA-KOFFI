import 'dart:async';

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
import 'weather_detail_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {

  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  String _query = '';

  final List<City> popularCities = const [
    City(
      name: 'Abidjan',
      latitude: 5.36,
      longitude: -4.01,
      country: "Côte d'Ivoire",
    ),
    City(
      name: 'Yamoussoukro',
      latitude: 6.83,
      longitude: -5.29,
      country: "Côte d'Ivoire",
    ),
    City(
      name: 'Bouaké',
      latitude: 7.69,
      longitude: -5.03,
      country: "Côte d'Ivoire",
    ),
    City(name: 'Dakar', latitude: 14.72, longitude: -17.47, country: 'Sénégal'),
    City(name: 'Paris', latitude: 48.86, longitude: 2.35, country: 'France'),
    City(
      name: 'New York',
      latitude: 40.71,
      longitude: -74.01,
      country: 'États-Unis',
    ),
    City(
      name: 'Londres',
      latitude: 51.51,
      longitude: -0.13,
      country: 'Royaume-Uni',
    ),
    City(name: 'Tokyo', latitude: 35.68, longitude: 139.69, country: 'Japon'),
  ];

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // RECHERCHE

  void _onSearchChanged(String value) {
    _debounce?.cancel();

    _debounce = Timer(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      setState(() {
        _query = value.trim();
      });
    });
  }

  // NAVIGATION

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

      final city = City(
        name: 'Ma position',
        latitude: position.latitude,
        longitude: position.longitude,
        country: 'Position actuelle',
      );

      if (mounted) {
        _openWeather(city);
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(error.toString().replaceFirst('Exception: ', '')),
        ),
      );
    }
  }

  // BUILD

  @override
  Widget build(BuildContext context) {
    final favorites = ref.watch(favoritesProvider);

    final searchAsync = _query.length >= 2
        ? ref.watch(citySearchProvider(_query))
        : null;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // HEADER FIXE

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
              child: _buildHeader(favorites.length),
            ),

            const SizedBox(height: 18),

            // RECHERCHE FIXE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildSearch(),
            ),

            const SizedBox(height: 4),

            // CONTENU SCROLLABLE
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  if (_query.length >= 2)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 30),
                      sliver: SliverToBoxAdapter(
                        child: _buildSearchResults(searchAsync!),
                      ),
                    )
                  else ...[
                    // VILLES POPULAIRES

                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
                      sliver: SliverToBoxAdapter(
                        child: _sectionTitle(
                          'Villes populaires',
                          'Quelques destinations pour commencer',
                          Icons.public_rounded,
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate((context, index) {
                          return _cityCard(popularCities[index]);
                        }, childCount: popularCities.length),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 1.18,
                            ),
                      ),
                    ),

                    // FAVORIS
                    if (favorites.isNotEmpty) ...[
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 12),
                        sliver: SliverToBoxAdapter(
                          child: _sectionTitle(
                            'Vos favoris',
                            '${favorites.length} ville'
                                '${favorites.length > 1 ? 's' : ''} '
                                'enregistrée'
                                '${favorites.length > 1 ? 's' : ''}',
                            Icons.favorite_rounded,
                          ),
                        ),
                      ),

                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
                        sliver: SliverToBoxAdapter(
                          child: Column(
                            children: favorites
                                .take(3)
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

  // HEADER

  Widget _buildHeader(int favoriteCount) {
    final hour = DateTime.now().hour;

    final greeting = hour < 12
        ? 'Bonjour 👋'
        : hour < 18
        ? 'Bon après-midi'
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
              builder: (context, ref, _) {
                final dark = ref.watch(themeProvider) == ThemeMode.dark;

                return _headerAction(
                  icon: dark
                      ? Icons.light_mode_rounded
                      : Icons.dark_mode_rounded,
                  color: isDark ? Colors.white70 : AppColors.navy,
                  tooltip: dark ? 'Mode clair' : 'Mode sombre',
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

  // ACTION HEADER

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

  // FAVORIS HEADER

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
                      : (isDark ? Colors.white70 : AppColors.green),
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

  // RECHERCHE

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
                  onPressed: () {
                    _searchController.clear();

                    setState(() {
                      _query = '';
                    });
                  },
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

  // RÉSULTATS RECHERCHE

  Widget _buildSearchResults(AsyncValue<List<City>> async) {
    return async.when(
      loading: () => const _SearchLoading(),

      error: (error, _) => _SearchMessage(
        icon: Icons.cloud_off_outlined,
        message: error.toString().replaceFirst('Exception: ', ''),
      ),

      data: (cities) {
        if (cities.isEmpty) {
          return const _SearchMessage(
            icon: Icons.location_off_outlined,
            message: 'Aucune ville trouvée.\nEssayez un autre nom.',
          );
        }

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: [
              for (int index = 0; index < cities.length; index++) ...[
                ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 4,
                  ),
                  leading: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.orange.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.orange,
                      size: 21,
                    ),
                  ),
                  title: Text(
                    cities[index].name,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    cities[index].subtitle,
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                  onTap: () => _openWeather(cities[index]),
                ),

                if (index < cities.length - 1)
                  Divider(
                    height: 1,
                    indent: 70,
                    endIndent: 14,
                    color: Theme.of(context).dividerColor
                        .withValues(alpha: 0.5),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  // CARTE VILLE

  Widget _cityCard(City city) {
    final favorite = ref.watch(favoritesProvider).contains(city);
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
                // PHOTO

                if (imageUrl != null && imageUrl.isNotEmpty)
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.high,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return _cityFallbackBackground(isDark);
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return _cityFallbackBackground(isDark);
                    },
                  )
                else
                  _cityFallbackBackground(isDark),

                // VOILE DISCRET
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

                // PETIT INDICATEUR FAVORI
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
                      favorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: favorite ? AppColors.orange : Colors.white,
                      size: 18,
                    ),
                  ),
                ),

                // NOM DE LA VILLE
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

                // CHARGEMENT
                if (snapshot.connectionState == ConnectionState.waiting &&
                    imageUrl == null)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 0,
                    bottom: 0,
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

  // FOND DE SECOURS

  Widget _cityFallbackBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF18232F) : const Color(0xFFE9EEF1),
      ),
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

  // FAVORIS

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
          child: const Icon(Icons.favorite_rounded, color: AppColors.orange, size: 20),
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

  // FAVORIS VIDES

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
          const Icon(Icons.favorite_border_rounded, color: AppColors.green, size: 25),

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
                  'Ajoutez vos villes préférées depuis leur page météo pour les retrouver rapidement ici.',
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

  // TITRE DE SECTION

  Widget _sectionTitle(String title, String subtitle, IconData icon) {
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
      ],
    );
  }
}

// RECHERCHE : CHARGEMENT

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

// RECHERCHE : MESSAGE

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
