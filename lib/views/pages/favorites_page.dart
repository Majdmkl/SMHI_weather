import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/place_model.dart';
import '../../viewmodels/place_viewmodel.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favourite places'),
      ),
      body: Consumer<PlaceViewModel>(
        builder: (context, placeVM, child) {
          final favs = placeVM.favorites;

          if (favs.isEmpty) {
            return const Center(
              child: Text('You have no favourite places yet.'),
            );
          }

          return ListView.separated(
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
                onTap: () => Navigator.pop<Place>(context, p),
                trailing: IconButton(
                  icon: const Icon(Icons.star_border),
                  tooltip: 'Remove from favourites',
                  onPressed: () => placeVM.toggleFavorite(p),
                ),
              );
            },
          );
        },
      ),
    );
  }
}