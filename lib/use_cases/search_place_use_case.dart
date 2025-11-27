import '../models/place_model.dart';
import '../repositories/place_repository.dart';

/// Use Case: Search for places
class SearchPlaceUseCase {
  final PlaceRepository _repository;

  SearchPlaceUseCase(this._repository);

  Future<SearchPlaceResult> execute(String query) async {
    try {
      final places = await _repository.searchPlaces(query);
      return SearchPlaceResult.success(places);
    } catch (e) {
      return SearchPlaceResult.failure(e.toString());
    }
  }
}

class SearchPlaceResult {
  final List<Place> places;
  final String? error;
  final bool isSuccess;

  SearchPlaceResult._({
    required this.places,
    this.error,
    required this.isSuccess,
  });

  factory SearchPlaceResult.success(List<Place> places) {
    return SearchPlaceResult._(
      places: places,
      isSuccess: true,
    );
  }

  factory SearchPlaceResult.failure(String error) {
    return SearchPlaceResult._(
      places: [],
      error: error,
      isSuccess: false,
    );
  }
}