import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';
import 'map_layer_utils.dart';

class ProvinceLayer {
  static List<Marker> build(
    MapStatsState state,
    double currentZoom,
    bool isDarkMode,
  ) {
    if (currentZoom >= 11 || state.provinces.isEmpty) return [];

    final List<Marker> markers = [];

    final visibleProvinces = state.provinces.where((p) {
      if (currentZoom <= 7.0) {
        return const [
          'Hà Nội',
          'Hồ Chí Minh',
          'Huế',
          'Hải Phòng',
          'Cần Thơ',
          'Đà Nẵng',
          'Đồng Nai',
        ].contains(p.tenShort);
      } else if (currentZoom <= 7.5) {
        return const [
          'Hà Nội',
          'Hồ Chí Minh',
          'Huế',
          'Hải Phòng',
          'Cần Thơ',
          'Đà Nẵng',
          'Đồng Nai',
          'Bắc Ninh',
          'Ninh Bình',
          'Hưng Yên',
        ].contains(p.tenShort);
      }
      return true;
    }).toList();

    for (var p in visibleProvinces) {
      final bool isCapital = p.tenShort == 'Hà Nội';
      Alignment textAlignment = Alignment.center;
      Offset customOffset = Offset.zero;

      if (p.tenShort == 'Hải Phòng') {
        textAlignment = Alignment.bottomRight;
        customOffset = const Offset(-40, 0);
      } else if (p.tenShort == 'Hưng Yên') {
        textAlignment = Alignment.bottomRight;
        customOffset = const Offset(-25, 10);
      } else if (p.tenShort == 'Ninh Bình' || p.tenShort == 'Đắk Lắk') {
        textAlignment = Alignment.bottomCenter;
        customOffset = const Offset(10, 0);
      } else if ([
        'Bắc Ninh',
        'Huế',
        'Đà Nẵng',
        'Cần Thơ',
      ].contains(p.tenShort)) {
        textAlignment = Alignment.bottomCenter;
        customOffset = const Offset(0, -10);
      } else if (p.tenShort == 'Hà Nội') {
        customOffset = const Offset(0, 15);
      } else if (['Phú Thọ', 'Hồ Chí Minh'].contains(p.tenShort)) {
        customOffset = const Offset(-20, 15);
      }

      // LABEL
      markers.add(
        Marker(
          point: LatLng(p.centroidLat, p.centroidLon),
          width: 150,
          height: 50,
          alignment: textAlignment,
          child: Transform.translate(
            offset: customOffset,
            child: isCapital
                ? MapLayerUtils.buildCapitalLabel(p, isDarkMode)
                : MapLayerUtils.buildNormalLabel(p, isDarkMode),
          ),
        ),
      );

      // HQ ICON
      final isSelected = state.selectedProvince?.ma == p.ma;
      final hasValidHQ = p.hqLat != 0 && p.hqLon != 0;

      if (isSelected && hasValidHQ) {
        markers.add(
          Marker(
            point: LatLng(p.hqLat, p.hqLon),
            width: 28,
            height: 28,
            alignment: Alignment.center,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDarkMode
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF0284C7),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.account_balance,
                size: 14,
                color: isDarkMode
                    ? const Color(0xFF38BDF8)
                    : const Color(0xFF0284C7),
              ),
            ),
          ),
        );
      }
    }

    // ADD ISLAND MARKERS
    markers.add(
      MapLayerUtils.buildIslandMarker(
        'QĐ. HOÀNG SA',
        const LatLng(16.3713479, 112.0785779),
        isDarkMode,
      ),
    );
    markers.add(
      MapLayerUtils.buildIslandMarker(
        'QĐ. TRƯỜNG SA',
        const LatLng(9.2886592, 113.9755647),
        isDarkMode,
      ),
    );

    return markers;
  }
}
