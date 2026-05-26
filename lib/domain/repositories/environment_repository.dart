import 'package:viet_wander/domain/entities/environment.dart';

abstract class EnvironmentRepository {
  Future<Environment?> fetchEnvironmentData(double lat, double lon);
}
