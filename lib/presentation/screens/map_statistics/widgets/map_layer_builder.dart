import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:viet_wander/domain/entities/province.dart';
import 'package:viet_wander/domain/entities/committee.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';
import 'package:viet_wander/app/utils/geojson_helper.dart';

class MapLayerBuilders {
  // --- 1. BUILD LABELS (TÊN TỈNH) ---
  static List<Marker> buildProvinceLabels(
    MapStatsState state,
    double currentZoom,
    bool isDarkMode,
  ) {
    if (currentZoom >= 11 || state.provinces.isEmpty) return [];

    return state.provinces
        .where((p) {
          if (currentZoom <= 7.0) {
            return const [
              'Hà Nội',
              'Hồ Chí Minh',
              'Huế',
              'Hải Phòng',
              'Cần Thơ',
              'Đà Nẵng',
            ].contains(p.tenShort);
          } else if (currentZoom <= 7.5) {
            return const [
              'Hà Nội',
              'Hồ Chí Minh',
              'Huế',
              'Hải Phòng',
              'Cần Thơ',
              'Đà Nẵng',
              'Bắc Ninh',
              'Ninh Bình',
              'Hưng Yên',
            ].contains(p.tenShort);
          }
          return true;
        })
        .map((p) {
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
          } else if (p.tenShort == 'Bắc Ninh' ||
              p.tenShort == 'Huế' ||
              p.tenShort == 'Đà Nẵng' ||
              p.tenShort == 'Cần Thơ') {
            textAlignment = Alignment.bottomCenter;
            customOffset = const Offset(0, -10);
          } else if (p.tenShort == 'Hà Nội') {
            customOffset = const Offset(0, 15);
          } else if (p.tenShort == 'Phú Thọ' || p.tenShort == 'Hồ Chí Minh') {
            customOffset = const Offset(-20, 15);
          }

          return Marker(
            point: LatLng(p.centroidLat, p.centroidLon),
            width: 150,
            height: 50,
            alignment: textAlignment,
            child: Transform.translate(
              offset: customOffset,
              child: isCapital
                  ? _buildCapitalLabel(p, isDarkMode)
                  : _buildNormalLabel(p, isDarkMode),
            ),
          );
        })
        .toList();
  }

  // --- 2. BUILD MARKERS (CHẤM ĐỎ UBND) ---
  static List<Marker> buildCommitteeMarkers(MapStatsState state) {
    if (!state.isDetailMode ||
        state.committees.isEmpty ||
        state.selectedCommune == null) {
      return [];
    }

    // Only show committee for the selected commune. We match by comparing the names.
    final targetCommuneName = state.selectedCommune!.ten.toLowerCase();

    // Tìm committee phù hợp (Ủy ban nhân dân Xã X có chứa chữ Xã X)
    final matchedCommittees = state.committees.where((c) {
      return c.ten.toLowerCase().contains(targetCommuneName);
    }).toList();

    return matchedCommittees.map((Committee committee) {
      return Marker(
        point: LatLng(committee.centroidLat, committee.centroidLon),
        width: 12,
        height: 12,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // --- HÀM PHỤ TRỢ UI CHO LABELS ---
  static List<Shadow> _getTextHalo(bool isDarkMode) {
    final Color haloColor = isDarkMode ? Colors.black87 : Colors.white;
    return [
      Shadow(offset: const Offset(-1.5, -1.5), color: haloColor),
      Shadow(offset: const Offset(1.5, -1.5), color: haloColor),
      Shadow(offset: const Offset(-1.5, 1.5), color: haloColor),
      Shadow(offset: const Offset(1.5, 1.5), color: haloColor),
    ];
  }

  static Widget _buildCapitalLabel(Province p, bool isDarkMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          color: isDarkMode ? Colors.yellowAccent : Colors.red,
          size: 16,
        ),
        Text(
          p.tenShort.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Times New Roman',
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            shadows: _getTextHalo(isDarkMode),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget _buildNormalLabel(Province p, bool isDarkMode) {
    return Text(
      p.tenShort.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Times New Roman',
        color: isDarkMode ? Colors.white : Colors.black87,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        shadows: _getTextHalo(isDarkMode),
      ),
      textAlign: TextAlign.center,
    );
  }

  // --- 3. BUILD COMMUNE LABELS ---
  static List<Marker> buildCommuneLabels(
    MapStatsState state,
    double currentZoom,
    bool isDarkMode,
    List<BasePolygon>? communePolygons,
  ) {
    if (currentZoom < 11 || state.communes.isEmpty || communePolygons == null) {
      return [];
    }

    // Build a map of ma -> name for O(1) lookup
    final communeNameMap = <String, String>{};
    for (var commune in state.communes) {
      communeNameMap[commune.ma] = commune.ten;
    }

    final List<Marker> markers = [];
    final Set<String> processedMa =
        {}; // Dùng Set để tránh hiện tên nhiều lần cho MultiPolygon

    for (var poly in communePolygons) {
      if (communeNameMap.containsKey(poly.ma) &&
          !processedMa.contains(poly.ma)) {
        processedMa.add(poly.ma);
        final communeName = communeNameMap[poly.ma]!;

        markers.add(
          Marker(
            point: poly.centroid,
            width: 120,
            height: 30,
            alignment: Alignment.center,
            child: Text(
              communeName,
              style: TextStyle(
                color: isDarkMode ? Colors.white70 : Colors.black87,
                fontSize: 10,
                fontWeight: FontWeight.w500,
                shadows: _getTextHalo(isDarkMode),
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
