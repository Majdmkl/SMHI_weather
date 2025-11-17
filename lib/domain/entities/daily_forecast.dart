import '../../data/models/forecast.dart';

class DailyForecast {
  final DateTime day;
  final double minT;
  final double maxT;
  final double meanCloud;
  DailyForecast({required this.day, required this.minT, required this.maxT, required this.meanCloud});
}

List<DailyForecast> toDaily(List<SmhiTimeStep> steps) {
  final byDay = <DateTime, List<SmhiTimeStep>>{};
  for (final s in steps) {
    final t = DateTime.parse(s.validTime).toLocal();
    final key = DateTime(t.year, t.month, t.day);
    (byDay[key] ??= []).add(s);
  }
  final days = byDay.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
  return days.take(7).map((e) {
    final temps = e.value.map((s) => s.temperature).whereType<double>().toList();
    final clouds = e.value.map((s) => s.cloudiness).whereType<double>().toList();
    final minT = temps.isEmpty ? double.nan : temps.reduce((a, b) => a < b ? a : b);
    final maxT = temps.isEmpty ? double.nan : temps.reduce((a, b) => a > b ? a : b);
    final meanC = clouds.isEmpty ? double.nan : clouds.reduce((a, b) => a + b) / clouds.length;
    return DailyForecast(day: e.key, minT: minT, maxT: maxT, meanCloud: meanC);
  }).toList();
}
