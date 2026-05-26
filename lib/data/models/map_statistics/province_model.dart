import 'package:tiengviet/tiengviet.dart';
import 'package:viet_wander/domain/entities/province.dart';

class ProvinceModel extends Province {
  const ProvinceModel({
    required super.id,
    required super.ma,
    required super.ten,
    required super.tenShort,
    required super.type,
    required super.areaKm2,
    required super.population,
    required super.density,
    required super.capital,
    required super.address,
    required super.decree,
    required super.centroidLat,
    required super.centroidLon,
    required super.searchKey,
    required super.hqLat,
    required super.hqLon,
  });

  factory ProvinceModel.fromJson(Map<String, dynamic> json) {
    final ten = json['ten']?.toString() ?? '';
    return ProvinceModel(
      id: json['id']?.toString() ?? '',
      ma: json['ma']?.toString() ?? '',
      ten: ten,
      tenShort: json['ten_short']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      areaKm2: (json['area_km2'] ?? 0).toDouble(),
      population: (json['population'] ?? 0).toInt(),
      density: (json['density'] ?? 0).toDouble(),
      capital: json['capital']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      decree: json['decree']?.toString() ?? '',
      centroidLat: (json['centroid_lat'] ?? 0).toDouble(),
      centroidLon: (json['centroid_lon'] ?? 0).toDouble(),
      searchKey: TiengViet.parse(ten).toLowerCase(),
      hqLat: (json['hq_lat'] ?? 0).toDouble(),
      hqLon: (json['hq_lon'] ?? 0).toDouble(),
    );
  }
}
