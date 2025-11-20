import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/forecast_repository.dart';
import '../../data/sources/cache_store.dart';
import '../../data/sources/smhi_api.dart';
import '../../domain/entities/daily_forecast.dart';

// Repo-provider (håller API + cache)
final repoProvider = Provider<ForecastRepository>((ref) {
  return ForecastRepository(
    api: SmhiApi(useTestMirror: false), // true under utveckling, false i slutversion
    cache: CacheStore(),
  );
});

/// Vår app-state: AsyncValue med (lista + offlineflagga).
typedef ForecastState = AsyncValue<({List<DailyForecast> days, bool offline})>;

/// Notifier (nytt API i Riverpod v2). Enklare än StateNotifier.
final forecastProvider = NotifierProvider<ForecastNotifier, ForecastState>(() {
  return ForecastNotifier();
});

class ForecastNotifier extends Notifier<ForecastState> {
  late final ForecastRepository _repo;

  @override
  ForecastState build() {
    // Körs när providern konstrueras.
    _repo = ref.read(repoProvider);
    // Tomt init-state (uppfyller "hantera tomt läge")
    return const AsyncValue.data((days: <DailyForecast>[], offline: false));
  }

  Future<void> load(double lon, double lat) async {
    state = const AsyncValue.loading();
    final res = await _repo.get(lon, lat);
    res.when(
      ok: (tuple) {
        final days = toDaily(tuple.$1.timeSeries);
        state = AsyncValue.data((days: days, offline: tuple.$2));
      },
      err: (e) => state = AsyncValue.error(e, StackTrace.current),
    );
  }
}
