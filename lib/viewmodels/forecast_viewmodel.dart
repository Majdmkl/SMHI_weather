import 'package:flutter/foundation.dart';
import '../models/forecast_model.dart';
import '../use_cases/load_forecast_use_case.dart';

/// ForecastViewModel - endast presentation logic
/// Affärslogik delegeras till Use Cases
class ForecastViewModel extends ChangeNotifier {
  final LoadForecastUseCase _loadForecastUseCase;

  // State properties (presentation state)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<DailyForecast> _days = [];
  List<DailyForecast> get days => _days;

  bool _isOffline = false;
  bool get isOffline => _isOffline;

  String? _error;
  String? get error => _error;

  bool get hasData => _days.isNotEmpty;

  ForecastViewModel({
    required LoadForecastUseCase loadForecastUseCase,
  }) : _loadForecastUseCase = loadForecastUseCase;

  /// Ladda prognos (delegerar till Use Case)
  Future<void> loadForecast(double lon, double lat) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Delegera affärslogik till Use Case
    final result = await _loadForecastUseCase.execute(lon, lat);

    // Uppdatera presentation state
    if (result.isSuccess) {
      _days = result.days;
      _isOffline = result.isOffline;
      _error = null;
    } else {
      _error = result.error;
      _days = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Rensa fel (presentation logic)
  void clearError() {
    _error = null;
    notifyListeners();
  }
}