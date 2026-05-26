import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:latlong2/latlong.dart';
import 'package:viet_wander/data/repositories/environment_repository_impl.dart';
import 'package:viet_wander/domain/entities/environment.dart';
import 'package:viet_wander/domain/repositories/environment_repository.dart';
import 'package:viet_wander/domain/usecases/get_environment_data_usecase.dart';
import 'package:viet_wander/presentation/controllers/environment/environment_controller.dart';

final environmentRepositoryProvider = Provider<EnvironmentRepository>((ref) {
  return EnvironmentRepositoryImpl();
});

final getEnvironmentDataUseCaseProvider = Provider<GetEnvironmentDataUseCase>((
  ref,
) {
  final repository = ref.read(environmentRepositoryProvider);
  return GetEnvironmentDataUseCase(repository);
});

final environmentControllerProvider = StateNotifierProvider.autoDispose
    .family<EnvironmentController, AsyncValue<Environment?>, LatLng>((
      ref,
      location,
    ) {
      final useCase = ref.read(getEnvironmentDataUseCaseProvider);
      return EnvironmentController(useCase, location);
    });
