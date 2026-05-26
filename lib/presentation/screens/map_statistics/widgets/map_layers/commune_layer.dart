import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:viet_wander/app/utils/geojson_helper.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';
import 'map_layer_utils.dart';

class CommuneLayer {
  static List<Marker> build(
    MapStatsState state,
    double currentZoom,
    bool isDarkMode,
    List<BasePolygon>? communePolygons,
  ) {
    if (currentZoom < 11 || communePolygons == null) return [];

    final List<Marker> markers = [];
    final Set<String> processedMa = {};

    for (var poly in communePolygons) {
      if (poly.ten.isNotEmpty && !processedMa.contains(poly.ma)) {
        processedMa.add(poly.ma);
        markers.add(
          Marker(
            point: poly.centroid,
            width: 120,
            height: 30,
            alignment: Alignment.center,
            child: Text(
              poly.ten,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                shadows: MapLayerUtils.getTextHalo(isDarkMode),
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        );
      }
    }
    return markers;
  }
}
