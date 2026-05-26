import 'package:flutter/material.dart';

class Environment {
  final double temperature;
  final int humidity;
  final String description;
  final String iconCode;
  final double rain1h;
  final int aqi;

  const Environment({
    required this.temperature,
    required this.humidity,
    required this.description,
    required this.iconCode,
    required this.rain1h,
    required this.aqi,
  });

  ({String status, Color color}) get aqiInfo {
    if (aqi <= 50) return (status: 'Tốt', color: Colors.green);
    if (aqi <= 100) {
      return (status: 'Trung bình', color: Colors.yellow.shade700);
    }
    if (aqi <= 150) return (status: 'Kém', color: Colors.orange);
    if (aqi <= 200) return (status: 'Xấu', color: Colors.red);
    if (aqi <= 300) return (status: 'Rất xấu', color: Colors.purple);
    return (status: 'Nguy hại', color: Colors.brown);
  }
}
