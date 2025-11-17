import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/daily_forecast.dart';

class DayCard extends StatelessWidget {
  final DailyForecast d;
  const DayCard(this.d, {super.key});

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE d MMM').format(d.day);
    final c = d.meanCloud;
    final icon = c.isNaN ? Icons.help_outline : c < 2 ? Icons.wb_sunny : c < 5 ? Icons.cloud_queue : Icons.cloud;
    final color = c.isNaN ? Colors.grey : c < 2 ? Colors.orangeAccent : c < 5 ? Colors.blueGrey : Colors.blueGrey.shade700;

    return Card(
      child: ListTile(
        leading: Icon(icon, color: color, size: 30),
        title: Text(date),
        subtitle: Text('Min: ${d.minT.toStringAsFixed(1)}°C • Max: ${d.maxT.toStringAsFixed(1)}°C'),
      ),
    );
  }
}
