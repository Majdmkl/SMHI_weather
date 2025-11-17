import 'package:smhi_weather/core/network.dart';
import 'package:smhi_weather/core/result.dart';
import '../models/forecast.dart';
import '../sources/cache_store.dart';
import '../sources/smhi_api.dart';

class ForecastRepository {
  final SmhiApi api;
  final CacheStore cache;
  ForecastRepository({required this.api, required this.cache});

  /// Returnerar Ok((root, offline)) eller Err(fel)
  Future<Result<(SmhiRoot root, bool offline)>> get(double lon, double lat) async {
    try {
      final online = await hasInternet();
      if (online) {
        final root = await api.getForecast(lon, lat);
        await cache.saveMap({'timeSeries': root.timeSeries.map((t) => {
          'validTime': t.validTime,
          'parameters': t.parameters.map((p) => {
            'name': p.name,
            'values': p.values
          }).toList()
        }).toList()});
        return Ok((root, false));
      } else {
        final raw = await cache.loadMap();
        if (raw == null) return Err('No internet and no cached data');
        return Ok((SmhiRoot.fromJson(raw), true));
      }
    } catch (e) {
      return Err(e);
    }
  }
}
