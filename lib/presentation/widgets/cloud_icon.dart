import 'package:flutter/material.dart';

class CloudIcon extends StatelessWidget {
  final double cloudiness;    // SMHI tcc_mean (0–8 eller 0–100)
  final double precipitation; // mm/h
  final double windSpeed;     // m/s
  final DateTime? time;       // null => overview (alltid dag-ikon)

  const CloudIcon({
    super.key,
    required this.cloudiness,
    required this.precipitation,
    required this.windSpeed,
    this.time,
  });

  bool get _isNight {
    if (time == null) return false; // översikt: alltid dag
    final h = time!.hour;
    return h < 6 || h >= 20;
  }

  @override
  Widget build(BuildContext context) {
    final isNight = _isNight;

    // --- Normalisera molnigheten till 0..1, oavsett om skalan är 0–8 eller 0–100 ---
    double cover; // 0 = klart, 1 = helt molnigt
    if (cloudiness.isNaN) {
      cover = double.nan;
    } else if (cloudiness <= 8.0) {
      // tcc_mean i oktas (0–8)
      cover = (cloudiness / 8.0).clamp(0.0, 1.0);
    } else {
      // tcc_mean i procent (0–100)
      cover = (cloudiness / 100.0).clamp(0.0, 1.0);
    }

    IconData icon;

    // 1) Nederbörd – snö/regn får gå före moln/vind
    if (precipitation > 0 && cover >= 0.5 && windSpeed < 10) {
      icon = Icons.ac_unit; // "snöigt"
    } else if (precipitation > 0) {
      icon = Icons.grain; // "regnigt"
    }
    // 2) Kraftig vind
    else if (windSpeed >= 12) {
      icon = Icons.air;
    }
    // 3) Molntäcke (huvudlogik)
    else if (cover.isNaN) {
      // ingen info – default klart
      icon = isNight ? Icons.nightlight_round : Icons.wb_sunny_outlined;
    } else if (cover < 0.2) {
      // klart
      icon = isNight ? Icons.nightlight_round : Icons.wb_sunny;
    } else if (cover < 0.7) {
      // halvklar / växlande molnighet
      icon = isNight ? Icons.bedtime : Icons.wb_cloudy_outlined;
    } else {
      // mestadels/molnigt
      icon = Icons.cloud;
    }

    return Icon(icon, size: 28);
  }
}
