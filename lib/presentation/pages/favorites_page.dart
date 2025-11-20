import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/place.dart';
import '../viewmodels/place_viewmodel.dart';

/// Enkel sida som visar alla favorit-platser.
/// När man trycker på en rad skickas valt Place tillbaka med Navigator.pop.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final placeState = ref.watch(placeProvider);

    final favs = placeState.favorites;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite places'),
      ),
      body: favs.isEmpty
          ? const Center(
              child: Text('You have no favourite places yet.'),
            )
          : ListView.separated(
              itemCount: favs.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (ctx, i) {
                final Place p = favs[i];
                return ListTile(
                  leading: const Icon(Icons.star),
                  title: Text(p.name),
                  subtitle: Text(
                    'lon: ${p.lon.toStringAsFixed(3)}  •  '
                    'lat: ${p.lat.toStringAsFixed(3)}',
                  ),
                  onTap: () {
                    // Skicka tillbaka vald plats till sidan som öppnade oss.
                    Navigator.pop<Place>(context, p);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.star_border),
                    tooltip: 'Remove from favourites',
                    onPressed: () {
                      // Samma toggle som i resten av appen.
                      ref.read(placeProvider.notifier).toggleFavorite(p);
                    },
                  ),
                );
              },
            ),
    );
  }
}
