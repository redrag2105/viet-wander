import 'package:viet_wander/domain/entities/committee.dart';
import 'package:viet_wander/domain/entities/commune.dart';
import 'package:viet_wander/domain/entities/province.dart';

abstract class MapRepository {
  Future<void> initializeData();

  List<Province> getAllProvinces();
  List<Commune> getAllCommunes();
  List<Commune> getCommunesByProvince(String provinceMa);
  List<Committee> getCommitteesByProvince(String provinceMa);
  List<Committee> getAllCommittees();
}
