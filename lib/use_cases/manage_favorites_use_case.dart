import '../models/place_model.dart';
import '../repositories/place_repository.dart';

/// Use Case: Hantera favoriter
/// Affärslogik: Ladda, spara, och toggle favoriter
class ManageFavoritesUseCase {
  final PlaceRepository _repository;

  ManageFavoritesUseCase(this._repository);

  /// Ladda alla favoriter
  Future<List<Place>> loadFavorites() async {
    return await _repository.loadFavorites();
  }

  /// Toggle favorit (lägg till eller ta bort)
  Future<List<Place>> toggleFavorite(
      Place place,
      List<Place> currentFavorites,
      ) async {
    final newFavorites = List<Place>.from(currentFavorites);

    if (_repository.isFavorite(place, currentFavorites)) {
      // Ta bort
      newFavorites.removeWhere((p) =>
      p.lat == place.lat && p.lon == place.lon && p.name == place.name);
    } else {
      // Lägg till
      newFavorites.add(place);
    }

    await _repository.saveFavorites(newFavorites);
    return newFavorites;
  }

  /// Kolla om en plats är favorit
  bool isFavorite(Place place, List<Place> favorites) {
    return _repository.isFavorite(place, favorites);
  }
}