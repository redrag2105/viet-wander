import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:viet_wander/data/models/map_statistics/committee_model.dart';
import 'package:viet_wander/data/models/map_statistics/commune_model.dart';
import 'package:viet_wander/data/models/map_statistics/province_model.dart';

List<ProvinceModel> _parseProvinces(String rawString) {
  final cleanString = rawString.replaceAll(': NaN', ': null');
  final List<dynamic> parsed = jsonDecode(cleanString);
  return parsed.map((json) => ProvinceModel.fromJson(json)).toList();
}

List<CommuneModel> _parseCommunes(String rawString) {
  final cleanString = rawString.replaceAll(': NaN', ': null');
  final List<dynamic> parsed = jsonDecode(cleanString);
  return parsed.map((json) => CommuneModel.fromJson(json)).toList();
}

List<CommitteeModel> _parseCommittees(String rawString) {
  final cleanString = rawString.replaceAll(': NaN', ': null');
  final List<dynamic> parsed = jsonDecode(cleanString);
  return parsed.map((json) => CommitteeModel.fromJson(json)).toList();
}

String _cleanGeoJson(String rawString) {
  return rawString.replaceAll(': NaN', ': null');
}

// --- MAIN SERVICE ---
class LocalDataService {
  static final LocalDataService _instance = LocalDataService._internal();
  factory LocalDataService() => _instance;
  LocalDataService._internal();

  List<ProvinceModel> _provinces = [];
  List<CommuneModel> _communes = [];
  List<CommitteeModel> _committees = [];

  String _provinceGeoJsonStr = '';
  String _communeGeoJsonStr = '';

  String get provinceGeoJsonStr => _provinceGeoJsonStr;
  String get communeGeoJsonStr => _communeGeoJsonStr;

  Future<void>? _initTask;

  Future<void> initData() {
    if (_initTask != null) return _initTask!;

    _initTask = _performInit();
    return _initTask!;
  }

  Future<void> _performInit() async {
    try {
      final provinceRaw = await rootBundle.loadString(
        'assets/data/provinces.json',
        cache: false,
      );
      final communeRaw = await rootBundle.loadString(
        'assets/data/communes.json',
        cache: false,
      );
      final committeeRaw = await rootBundle.loadString(
        'assets/data/committees.json',
        cache: false,
      );
      final provinceGeoRaw = await rootBundle.loadString(
        'assets/data/provinces.geojson',
        cache: false,
      );
      final communeGeoRaw = await rootBundle.loadString(
        'assets/data/communes.geojson',
        cache: false,
      );

      final result = await Isolate.run(() {
        return (
          provinces: _parseProvinces(provinceRaw),
          communes: _parseCommunes(communeRaw),
          committees: _parseCommittees(committeeRaw),
          provinceGeo: _cleanGeoJson(provinceGeoRaw),
          communeGeo: _cleanGeoJson(communeGeoRaw),
        );
      });

      _provinces = result.provinces;
      _communes = result.communes;
      _committees = result.committees;
      _provinceGeoJsonStr = result.provinceGeo;
      _communeGeoJsonStr = result.communeGeo;

      debugPrint('✅ Khởi tạo dữ liệu Local thành công!');
    } catch (e) {
      _initTask = null;
      debugPrint('❌ Lỗi khi tải dữ liệu Local: $e');
      rethrow;
    }
  }

  List<ProvinceModel> getAllProvinces() => _provinces;
  List<CommuneModel> getAllCommunes() => _communes;
  List<CommuneModel> getCommunesByProvince(String provinceMa) {
    return _communes.where((c) => c.parentMa == provinceMa).toList();
  }

  List<CommitteeModel> getCommitteesByProvince(String provinceMa) {
    return _committees.where((c) => c.parentMa == provinceMa).toList();
  }

  List<CommitteeModel> getAllCommittees() => _committees;
}
