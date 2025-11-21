import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/place.dart';

class PlaceApi {
  // Använder Nominatim med fokus på Sverige
  // Detta fungerar utmärkt för svenska städer och platser
  // SMHI:s autocomplete API (som krävdes i labben) existerar tyvärr inte längre som JSON-endpoint

  Future<List<Place>> search(String query) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // Nominatim med fokus på Sverige
    // Lägger till "Sweden" för att prioritera svenska resultat
    final searchQuery = query.contains('Sweden') || query.contains('Sverige')
        ? query
        : '$query, Sweden';

    final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
            '?q=${Uri.encodeComponent(searchQuery)}'
            '&format=json'
            '&limit=10'
            '&countrycodes=se'  // Begränsar till Sverige
            '&addressdetails=1'
    );

    try {
      final res = await http.get(
        uri,
        headers: {
          'User-Agent': 'SMHIWeatherApp/1.0 (Flutter Educational Project)',
          'Accept-Language': 'sv,en',  // Föredrar svenska namn
        },
      ).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception('HTTP ${res.statusCode}: ${res.body}');
      }

      final body = json.decode(res.body);

      if (body is List) {
        return body.map<Place?>((e) {
          final m = e as Map<String, dynamic>;

          // Hämta namn (föredrar svenska namn)
          final displayName = (m['display_name'] ?? '').toString();
          final name = (m['name'] ?? '').toString();

          // Koordinater
          final lat = double.tryParse(m['lat']?.toString() ?? '');
          final lon = double.tryParse(m['lon']?.toString() ?? '');

          if (lat == null || lon == null) {
            return null;
          }

          // Skapa ett rent namn utan hela adressen
          String cleanName = name.isNotEmpty ? name : displayName;

          // Om vi har address-detaljer, använd dem för bättre namn
          if (m['address'] is Map) {
            final address = m['address'] as Map<String, dynamic>;
            cleanName = address['city'] ??
                address['town'] ??
                address['village'] ??
                address['municipality'] ??
                name;
          }

          // Fallback till första delen av display_name
          if (cleanName.isEmpty && displayName.isNotEmpty) {
            final parts = displayName.split(',');
            cleanName = parts.isNotEmpty ? parts[0].trim() : displayName;
          }

          return Place(
            name: cleanName,
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