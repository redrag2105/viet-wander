import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:latlong2/latlong.dart';
import 'package:viet_wander/domain/entities/environment.dart';
import 'package:viet_wander/domain/usecases/get_environment_data_usecase.dart';

class EnvironmentController extends StateNotifier<AsyncValue<Environment?>> {
  final GetEnvironmentDataUseCase _useCase;
  final LatLng location;

  EnvironmentController(this._useCase, this.location)
    : super(const AsyncValue.loading()) {
    _fetchData();
  }

  Future<void> _fetchData() async {
    state = const AsyncValue.loading();
    try {
      final result = await _useCase.call(location.latitude, location.longitude);

      if (mounted) {
        state = AsyncValue.data(result);
      }
    } catch (e, stack) {
      if (mounted) {
        state = AsyncValue.error(e, stack);
      }
    }
  }

  Future<void> refresh() async {
    await _fetchData();
  }
}
