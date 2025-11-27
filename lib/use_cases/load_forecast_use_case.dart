import '../models/forecast_model.dart';
import '../repositories/forecast_repository.dart';

/// Use Case: load weather forecast
/// Business logic: Retrieve data and convert to daily forecast
class LoadForecastUseCase {
  final ForecastRepository _repository;

  LoadForecastUseCase(this._repository);

  Future<LoadForecastResult> execute(double lon, double lat) async {
    final result = await _repository.getForecast(lon, lat);

    return result.when(
      ok: (tuple) {
        final (root, isOffline) = tuple;
        // Business Logic: Convert to Daily Forecast
        final days = toDaily(root.timeSeries);

        return LoadForecastResult.success(
          days: days,
          isOffline: isOffline,
        );
      },
      err: (error) {
        return LoadForecastResult.failure(error.toString());
      },
    );
  }
}

/// Result class for Load Forecast
class LoadForecastResult {
  final List<DailyForecast> days;
  final bool isOffline;
  final String? error;
  final bool isSuccess;

  LoadForecastResult._({
    required this.days,
    required this.isOffline,
    this.error,
    required this.isSuccess,
  });

  factory LoadForecastResult.success({
    required List<DailyForecast> days,
    required bool isOffline,
  }) {
    return LoadForecastResult._(
      days: days,
      isOffline: isOffline,
      isSuccess: true,
    );
  }

  factory LoadForecastResult.failure(String error) {
    return LoadForecastResult._(
      days: [],
      isOffline: false,
      error: error,
      isSuccess: false,
    );
  }
}