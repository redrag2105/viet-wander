import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:viet_wander/app/config/app_config.dart';
import 'package:viet_wander/app/utils/geojson_helper.dart';
import 'package:viet_wander/data/providers/polygon_provider.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';
import 'package:viet_wander/presentation/screens/map_statistics/utils/map_animation_extension.dart';

import 'map_panel.dart';

mixin MapPanelLogic on ConsumerState<MapPanel> {
  final MapController mapController = MapController();
  double currentZoom = 6.0;
  bool isDarkMode = false;

  bool showZoomIndicator = false;
  Timer? zoomTimer;

  void triggerZoomIndicator() {
    if (!mounted) return;
    setState(() => showZoomIndicator = true);

    zoomTimer?.cancel();
    zoomTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => showZoomIndicator = false);
    });
  }

  TickerProvider get tickerProvider => this as TickerProvider;

  void toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }

  void handleZoomChange(MapCamera camera, bool hasGesture) {
    int getZoomTier(double zoom) {
      if (zoom <= 7.0) return 1;
      if (zoom <= 7.5) return 2;
      if (zoom < 11) return 3;
      return 4;
    }

    int oldTier = getZoomTier(currentZoom);
    int newTier = getZoomTier(camera.zoom);

    if (oldTier != newTier) {
      setState(() => currentZoom = camera.zoom);
      if (hasGesture) triggerZoomIndicator();
    } else if (currentZoom != camera.zoom) {
      currentZoom = camera.zoom;

      if (hasGesture) {
        setState(() {});
        triggerZoomIndicator();
      }
    }
  }

  double _getProvinceTargetZoom(double area) {
    if (area > 12000) return 8.75;
    if (area > 8500) return 9.25;
    if (area > 7000) return 9.5;
    return 10.0;
  }

  double _getCommuneTargetZoom(double area) {
    if (area > 800) return 11.0;
    if (area > 600) return 11.25;
    if (area > 400) return 11.5;
    if (area > 200) return 11.75;
    if (area > 100) return 12.0;
    if (area > 50) return 12.5;
    if (area > 25) return 12.75;
    return 13.5;
  }

  LatLng _getOffsetCenter(LatLng target, double targetZoom) {
    final double sidebarWidth = widget.rightMargin;
    if (sidebarWidth <= 0) return target;

    final double shiftX = sidebarWidth / 2.0;

    final Offset projectedPoint = mapController.camera.projectAtZoom(
      target,
      targetZoom,
    );
    final Offset offsetPoint = Offset(
      projectedPoint.dx + shiftX,
      projectedPoint.dy,
    );
    final LatLng rawOffsetCenter = mapController.camera.unprojectAtZoom(
      offsetPoint,
      targetZoom,
    );

    if (AppConfig.mapBounds.contains(rawOffsetCenter)) {
      return rawOffsetCenter;
    } else {
      return target;
    }
  }

  void listenToMapStateChanges(MapStatsState? previous, MapStatsState next) {
    final oldCommuneMa = previous?.selectedCommune?.ma;
    final newCommuneMa = next.selectedCommune?.ma;
    final oldProvinceMa = previous?.selectedProvince?.ma;
    final newProvinceMa = next.selectedProvince?.ma;

    if (oldCommuneMa != newCommuneMa && next.selectedCommune != null) {
      final communePolysInfo = ref
          .read(communeBasePolygonProvider)
          .whenOrNull(data: (d) => d);
      final poly = communePolysInfo
          ?.where((p) => p.ma == newCommuneMa)
          .firstOrNull;

      if (poly != null && poly.points.isNotEmpty) {
        final double targetZoom = _getCommuneTargetZoom(
          next.selectedCommune!.areaKm2,
        );
        final LatLng offsetCenter = _getOffsetCenter(poly.centroid, targetZoom);
        mapController.animatedMove(offsetCenter, targetZoom, tickerProvider);
      }
    } else if ((oldCommuneMa != newCommuneMa &&
            next.selectedCommune == null &&
            next.selectedProvince != null) ||
        (oldProvinceMa != newProvinceMa && next.selectedProvince != null)) {
      final targetZoom = _getProvinceTargetZoom(next.selectedProvince!.areaKm2);
      final LatLng rawCenter = LatLng(
        next.selectedProvince!.centroidLat,
        next.selectedProvince!.centroidLon,
      );

      final LatLng offsetCenter = _getOffsetCenter(rawCenter, targetZoom);
      mapController.animatedMove(offsetCenter, targetZoom, tickerProvider);
    } else if ((oldCommuneMa != newCommuneMa ||
            oldProvinceMa != newProvinceMa) &&
        next.selectedCommune == null &&
        next.selectedProvince == null) {
      mapController.animatedMove(
        AppConfig.defaultMapCenter,
        AppConfig.defaultMapZoom,
        tickerProvider,
        duration: const Duration(milliseconds: 1250),
      );
    }
  }

  // --- Click Event (RAY-CASTING) ---
  void handleMapTap(TapPosition tapPosition, LatLng point) {
    final isZoomedIn = currentZoom >= 11;
    final controller = ref.read(mapStatsControllerProvider.notifier);

    if (isZoomedIn) {
      ref.read(communeBasePolygonProvider).whenData((basePolygons) {
        String? clickedMa;
        for (var poly in basePolygons) {
          if (GeoJsonHelper.isPointInsidePolygon(point, poly.points)) {
            clickedMa = poly.ma;
            break;
          }
        }
        controller.selectCommuneByMa(clickedMa ?? '');
      });
    } else {
      ref.read(provinceBasePolygonProvider).whenData((basePolygons) {
        String? clickedMa;
        for (var poly in basePolygons) {
          if (GeoJsonHelper.isPointInsidePolygon(point, poly.points)) {
            clickedMa = poly.ma;
            break;
          }
        }

        if (clickedMa == null) {
          ref.read(communeBasePolygonProvider).whenData((communes) {
            for (var poly in communes) {
              if ((poly.ma == '20333' || poly.ma == '22736') &&
                  GeoJsonHelper.isPointInsidePolygon(point, poly.points)) {
                clickedMa = poly.ma == '20333' ? '48' : '56';
                break;
              }
            }
          });
        }

        clickedMa != null
            ? controller.selectProvinceByMa(clickedMa!)
            : controller.resetToListView();
      });
    }
  }

  // --- POLYGON ---
  List<Polygon> buildPolygons(MapStatsState state) {
    final isZoomedIn = currentZoom >= 11;
    final mode = state.currentMapMode;

    Color fillColor;
    if (mode == MapViewMode.street || mode == MapViewMode.satellite) {
      fillColor = Colors.transparent;
    } else {
      fillColor = isDarkMode
          ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
          : const Color(0xFF0EA5E9).withValues(alpha: 0.25);
    }

    final borderColor = isDarkMode
        ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
        : const Color(0xFF0284C7).withValues(alpha: 0.8);
    final highlightColor = isDarkMode ? Colors.amber : Colors.deepOrange;

    if (isZoomedIn) {
      return ref
          .watch(communeBasePolygonProvider)
          .maybeWhen(
            data: (basePolygons) {
              Map<String, Color>? heatColors;
              if (mode == MapViewMode.density) {
                heatColors = {};
                for (var poly in basePolygons) {
                  heatColors[poly.ma] = _getDensityColor(
                    poly.density,
                    isCommune: true,
                  );
                }
              }
              return GeoJsonHelper.buildPolygonsFromBase(
                basePolygons: basePolygons,
                fillColor: fillColor,
                borderColor: borderColor,
                borderStrokeWidth: 1.0,
                isDarkMode: isDarkMode,
                selectedMa: state.selectedCommune?.ma,
                highlightColor: highlightColor,
                customColors: heatColors,
              );
            },
            orElse: () => [],
          );
    } else {
      return ref
          .watch(provinceBasePolygonProvider)
          .maybeWhen(
            data: (provincePolygons) {
              final combinedPolys = List<BasePolygon>.from(provincePolygons);
              ref.read(communeBasePolygonProvider).whenData((communes) {
                final islands = communes.where(
                  (p) => p.ma == '20333' || p.ma == '22736',
                );
                combinedPolys.addAll(islands);
              });

              Map<String, Color>? heatColors;
              if (mode == MapViewMode.density) {
                heatColors = {};
                for (var poly in combinedPolys) {
                  heatColors[poly.ma] = _getDensityColor(
                    poly.density,
                    isCommune: false,
                  );
                }
              }

              return GeoJsonHelper.buildPolygonsFromBase(
                basePolygons: combinedPolys,
                fillColor: fillColor,
                borderColor: borderColor,
                borderStrokeWidth: 1.5,
                isDarkMode: isDarkMode,
                selectedMa: state.selectedProvince?.ma,
                highlightColor: highlightColor,
                customColors: heatColors,
              );
            },
            orElse: () => [],
          );
    }
  }

  Color _getDensityColor(double density, {bool isCommune = false}) {
    if (isCommune) {
      // Communes
      if (density >= 35000) return const Color(0xFF4C0519);
      if (density >= 25000) return const Color(0xFF881337);
      if (density >= 15000) return const Color(0xFFBE123C);
      if (density >= 10000) return const Color(0xFFE11D48);
      if (density >= 7000) return const Color(0xFFF43F5E);
      if (density >= 4000) return const Color(0xFFF97316);
      if (density >= 2000) return const Color(0xFFF59E0B);
      if (density >= 1000) return const Color(0xFFFBBF24);
      if (density >= 500) return const Color(0xFFFDE047);
      return const Color(0xFFFEF08A).withValues(alpha: 0.6);
    } else {
      // provinces
      if (density >= 2500) return const Color(0xFF4C0519);
      if (density >= 2000) return const Color(0xFF881337);
      if (density >= 1500) return const Color(0xFFBE123C);
      if (density >= 1000) return const Color(0xFFE11D48);
      if (density >= 750) return const Color(0xFFF43F5E);
      if (density >= 500) return const Color(0xFFF97316);
      if (density >= 350) return const Color(0xFFF59E0B);
      if (density >= 200) return const Color(0xFFFBBF24);
      if (density >= 100) return const Color(0xFFFDE047);
      return const Color(0xFFFEF08A).withValues(alpha: 0.6);
    }
  }

  // --- LAYER URL GENERATOR ---
  String getTileUrl(MapViewMode mode, bool isDark) {
    switch (mode) {
      case MapViewMode.minimal || MapViewMode.density:
        return isDark
            ? 'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png'
            : 'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png';
      case MapViewMode.satellite:
        return 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}';

      case MapViewMode.street:
        return isDark
            ? 'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png'
            : 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager_nolabels/{z}/{x}/{y}{r}.png';
    }
  }
}
