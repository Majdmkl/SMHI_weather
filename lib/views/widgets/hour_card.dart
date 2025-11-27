import 'package:flutter/material.dart';
import '../../models/forecast_model.dart';
import 'cloud_icon.dart';

class HourCard extends StatelessWidget {
  final HourForecast hour;

  const HourCard(this.hour, {super.key});

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${hour.time.hour.toString().padLeft(2, '0')}:'
        '${hour.time.minute.toString().padLeft(2, '0')}';
    final tempStr = '${hour.temperature.toStringAsFixed(1)}°C';

    return ListTile(
      leading: CloudIcon(
        cloudiness: hour.cloudiness,
        precipitation: hour.precipitation,
        windSpeed: hour.windSpeed,
        time: hour.time,
      ),
      title: Text(timeStr),
      trailing: Text(tempStr),
    );
  }
}