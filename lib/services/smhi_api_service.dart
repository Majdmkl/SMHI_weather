import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/forecast_model.dart';

class SmhiApiService {
  Future<SmhiRoot> getForecast(double lon, double lat) async {
    final uri = Uri.parse(
        'https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/$lon/lat/$lat/data.json');

    try {
      final res = await http.get(uri).timeout(const Duration(seconds: 10));

      if (res.statusCode != 200) {
        throw Exception('SMHI HTTP ${res.statusCode} for $uri');
      }

      return compute(_parseSmhi, res.body);
    } catch (e) {
      throw Exception('Failed to fetch forecast: $e');
    }
  }
}

SmhiRoot _parseSmhi(String body) {
  final map = json.decode(body) as Map<String, dynamic>;
  return SmhiRoot.fromJson(map);
}