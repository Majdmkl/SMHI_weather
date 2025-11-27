import 'package:flutter/material.dart';

class CloudIcon extends StatelessWidget {
  final double cloudiness;
  final double precipitation;
  final double windSpeed;
  final DateTime? time;

  const CloudIcon({
    super.key,
    required this.cloudiness,
    required this.precipitation,
    required this.windSpeed,
    this.time,
  });

  bool get _isNight {
    if (time == null) return false;
    final h = time!.hour;
    return h < 6 || h >= 20;
  }

  @override
  Widget build(BuildContext context) {
    final isNight = _isNight;

    double cover;
    if (cloudiness.isNaN) {
      cover = double.nan;
    } else if (cloudiness <= 8.0) {
      cover = (cloudiness / 8.0).clamp(0.0, 1.0);
    } else {
      cover = (cloudiness / 100.0).clamp(0.0, 1.0);
    }

    IconData icon;

    if (precipitation > 0 && cover >= 0.5 && windSpeed < 10) {
      icon = Icons.ac_unit;
    } else if (precipitation > 0) {
      icon = Icons.grain;
    } else if (windSpeed >= 12) {
      icon = Icons.air;
    } else if (cover.isNaN) {
      icon = isNight ? Icons.nightlight_round : Icons.wb_sunny_outlined;
    } else if (cover < 0.2) {
      icon = isNight ? Icons.nightlight_round : Icons.wb_sunny;
    } else if (cover < 0.7) {
      icon = isNight ? Icons.bedtime : Icons.wb_cloudy_outlined;
    } else {
      icon = Icons.cloud;
    }

    return Icon(icon, size: 28);
  }
}