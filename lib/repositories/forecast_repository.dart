import 'dart:io';
import 'dart:async';
import '../models/forecast_model.dart';
import '../services/smhi_api_service.dart';
import '../services/cache_service.dart';
import '../utils/result.dart';

// Repository that abstracts data access for forecasts
class ForecastRepository {
  final SmhiApiService _apiService;
  final CacheService _cacheService;

  ForecastRepository({
    required SmhiApiService apiService,
    required CacheService cacheService,
  })  : _apiService = apiService,
        _cacheService = cacheService;

  // Get forecast from API or cache
  Future<Result<(SmhiRoot, bool isOffline)>> getForecast(
      double lon,
      double lat,
      ) async {
    try {
      // Try API first
      final root = await _apiService
          .getForecast(lon, lat)
          .timeout(const Duration(seconds: 8));

      // Save in cache
      await _cacheService.saveMap(root.toJson());

      return Ok((root, false));
    } on SocketException catch (_) {
      return _loadFromCache();
    } on TimeoutException catch (_) {
      return _loadFromCache();
    } catch (e) {
      return _loadFromCache();
    }
  }

  /// Load from cache (private helper method)
  Future<Result<(SmhiRoot, bool isOffline)>> _loadFromCache() async {
    try {
      final raw = await _cacheService.loadMap();
      if (raw != null) {
        final root = SmhiRoot.fromJson(raw);
        return Ok((root, true));
      }
      return const Err('No internet and no cached data');
    } catch (e) {
      return Err(e);
    }
  }
}