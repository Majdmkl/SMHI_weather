import 'package:json_annotation/json_annotation.dart';
part 'forecast_model.g.dart';

@JsonSerializable()
class SmhiRoot {
  final List<SmhiTimeStep> timeSeries;
  SmhiRoot({required this.timeSeries});

  factory SmhiRoot.fromJson(Map<String, dynamic> json) =>
      _$SmhiRootFromJson(json);
  Map<String, dynamic> toJson() => _$SmhiRootToJson(this);
}

@JsonSerializable()
class SmhiTimeStep {
  final String validTime;
  final List<SmhiParameter> parameters;

  SmhiTimeStep({
    required this.validTime,
    required this.parameters,
  });

  factory SmhiTimeStep.fromJson(Map<String, dynamic> json) =>
      _$SmhiTimeStepFromJson(json);
  Map<String, dynamic> toJson() => _$SmhiTimeStepToJson(this);

  /// Temperatur (°C)
  double? get temperature => _valueFor('t');

  /// Molnighet (0–100 %)
  double? get cloudiness => _valueFor('tcc_mean');

  /// Nederbörd (mm/h)
  double? get precipitation => _valueFor('pmean');

  /// Vindhastighet (m/s)
  double? get windSpeed => _valueFor('ws');

  double? _valueFor(String name) {
    final match = parameters.firstWhere(
          (p) => p.name == name,
      orElse: () => SmhiParameter(name: name, values: null),
    );

    final vals = match.values;
    if (vals == null || vals.isEmpty) return null;

    final v = vals.first;
    if (v is num) return v.toDouble();
    return double.tryParse(v.toString());
  }
}

@JsonSerializable()
class SmhiParameter {
  final String name;
  final List<dynamic>? values;

  SmhiParameter({
    required this.name,
    this.values,
  });

  factory SmhiParameter.fromJson(Map<String, dynamic> json) =>
      _$SmhiParameterFromJson(json);
  Map<String, dynamic> toJson() => _$SmhiParameterToJson(this);
}

// Daily Forecast Model
class DailyForecast {
  final DateTime day;
  final double minT;
  final double maxT;
  final double meanCloud;
  final double meanPrecip;
  final double meanWind;
  final List<HourForecast> hourly;

  const DailyForecast({
    required this.day,
    required this.minT,
    required this.maxT,
    required this.meanCloud,
    required this.meanPrecip,
    required this.meanWind,
    this.hourly = const [],
  });
}

class HourForecast {
  final DateTime time;
  final double temperature;
  final double cloudiness;
  final double precipitation;
  final double windSpeed;

  const HourForecast({
    required this.time,
    required this.temperature,
    required this.cloudiness,
    required this.precipitation,
    required this.windSpeed,
  });
}

/// Convert SMHI time steps to daily forecasts
List<DailyForecast> toDaily(List<SmhiTimeStep> steps) {
  if (steps.isEmpty) return [];

  final byDay = <DateTime, List<SmhiTimeStep>>{};
  for (final s in steps) {
    final t = DateTime.parse(s.validTime).toLocal();
    final key = DateTime(t.year, t.month, t.day);
    (byDay[key] ??= []).add(s);
  }

  final entries = byDay.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final todayKey = entries.first.key;

  return entries.take(7).map((entry) {
    final stepsOfDay = entry.value;

    List<double> temps =
    stepsOfDay.map((s) => s.temperature).whereType<double>().toList();
    List<double> clouds =
    stepsOfDay.map((s) => s.cloudiness).whereType<double>().toList();
    List<double> precs =
    stepsOfDay.map((s) => s.precipitation).whereType<double>().toList();
    List<double> winds =
    stepsOfDay.map((s) => s.windSpeed).whereType<double>().toList();

    double avg(List<double> xs) =>
        xs.isEmpty ? double.nan : xs.reduce((a, b) => a + b) / xs.length;

    final minT =
    temps.isEmpty ? double.nan : temps.reduce((a, b) => a < b ? a : b);
    final maxT =
    temps.isEmpty ? double.nan : temps.reduce((a, b) => a > b ? a : b);

    final hourly = entry.key == todayKey
        ? stepsOfDay
        .map((s) {
      final t = DateTime.parse(s.validTime).toLocal();
      final temp = s.temperature;
      final c = s.cloudiness;
      final p = s.precipitation;
      final w = s.windSpeed;

      if (temp == null || c == null || p == null || w == null) {
        return null;
      }

      return HourForecast(
        time: t,
        temperature: temp,
        cloudiness: c,
        precipitation: p,
        windSpeed: w,
      );
    })
        .whereType<HourForecast>()
        .toList()
        : const <HourForecast>[];

    return DailyForecast(
      day: entry.key,
      minT: minT,
      maxT: maxT,
      meanCloud: avg(clouds),
      meanPrecip: avg(precs),
      meanWind: avg(winds),
      hourly: hourly,
    );
  }).toList();
}