import 'package:tiengviet/tiengviet.dart';
import 'package:viet_wander/domain/entities/commune.dart';

class CommuneModel extends Commune {
  const CommuneModel({
    required super.id,
    required super.ma,
    required super.parentMa,
    required super.ten,
    required super.areaKm2,
    required super.population,
    required super.density,
    required super.capital,
    required super.decree,
    required super.searchKey,
  });

  factory CommuneModel.fromJson(Map<String, dynamic> json) {
    final ten = json['ten']?.toString() ?? '';
    return CommuneModel(
      id: json['id']?.toString() ?? '',
      ma: json['ma']?.toString() ?? '',
      parentMa: json['parent_ma']?.toString() ?? '',
      ten: ten,
      areaKm2: (json['area_km2'] ?? 0).toDouble(),
      population: (json['population'] ?? 0).toInt(),
      density: (json['density'] ?? 0).toDouble(),
      capital: json['capital']?.toString() ?? '',
      decree: json['decree']?.toString() ?? '',
      searchKey: TiengViet.parse(ten).toLowerCase(),
    );
  }
}
