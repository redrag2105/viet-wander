import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viet_wander/app/utils/geojson_helper.dart';

import 'package:viet_wander/data/providers/local/local_data.dart';

// --- Hàm tĩnh chạy ngầm (Isolate) ---
List<BasePolygon> _parseBaseInBackground(String geoJson) {
  return GeoJsonHelper.parseToBasePolygons(geoJson);
}

// --- Provider cung cấp Cache cho Tỉnh ---
final provinceBasePolygonProvider = FutureProvider<List<BasePolygon>>((
  ref,
) async {
  final repo = ref.read(mapRepositoryProvider);
  await repo.initializeData();

  final service = ref.read(localDataServiceProvider);
  if (service.provinceGeoJsonStr.isEmpty) return [];

  return await compute(_parseBaseInBackground, service.provinceGeoJsonStr);
});

// --- Provider cung cấp Cache cho Xã ---
final communeBasePolygonProvider = FutureProvider<List<BasePolygon>>((
  ref,
) async {
  final repo = ref.read(mapRepositoryProvider);
  await repo.initializeData();

  final service = ref.read(localDataServiceProvider);
  if (service.communeGeoJsonStr.isEmpty) return [];

  return await compute(_parseBaseInBackground, service.communeGeoJsonStr);
});
