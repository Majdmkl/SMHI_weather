import '../models/place_model.dart';
import '../repositories/place_repository.dart';

/// Use Case: handles favorites
/// Business logic: Load, save, and toggle favorites
class ManageFavoritesUseCase {
  final PlaceRepository _repository;

  ManageFavoritesUseCase(this._repository);

  /// Load all favoriter
  Future<List<Place>> loadFavorites() async {
    return await _repository.loadFavorites();
  }

  /// Toggle favorit (add or remove)
  Future<List<Place>> toggleFavorite(
      Place place,
      List<Place> currentFavorites,
      ) async {
    final newFavorites = List<Place>.from(currentFavorites);

    if (_repository.isFavorite(place, currentFavorites)) {
      // Remove
      newFavorites.removeWhere((p) =>
      p.lat == place.lat && p.lon == place.lon && p.name == place.name);
    } else {
      // add
      newFavorites.add(place);
    }

    await _repository.saveFavorites(newFavorites);
    return newFavorites;
  }

  /// Check if a place is a favorite
  bool isFavorite(Place place, List<Place> favorites) {
    return _repository.isFavorite(place, favorites);
  }
}