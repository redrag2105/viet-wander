import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:viet_wander/data/models/map_statistics/environment_model.dart';
import 'package:viet_wander/domain/entities/environment.dart';
import 'package:viet_wander/domain/repositories/environment_repository.dart';

class EnvironmentRepositoryImpl implements EnvironmentRepository {
  final Dio _dio;

  static const String _owmKey = '42086bf5c9b7e1d0061ecf7e53078fd1';
  static const String _waqiKey = '07cee11eadc21dc407e533ab2b6012a72d2bab7c';

  EnvironmentRepositoryImpl({Dio? dio}) : _dio = dio ?? Dio() {
    _dio.options.connectTimeout = const Duration(seconds: 10);
    _dio.options.receiveTimeout = const Duration(seconds: 10);
  }

  @override
  Future<Environment?> fetchEnvironmentData(double lat, double lon) async {
    try {
      final responses = await Future.wait([
        _dio.get(
          'https://api.openweathermap.org/data/2.5/weather',
          queryParameters: {
            'lat': lat,
            'lon': lon,
            'appid': _owmKey,
            'units': 'metric',
            'lang': 'vi',
          },
        ),
        _dio.get(
          'https://api.waqi.info/feed/geo:$lat;$lon/',
          queryParameters: {'token': _waqiKey},
        ),
      ]);

      final weatherRes = responses[0];
      final aqiRes = responses[1];

      if (weatherRes.statusCode == 200 && aqiRes.statusCode == 200) {
        return EnvironmentModel.fromApi(
          weatherJson: weatherRes.data,
          aqiJson: aqiRes.data,
        );
      }
      return null;
    } on DioException catch (e) {
      debugPrint('❌ Lỗi mạng (Dio) khi gọi dữ liệu môi trường: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('❌ Lỗi không xác định tại EnvironmentRepositoryImpl: $e');
      return null;
    }
  }
}
