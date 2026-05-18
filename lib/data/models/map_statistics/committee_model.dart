import 'package:tiengviet/tiengviet.dart';
import 'package:viet_wander/domain/entities/committee.dart';

class CommitteeModel extends Committee {
  const CommitteeModel({
    required super.id,
    required super.ma,
    required super.parentMa,
    required super.ten,
    required super.type,
    required super.centroidLon,
    required super.centroidLat,
    required super.searchKey,
  });

  factory CommitteeModel.fromJson(Map<String, dynamic> json) {
    final ten = json['ten']?.toString() ?? '';
    return CommitteeModel(
      id: json['id']?.toString() ?? '',
      ma: json['ma']?.toString() ?? '',
      parentMa: json['parent_ma']?.toString() ?? '',
      ten: ten,
      type: json['type']?.toString() ?? '',
      centroidLon: (json['centroid_lon'] ?? 0).toDouble(),
      centroidLat: (json['centroid_lat'] ?? 0).toDouble(),
      searchKey: TiengViet.parse(ten).toLowerCase(),
    );
  }
}
