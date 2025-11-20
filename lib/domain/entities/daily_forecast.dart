// lib/domain/entities/daily_forecast.dart

import '../../data/models/forecast.dart';

class DailyForecast {
  final DateTime day;

  final double minT;
  final double maxT;

  final double meanCloud;     // 0–100 %
  final double meanPrecip;    // mm/h
  final double meanWind;      // m/s

  /// Endast för idag fylls denna lista med timvärden.
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
  final double cloudiness;     // 0–100 %
  final double precipitation;  // mm/h
  final double windSpeed;      // m/s

  const HourForecast({
    required this.time,
    required this.temperature,
    required this.cloudiness,
    required this.precipitation,
    required this.windSpeed,
  });
}

/// Tar SMHI:s timeSteps och gör om till 7 dagposter.
/// Första dagen (idag) får även en lista med timprognoser.
List<DailyForecast> toDaily(List<SmhiTimeStep> steps) {
  if (steps.isEmpty) return [];

  // ---- 1. Gruppera per kalenderdag ----
  final byDay = <DateTime, List<SmhiTimeStep>>{};
  for (final s in steps) {
    final t = DateTime.parse(s.validTime).toLocal();
    final key = DateTime(t.year, t.month, t.day);
    (byDay[key] ??= []).add(s);
  }

  // ---- 2. Sortera dagarna ----
  final entries = byDay.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final todayKey = entries.first.key;

  // ---- 3. Skapa DailyForecast per dag ----
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

    final meanC = avg(clouds);
    final meanP = avg(precs);
    final meanW = avg(winds);

    // ---- Endast idag: skapa timlistan ----
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
      meanCloud: meanC,
      meanPrecip: meanP,
      meanWind: meanW,
      hourly: hourly,
    );
  }).toList();
}
