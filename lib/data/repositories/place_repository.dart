import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/place.dart';
import '../sources/place_api.dart';

class PlaceRepository {
  final PlaceApi api;
  static const _favoritesKey = 'favorite_places';

  PlaceRepository({required this.api});

  Future<List<Place>> search(String query) => api.search(query);

  Future<List<Place>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_favoritesKey);
    if (raw == null) return [];
    final list = (json.decode(raw) as List)
        .map((e) => Place.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<void> saveFavorites(List<Place> places) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = json.encode(places.map((p) => p.toJson()).toList());
    await prefs.setString(_favoritesKey, encoded);
  }

  /// Toggle: lägger till om saknas, tar bort om finns.
  Future<List<Place>> toggleFavorite(Place place) async {
    final current = await loadFavorites();
    final idx = current.indexWhere(
        (p) => p.lat == place.lat && p.lon == place.lon && p.name == place.name);
    if (idx >= 0) {
      current.removeAt(idx);
    } else {
      current.add(place);
    }
    await saveFavorites(current);
    return current;
  }
}
