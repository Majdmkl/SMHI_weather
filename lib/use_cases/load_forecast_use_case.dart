import '../models/forecast_model.dart';
import '../repositories/forecast_repository.dart';

/// Use Case: Ladda väderprognos
/// Affärslogik: Hämta data och konvertera till daglig prognos
class LoadForecastUseCase {
  final ForecastRepository _repository;

  LoadForecastUseCase(this._repository);

  Future<LoadForecastResult> execute(double lon, double lat) async {
    final result = await _repository.getForecast(lon, lat);

    return result.when(
      ok: (tuple) {
        final (root, isOffline) = tuple;
        // Affärslogik: Konvertera till daglig prognos
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

/// Result class för Load Forecast
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