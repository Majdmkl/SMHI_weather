import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/forecast.dart';

class SmhiApi {
  final bool useTestMirror;
  SmhiApi({this.useTestMirror = false});

  Future<SmhiRoot> getForecast(double lon, double lat) async {
    final uri = useTestMirror
      ? Uri.parse('https://maceo.sth.kth.se/weather/forecast?lonLat=lon/$lon/lat/$lat') // dev only
      : Uri.parse('https://opendata-download-metfcst.smhi.se/api/category/pmp3g/version/2/geotype/point/lon/$lon/lat/$lat/data.json');


    final res = await http.get(uri).timeout(const Duration(seconds: 8));
    if (res.statusCode != 200) {
      throw Exception('SMHI HTTP ${res.statusCode} for $uri');
    }
    return compute(_parseSmhi, res.body);
  }
}

// Fristående parser-funktion (kravet: separat parser)
SmhiRoot _parseSmhi(String body) {
  final map = json.decode(body) as Map<String, dynamic>;
  return SmhiRoot.fromJson(map);
}
