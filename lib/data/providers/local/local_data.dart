import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viet_wander/app/services/local_data_service.dart';
import 'package:viet_wander/data/repositories/map_repository_impl.dart';
import 'package:viet_wander/domain/repositories/map_repository.dart';

final localDataServiceProvider = Provider<LocalDataService>((ref) {
  return LocalDataService();
});

final mapRepositoryProvider = Provider<MapRepository>((ref) {
  final service = ref.watch(localDataServiceProvider);
  return MapRepositoryImpl(service);
});
