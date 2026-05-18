import 'package:viet_wander/app/services/local_data_service.dart';
import 'package:viet_wander/domain/entities/committee.dart';
import 'package:viet_wander/domain/entities/commune.dart';
import 'package:viet_wander/domain/entities/province.dart';
import 'package:viet_wander/domain/repositories/map_repository.dart';

class MapRepositoryImpl implements MapRepository {
  final LocalDataService _localDataService;

  MapRepositoryImpl(this._localDataService);

  @override
  Future<void> initializeData() async {
    await _localDataService.initData();
  }

  @override
  List<Province> getAllProvinces() {
    return _localDataService.getAllProvinces();
  }

  @override
  List<Commune> getAllCommunes() {
    return _localDataService.getAllCommunes();
  }

  @override
  List<Commune> getCommunesByProvince(String provinceMa) {
    return _localDataService.getCommunesByProvince(provinceMa);
  }

  @override
  List<Committee> getCommitteesByProvince(String provinceMa) {
    return _localDataService.getCommitteesByProvince(provinceMa);
  }

  @override
  List<Committee> getAllCommittees() {
    return _localDataService.getAllCommittees();
  }
}
