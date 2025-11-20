import '../../data/models/forecast.dart';

class HourForecast {
  final DateTime time;
  final double temperature;
  final double cloudiness;

  const HourForecast({
    required this.time,
    required this.temperature,
    required this.cloudiness,
  });
}

class DailyForecast {
  final DateTime day;
  final double minT;
  final double maxT;
  final double meanCloud;

  /// Tom lista för alla dagar utom idag
  final List<HourForecast> hourly;

  const DailyForecast({
    required this.day,
    required this.minT,
    required this.maxT,
    required this.meanCloud,
    this.hourly = const [],
  });
}

// Gruppning: timvärden för idag, dagvärden för övriga
List<DailyForecast> toDaily(List<SmhiTimeStep> steps) {
  final byDay = <DateTime, List<SmhiTimeStep>>{};

  for (final s in steps) {
    final t = DateTime.parse(s.validTime).toLocal();
    final key = DateTime(t.year, t.month, t.day);
    (byDay[key] ??= []).add(s);
  }

  final entries = byDay.entries.toList()
    ..sort((a, b) => a.key.compareTo(b.key));

  final todayKey = DateTime.now();
  final today = DateTime(todayKey.year, todayKey.month, todayKey.day);

  return entries.take(7).map((e) {
    final allSteps = e.value;

    final temps = allSteps
        .map((s) => s.temperature)
        .whereType<double>()
        .toList();

    final clouds = allSteps
        .map((s) => s.cloudiness)
        .whereType<double>()
        .toList();

    final minT = temps.isEmpty
        ? double.nan
        : temps.reduce((a, b) => a < b ? a : b);

    final maxT = temps.isEmpty
        ? double.nan
        : temps.reduce((a, b) => a > b ? a : b);

    final meanC = clouds.isEmpty
        ? double.nan
        : clouds.reduce((a, b) => a + b) / clouds.length;

    // Timdata för idag:
    List<HourForecast> hours = [];

    if (e.key == today) {
      hours = allSteps.map((s) {
        final t = DateTime.parse(s.validTime).toLocal();
        return HourForecast(
          time: t,
          temperature: s.temperature ?? double.nan,
          cloudiness: s.cloudiness ?? double.nan,
        );
      }).toList();
    }

    return DailyForecast(
      day: e.key,
      minT: minT,
      maxT: maxT,
      meanCloud: meanC,
      hourly: hours,
    );
  }).toList();
}
