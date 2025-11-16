import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutTab extends StatelessWidget {
  final PackageInfo? packageInfo;
  final VoidCallback onOpenSource;
  final VoidCallback onContact;

  const AboutTab({
    super.key,
    this.packageInfo,
    required this.onOpenSource,
    required this.onContact,
  });

  @override
  Widget build(BuildContext context) {
    final version = packageInfo?.version ?? '—';
    final buildNumber = packageInfo?.buildNumber ?? '—';

    final packages = [
      'flutter_map',
      'latlong2',
      'hive',
      'flutter_bloc',
      'geolocator',
      'package_info_plus',
      'url_launcher',
      'http',
      'connectivity_plus',
      'equatable',
    ];

    final architecture = [
      'Presentation: Flutter widgets, Bloc for state management',
      'Data: Repository pattern, Hive for offline caching',
      'Networking: API service layer (REST)',
    ];

    final features = [
      'Browse breweries with infinite scroll and pagination',
      'View breweries on an interactive map with clustering support',
      'Mark favorites and access them offline via Hive caching',
      'Offline-first experience: cached data used when no network is available',
      'User location with a blue marker.',
      'Detailed brewery pages with website links and map integration',
      'Share brewery details and export favorites',
      'Accessibility-friendly: scalable fonts and semantic labels',
      'Pluggable architecture: easy to add analytics, auth, or push notifications',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Text('App', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 8),
          Text(
            'Brewery Explorer',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 4),
          Text('Version: $version ($buildNumber)'),

          const SizedBox(height: 16),

          Text(
            'What this app does',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Browse breweries, view them on a map, save favorites for offline use, and read details.',
          ),

          const SizedBox(height: 16),

          Text('Key Features', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...features.map(
                (f) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $f'),
            ),
          ),

          const SizedBox(height: 16),

          Text('Architecture', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...architecture.map(
                (a) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $a'),
            ),
          ),

          const SizedBox(height: 16),

          Text('Packages used', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ...packages.map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('• $p'),
            ),
          ),

          const SizedBox(height: 16),

          Text(
            'Data & Offline',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Uses Hive to cache brewery details and store favorite ids. The list and map read from cache when offline.',
          ),

          const SizedBox(height: 16),

          Text(
            'Privacy & Permissions',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Location permission is requested at runtime to show your current location on the map.',
          ),

          const SizedBox(height: 24),

          ElevatedButton.icon(
            onPressed: onOpenSource,
            icon: const Icon(Icons.code),
            label: const Text('View Source / Repo'),
          ),

          const SizedBox(height: 8),

          ElevatedButton.icon(
            onPressed: onContact,
            icon: const Icon(Icons.mail),
            label: const Text('Contact Developer'),
          ),
        ],
      ),
    );
  }
}
