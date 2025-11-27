import 'package:flutter/material.dart';
import '../../models/forecast_model.dart';
import 'cloud_icon.dart';
import 'hour_card.dart';

class DayCard extends StatelessWidget {
  final DailyForecast day;

  const DayCard(this.day, {super.key});

  String _formatDate(DateTime d) {
    const wk = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final w = wk[d.weekday % 7];
    final dd = d.day.toString().padLeft(2, '0');
    final mm = months[d.month - 1];
    return '$w $dd $mm';
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = _formatDate(day.day);
    final minStr = day.minT.isNaN ? '-' : '${day.minT.toStringAsFixed(1)}°C';
    final maxStr = day.maxT.isNaN ? '-' : '${day.maxT.toStringAsFixed(1)}°C';

    final header = ListTile(
      leading: CloudIcon(
        cloudiness: day.meanCloud,
        precipitation: day.meanPrecip,
        windSpeed: day.meanWind,
      ),
      title: Text(dateStr),
      subtitle: Text('Min: $minStr • Max: $maxStr'),
    );

    if (day.hourly.isEmpty) {
      return Card(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: header,
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        children: [
          header,
          const Divider(height: 0),
          ...day.hourly.map((h) => HourCard(h)),
        ],
      ),
    );
  }
}