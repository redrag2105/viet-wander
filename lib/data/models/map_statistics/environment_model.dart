import 'package:viet_wander/domain/entities/environment.dart';

class EnvironmentModel extends Environment {
  const EnvironmentModel({
    required super.temperature,
    required super.humidity,
    required super.description,
    required super.iconCode,
    required super.rain1h,
    required super.aqi,
  });

  factory EnvironmentModel.fromApi({
    required Map<String, dynamic> weatherJson,
    required Map<String, dynamic> aqiJson,
  }) {
    final weatherArray = weatherJson['weather'] as List<dynamic>?;
    final weatherObj = (weatherArray != null && weatherArray.isNotEmpty)
        ? weatherArray[0]
        : {};

    return EnvironmentModel(
      temperature: (weatherJson['main']?['temp'] ?? 0).toDouble(),
      humidity: (weatherJson['main']?['humidity'] ?? 0).toInt(),
      description: weatherObj['description']?.toString() ?? 'Không rõ',
      iconCode: weatherObj['icon']?.toString() ?? '01d',
      rain1h: (weatherJson['rain']?['1h'] ?? 0).toDouble(),
      aqi: (aqiJson['data'] is Map ? aqiJson['data']['aqi'] ?? 0 : 0).toInt(),
    );
  }
}
