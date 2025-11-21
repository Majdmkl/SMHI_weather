import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/place.dart';

class PlaceApi {
  // Using geocode.maps.co with API key
  // API key: 692064a9d10bc584103700axma7872e

  static const String _apiKey = '692064a9d10bc584103700axma7872e';

  Future<List<Place>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // Geocode.maps.co endpoint with API key
    final uri = Uri.parse(
        'https://geocode.maps.co/search?q=${Uri.encodeComponent(query)}&api_key=$_apiKey'
    );

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception('Geocode API HTTP ${res.statusCode}: ${res.body}');
      }

      final body = json.decode(res.body);

      // geocode.maps.co returns a list of places
      if (body is List) {
        return body.map<Place?>((e) {
          final m = e as Map<String, dynamic>;

          // Get the display name and coordinates
          final displayName = (m['display_name'] ?? '').toString();
          final name = (m['name'] ?? displayName).toString();
          final lat = double.tryParse(m['lat']?.toString() ?? '');
          final lon = double.tryParse(m['lon']?.toString() ?? '');

          // Validate data
          if (lat == null || lon == null) {
            return null;
          }

          // Create a cleaner name - use first part of display_name if name is empty
          String cleanName = name;
          if (cleanName.isEmpty && displayName.isNotEmpty) {
            final parts = displayName.split(',');
            cleanName = parts.isNotEmpty ? parts[0].trim() : displayName;
          }

          return Place(
            name: cleanName.isEmpty ? displayName : cleanName,
            lat: lat,
            lon: lon,
          );
        }).whereType<Place>().toList();
      }

      throw Exception('Unexpected response format');
    } catch (e) {
      throw Exception('Failed to search places: $e');
    }
  }
}