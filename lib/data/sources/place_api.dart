import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/place.dart';

class PlaceApi {
  final bool useTestMirror;
  PlaceApi({this.useTestMirror = false});

  Future<List<Place>> search(String query) async {
    final uri = useTestMirror
        // KTH test-server (högre nivå – svenska orter)
        ? Uri.parse('https://maceo.sth.kth.se/weather/search?location=$query')
        // Slutversion – internationell API (om du vill använda den)
        : Uri.parse('https://geocode.maps.co/search?q=$query');

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('HTTP ${res.statusCode}');
    }

    final body = json.decode(res.body);

    if (useTestMirror) {
      // KTH: lista med { place, lat, lon, ... }
      if (body is List) {
        return body.map<Place?>((e) {
          final m = e as Map<String, dynamic>;

          final name = (m['place'] ?? '').toString();
          final lat = (m['lat'] as num?)?.toDouble();
          final lon = (m['lon'] as num?)?.toDouble();

          if (name.isEmpty || lat == null || lon == null) {
            // hoppa över trasiga rader (t.ex. de som orsakar Null-felet)
            return null;
          }

          return Place(name: name, lat: lat, lon: lon);
        }).whereType<Place>().toList();
      }
      throw Exception('Unexpected KTH response format');
    }

    // geocode.maps.co: lista med { display_name, lat, lon, ... }
    if (body is List) {
      return body.map<Place?>((e) {
        final m = e as Map<String, dynamic>;

        final name = (m['display_name'] ?? m['name'] ?? '').toString();
        final lat = double.tryParse(m['lat']?.toString() ?? '');
        final lon = double.tryParse(m['lon']?.toString() ?? '');

        if (name.isEmpty || lat == null || lon == null) {
          return null;
        }

        return Place(name: name, lat: lat, lon: lon);
      }).whereType<Place>().toList();
    }

    throw Exception('Unexpected response type');
  }
}
