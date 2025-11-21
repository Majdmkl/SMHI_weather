import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/place_repository.dart';
import '../../data/sources/place_api.dart';
import '../../domain/entities/place.dart';

/// Repo-provider: håller reda på PlaceRepository (API + ev. lagring)
final placeRepoProvider = Provider<PlaceRepository>((ref) {
  // REMOVED: useTestMirror: true - now always uses production API
  return PlaceRepository(api: PlaceApi());
});

/// State för sök + favoriter
class PlaceState {
  final List<Place> searchResults;
  final List<Place> favorites;
  final bool searching;
  final String? error;

  const PlaceState({
    this.searchResults = const [],
    this.favorites = const [],
    this.searching = false,
    this.error,
  });

  PlaceState copyWith({
    List<Place>? searchResults,
    List<Place>? favorites,
    bool? searching,
    String? error,
  }) {
    return PlaceState(
      searchResults: searchResults ?? this.searchResults,
      favorites: favorites ?? this.favorites,
      searching: searching ?? this.searching,
      error: error,
    );
  }
}

/// Provider som UI:t använder (samma stil som forecastProvider)
final placeProvider = NotifierProvider<PlaceNotifier, PlaceState>(() {
  return PlaceNotifier();
});

class PlaceNotifier extends Notifier<PlaceState> {
  late final PlaceRepository _repo;

  @override
  PlaceState build() {
    _repo = ref.read(placeRepoProvider);
    // Ladda favoriter i bakgrunden
    _loadFavorites();
    // Tomt initialt state
    return const PlaceState();
  }

  Future<void> _loadFavorites() async {
    final favs = await _repo.loadFavorites();
    state = state.copyWith(favorites: favs);
  }

  Future<void> search(String query) async {
    if (query.trim().isEmpty) return;

    state = state.copyWith(searching: true, error: null);

    try {
      final results = await _repo.search(query);
      state = state.copyWith(
        searching: false,
        searchResults: results,
      );
    } catch (e) {
      state = state.copyWith(
        searching: false,
        error: e.toString(),
      );
    }
  }

  Future<void> toggleFavorite(Place place) async {
    final favs = await _repo.toggleFavorite(place);
    state = state.copyWith(favorites: favs);
  }
}