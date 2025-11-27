import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/place_model.dart';
import '../services/place_api_service.dart';

// Repository that abstracts data access for locations
class PlaceRepository {
  final PlaceApiService _apiService;
  static const _favoritesKey = 'favorite_places';

  PlaceRepository({required PlaceApiService apiService})
      : _apiService = apiService;

  // Search for places
  Future<List<Place>> searchPlaces(String query) async {
    if (query.trim().isEmpty) return [];
    return await _apiService.search(query);
  }

  // Load favorites
  Future<List<Place>> loadFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_favoritesKey);
      if (raw == null) return [];

      final list = (json.decode(raw) as List)
          .map((e) => Place.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } catch (e) {
      return [];
    }
  }

  /// Save favorites
  Future<void> saveFavorites(List<Place> places) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(places.map((p) => p.toJson()).toList());
    await prefs.setString(_favoritesKey, encoded);
  }

  /// Check if a place is favorite
  bool isFavorite(Place place, List<Place> favorites) {
    return favorites.any((p) =>
    p.lat == place.lat && p.lon == place.lon && p.name == place.name);
  }
}