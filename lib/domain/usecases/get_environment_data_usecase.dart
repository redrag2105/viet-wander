import 'package:viet_wander/domain/entities/environment.dart';
import 'package:viet_wander/domain/repositories/environment_repository.dart';

class GetEnvironmentDataUseCase {
  final EnvironmentRepository _repository;

  GetEnvironmentDataUseCase(this._repository);

  Future<Environment?> call(double lat, double lon) async {
    if (lat == 0 && lon == 0) return null;

    return await _repository.fetchEnvironmentData(lat, lon);
  }
}
