import 'package:flutter/foundation.dart';
import '../models/place_model.dart';
import '../use_cases/search_place_use_case.dart';
import '../use_cases/manage_favorites_use_case.dart';

/// PlaceViewModel - endast presentation logic
/// Affärslogik delegeras till Use Cases
class PlaceViewModel extends ChangeNotifier {
  final SearchPlaceUseCase _searchPlaceUseCase;
  final ManageFavoritesUseCase _manageFavoritesUseCase;

  // State properties (presentation state)
  List<Place> _searchResults = [];
  List<Place> get searchResults => _searchResults;

  List<Place> _favorites = [];
  List<Place> get favorites => _favorites;

  bool _isSearching = false;
  bool get isSearching => _isSearching;

  String? _error;
  String? get error => _error;

  PlaceViewModel({
    required SearchPlaceUseCase searchPlaceUseCase,
    required ManageFavoritesUseCase manageFavoritesUseCase,
  })  : _searchPlaceUseCase = searchPlaceUseCase,
        _manageFavoritesUseCase = manageFavoritesUseCase {
    _loadFavorites();
  }

  /// Ladda favoriter vid start
  Future<void> _loadFavorites() async {
    _favorites = await _manageFavoritesUseCase.loadFavorites();
    notifyListeners();
  }

  /// Sök efter platser (delegerar till Use Case)
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    _error = null;
    notifyListeners();

    // Delegera affärslogik till Use Case
    final result = await _searchPlaceUseCase.execute(query);

    // Uppdatera presentation state
    if (result.isSuccess) {
      _searchResults = result.places;
      _error = null;
    } else {
      _error = result.error;
      _searchResults = [];
    }

    _isSearching = false;
    notifyListeners();
  }

  /// Toggle favorit (delegerar till Use Case)
  Future<void> toggleFavorite(Place place) async {
    // Delegera affärslogik till Use Case
    _favorites = await _manageFavoritesUseCase.toggleFavorite(
      place,
      _favorites,
    );
    notifyListeners();
  }

  /// Rensa sökresultat (presentation logic)
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  /// Rensa fel (presentation logic)
  void clearError() {
    _error = null;
    notifyListeners();
  }
}