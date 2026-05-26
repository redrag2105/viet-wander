import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class BasePolygon {
  final String ma;
  final String ten;
  final List<LatLng> points;
  late final LatLng centroid;
  final double density;

  BasePolygon({
    required this.ma,
    required this.points,
    this.ten = '',
    this.density = 0.0,
  }) {
    if (points.isEmpty) {
      centroid = const LatLng(0, 0);
    } else {
      double minLat = points.first.latitude;
      double maxLat = points.first.latitude;
      double minLng = points.first.longitude;
      double maxLng = points.first.longitude;
      for (final p in points) {
        if (p.latitude < minLat) minLat = p.latitude;
        if (p.latitude > maxLat) maxLat = p.latitude;
        if (p.longitude < minLng) minLng = p.longitude;
        if (p.longitude > maxLng) maxLng = p.longitude;
      }
      centroid = LatLng((minLat + maxLat) / 2, (minLng + maxLng) / 2);
    }
  }
}

class GeoJsonHelper {
  static List<Polygon> buildPolygonsFromBase({
    required List<BasePolygon> basePolygons,
    required Color fillColor,
    required Color borderColor,
    required double borderStrokeWidth,
    bool isDarkMode = false,
    String? selectedMa,
    Color? highlightColor,
    Map<String, Color>? customColors,
  }) {
    final lightPalette = [
      const Color(0xFFFCA5A5),
      const Color(0xFFFCD34D),
      const Color(0xFFFDE047),
      const Color(0xFF86EFAC),
      const Color(0xFF67E8F9),
      const Color(0xFF93C5FD),
      const Color(0xFFA5B4FC),
      const Color(0xFFC4B5FD),
      const Color(0xFFD8B4FE),
      const Color(0xFFF9A8D4),
      const Color(0xFFF0ABFC),
      const Color(0xFFFDA4AF),
    ];
    final darkPalette = [
      const Color(0xFF991B1B),
      const Color(0xFF9A3412),
      const Color(0xFF854D0E),
      const Color(0xFF166534),
      const Color(0xFF155E75),
      const Color(0xFF1E40AF),
      const Color(0xFF3730A3),
      const Color(0xFF5B21B6),
      const Color(0xFF86198F),
      const Color(0xFF9D174D),
      const Color(0xFF065F46),
      const Color(0xFF115E59),
    ];
    final palette = isDarkMode ? darkPalette : lightPalette;

    return basePolygons.map((base) {
      final int code = base.ma.hashCode.abs();
      Color polygonColor;
      double currentStroke = borderStrokeWidth;

      // Density mode
      if (customColors != null) {
        String normalizedMa = int.tryParse(base.ma)?.toString() ?? base.ma;

        if (customColors.containsKey(base.ma) ||
            customColors.containsKey(normalizedMa)) {
          Color heatColor =
              customColors[base.ma] ?? customColors[normalizedMa]!;
          if (selectedMa != null) {
            if (base.ma == selectedMa) {
              polygonColor = heatColor;
              currentStroke += 1.5;
            } else {
              polygonColor = heatColor.withValues(alpha: 0.15);
            }
          } else {
            polygonColor = heatColor.withValues(alpha: 0.8);
          }
        } else {
          polygonColor = Colors.transparent;
        }
      }
      // Satellite/Street mode
      else if (fillColor == Colors.transparent) {
        if (selectedMa != null && base.ma == selectedMa) {
          polygonColor = (highlightColor ?? Colors.amber).withValues(
            alpha: 0.3,
          );
          currentStroke += 1.25;
        } else {
          polygonColor = Colors.transparent;
        }
      }
      // Minimal mode
      else {
        if (selectedMa != null && base.ma == selectedMa) {
          polygonColor = palette[code % palette.length].withValues(
            alpha: isDarkMode ? 0.6 : 0.8,
          );
          currentStroke += 1.25;
        } else {
          polygonColor = palette[code % palette.length].withValues(
            alpha: isDarkMode ? 0.45 : 0.54,
          );
          if (selectedMa != null) {
            polygonColor = polygonColor.withValues(
              alpha: isDarkMode ? 0.1 : 0.15,
            );
          }
        }
      }

      return Polygon(
        points: base.points,
        color: polygonColor,
        borderColor: borderColor,
        borderStrokeWidth: currentStroke > 0 ? currentStroke : 0.1,
      );
    }).toList();
  }

  static List<BasePolygon> parseToBasePolygons(String geoJsonString) {
    final List<BasePolygon> polygons = [];
    final parsed = jsonDecode(geoJsonString);

    if (parsed['type'] != 'FeatureCollection') return [];
    final features = parsed['features'] as List<dynamic>;

    for (var feature in features) {
      final geometry = feature['geometry'];
      final type = geometry['type'];
      final coordinates = geometry['coordinates'] as List<dynamic>;

      final properties = feature['properties'] ?? {};
      final String codeStr =
          properties['ma']?.toString() ??
          properties['id']?.toString() ??
          properties['ten']?.toString() ??
          '0';
      final String tenStr = properties['ten']?.toString() ?? '';

      final double densityVal = (properties['density'] ?? 0).toDouble();

      if (type == 'MultiPolygon') {
        for (var polygonCoords in coordinates) {
          polygons.add(
            BasePolygon(
              ma: codeStr,
              ten: tenStr,
              density: densityVal,
              points: _createPoints(polygonCoords[0]),
            ),
          );
        }
      } else if (type == 'Polygon') {
        for (var ring in coordinates) {
          polygons.add(
            BasePolygon(
              ma: codeStr,
              ten: tenStr,
              points: _createPoints(ring),
              density: densityVal,
            ),
          );
        }
      }
    }

    return polygons;
  }

  static List<LatLng> _createPoints(List<dynamic> ring) {
    return ring.map((coord) {
      return LatLng(coord[1].toDouble(), coord[0].toDouble());
    }).toList();
  }

  static bool isPointInsidePolygon(LatLng point, List<LatLng> vertices) {
    int intersectCount = 0;
    for (int i = 0; i < vertices.length - 1; i++) {
      final p1 = vertices[i];
      final p2 = vertices[i + 1];

      // Kiểm tra tia phóng ngang có cắt qua đoạn thẳng (p1, p2) không
      if (((p1.latitude > point.latitude) != (p2.latitude > point.latitude)) &&
          (point.longitude <
              (p2.longitude - p1.longitude) *
                      (point.latitude - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersectCount++;
      }
    }
    // Lẻ lần cắt = Nằm trong; Chẵn lần cắt = Nằm ngoài
    return intersectCount % 2 != 0;
  }
}
