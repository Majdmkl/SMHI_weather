import 'dart:io';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:smhi_weather/core/result.dart';

import '../models/forecast.dart';
import '../sources/cache_store.dart';
import '../sources/smhi_api.dart';

class ForecastRepository {
  final SmhiApi api;
  final CacheStore cache;

  ForecastRepository({required this.api, required this.cache});

  Future<Result<(SmhiRoot root, bool offline)>> get(
      double lon, double lat) async {
    try {
      final root = await api
          .getForecast(lon, lat)
          .timeout(const Duration(seconds: 8)); // extra säkerhet

      await cache.saveMap(root.toJson());

      return Ok((root, false));
    } on SocketException catch (_) {
    } on http.ClientException catch (_) {
    } on TimeoutException catch (_) {
    } catch (e) {}

    try {
      final raw = await cache.loadMap();
      if (raw != null) {
        final root = SmhiRoot.fromJson(raw);
        return Ok((root, true));
      }
      return Err('No internet and no cached data');
    } catch (e) {
      return Err(e);
    }
  }
}
