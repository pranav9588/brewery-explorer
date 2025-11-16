import 'package:brewery/models/response_model.dart';
import 'package:brewery/ui/brewery_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final Box<bool> favBox = Hive.box<bool>('favorites');
    final Box<Brewery> breweriesBox = Hive.box<Brewery>('breweries');

    return Scaffold(
      appBar: AppBar(title: const Text("Favorite Breweries")),
      body: ValueListenableBuilder<Box<bool>>(
        valueListenable: favBox.listenable(),
        builder: (context, box, child) {
          final favIds = box.keys
              .where((k) => box.get(k) == true)
              .map((e) => e.toString())
              .toList();

          if (favIds.isEmpty) {
            return const Center(
              child: Text(
                "No favorites yet!",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            );
          }

          final favoriteBreweries = favIds
              .map((id) => breweriesBox.get(id))
              .toList();

          return ListView.separated(
            itemCount: favoriteBreweries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final brewery = favoriteBreweries[index];

              if (brewery == null) {
                final missingId = favIds[index];
                return ListTile(
                  title: Text('Unknown brewery ($missingId)'),
                  subtitle: const Text('Tap to fetch details when online'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => favBox.delete(missingId),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BreweryDetailPage(brewery: brewery!),
                      ),
                    );
                  },
                );
              }

              return Card(
                margin: const EdgeInsets.all(12),
                child: ListTile(
                  title: Text(brewery.name ?? "Unknown Brewery"),
                  subtitle: Text(brewery.city ?? ""),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => favBox.delete(brewery.id),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            BreweryDetailPage(brewery: brewery),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
