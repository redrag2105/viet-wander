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
import 'package:viet_wander/presentation/screens/map_statistics/widgets/map_panel/map_gesture_mixin.dart';
import 'package:viet_wander/presentation/screens/map_statistics/widgets/map_panel/map_panel.dart';
import 'package:viet_wander/presentation/screens/map_statistics/widgets/map_panel/map_style_utils.dart';

mixin MapPanelLogic on ConsumerState<MapPanel>, MapGestureMixin {
  @override
  final MapController mapController = MapController();

  @override
  double currentZoom = 6.0;

  bool isDarkMode = false;
  bool showZoomIndicator = false;
  Timer? zoomTimer;

  TickerProvider get tickerProvider => this as TickerProvider;

  void triggerZoomIndicator() {
    if (!mounted) return;
    setState(() => showZoomIndicator = true);
    zoomTimer?.cancel();
    zoomTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => showZoomIndicator = false);
    });
  }

  void toggleTheme() {
    setState(() => isDarkMode = !isDarkMode);
  }

  void handleZoomChange(MapCamera camera, bool hasGesture) {
    if ((currentZoom - camera.zoom).abs() > 0.5) {
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

  // --- MAP CAMERA TARGETING ---
  double _getProvinceTargetZoom(double area) {
    if (area > 12000) return 8.75;
    if (area > 8500) return 9.25;
    if (area > 7000) return 9.5;
    return 10.0;
  }

  double _getCommuneTargetZoom(double area) {
    if (area > 800) return 11.0;
    if (area > 400) return 11.5;
    if (area > 100) return 12.0;
    if (area > 25) return 12.75;
    return 13.5;
  }

  LatLng _getOffsetCenter(LatLng target, double targetZoom) {
    if (widget.rightMargin <= 0) return target;
    final projectedPoint = mapController.camera.projectAtZoom(
      target,
      targetZoom,
    );
    final offsetPoint = Offset(
      projectedPoint.dx + (widget.rightMargin / 2.0),
      projectedPoint.dy,
    );
    final rawOffsetCenter = mapController.camera.unprojectAtZoom(
      offsetPoint,
      targetZoom,
    );
    return AppConfig.mapBounds.contains(rawOffsetCenter)
        ? rawOffsetCenter
        : target;
  }

  void listenToMapStateChanges(MapStatsState? previous, MapStatsState next) {
    final oldCommuneMa = previous?.selectedCommune?.ma;
    final newCommuneMa = next.selectedCommune?.ma;
    final oldProvinceMa = previous?.selectedProvince?.ma;
    final newProvinceMa = next.selectedProvince?.ma;

    if (oldCommuneMa != newCommuneMa && next.selectedCommune != null) {
      final poly = ref
          .read(communeBasePolygonProvider)
          .whenOrNull(data: (d) => d)
          ?.where((p) => p.ma == newCommuneMa)
          .firstOrNull;
      if (poly != null && poly.points.isNotEmpty) {
        final targetZoom = _getCommuneTargetZoom(next.selectedCommune!.areaKm2);
        mapController.animatedMove(
          _getOffsetCenter(poly.centroid, targetZoom),
          targetZoom,
          tickerProvider,
        );
      }
    } else if ((oldCommuneMa != newCommuneMa &&
            next.selectedCommune == null &&
            next.selectedProvince != null) ||
        (oldProvinceMa != newProvinceMa && next.selectedProvince != null)) {
      final targetZoom = _getProvinceTargetZoom(next.selectedProvince!.areaKm2);
      final rawCenter = LatLng(
        next.selectedProvince!.centroidLat,
        next.selectedProvince!.centroidLon,
      );
      mapController.animatedMove(
        _getOffsetCenter(rawCenter, targetZoom),
        targetZoom,
        tickerProvider,
      );
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

  // ==========================
  // CLICK EVENT (RAY-CASTING)
  // ==========================
  @override
  void triggerMapTap(LatLng point) {
    final isZoomedIn = currentZoom >= 11;
    final controller = ref.read(mapStatsControllerProvider.notifier);

    if (isZoomedIn) {
      ref.read(communeBasePolygonProvider).whenData((basePolygons) {
        String? clickedMa = basePolygons
            .where(
              (poly) => GeoJsonHelper.isPointInsidePolygon(point, poly.points),
            )
            .firstOrNull
            ?.ma;
        controller.selectCommuneByMa(clickedMa ?? '');
      });
    } else {
      ref.read(provinceBasePolygonProvider).whenData((basePolygons) {
        String? clickedMa = basePolygons
            .where(
              (poly) => GeoJsonHelper.isPointInsidePolygon(point, poly.points),
            )
            .firstOrNull
            ?.ma;
        if (clickedMa == null) {
          ref.read(communeBasePolygonProvider).whenData((communes) {
            clickedMa = communes
                .where(
                  (p) =>
                      (p.ma == '20333' || p.ma == '22736') &&
                      GeoJsonHelper.isPointInsidePolygon(point, p.points),
                )
                .firstOrNull
                ?.ma;
            if (clickedMa != null) {
              clickedMa = clickedMa == '20333' ? '48' : '56';
            }
          });
        }
        clickedMa != null
            ? controller.selectProvinceByMa(clickedMa!)
            : controller.resetToListView();
      });
    }
  }

  void handleMapTap(TapPosition tapPosition, LatLng point) =>
      triggerMapTap(point);

  // --- POLYGON ---
  List<Polygon> buildPolygons(MapStatsState state) {
    final isZoomedIn = currentZoom >= 11;
    final mode = state.currentMapMode;

    Color fillColor =
        (mode == MapViewMode.street || mode == MapViewMode.satellite)
        ? Colors.transparent
        : (isDarkMode
              ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
              : const Color(0xFF0EA5E9).withValues(alpha: 0.25));

    final borderColor = isDarkMode
        ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
        : const Color(0xFF0284C7).withValues(alpha: 0.8);
    final highlightColor = isDarkMode ? Colors.amber : Colors.deepOrange;

    if (isZoomedIn) {
      return ref
          .watch(communeBasePolygonProvider)
          .maybeWhen(
            data: (basePolygons) {
              Map<String, Color>? heatColors = mode == MapViewMode.density
                  ? {
                      for (var poly in basePolygons)
                        poly.ma: MapStyleUtils.getDensityColor(
                          poly.density,
                          isCommune: true,
                        ),
                    }
                  : null;
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
              ref
                  .read(communeBasePolygonProvider)
                  .whenData(
                    (communes) => combinedPolys.addAll(
                      communes.where((p) => p.ma == '20333' || p.ma == '22736'),
                    ),
                  );
              Map<String, Color>? heatColors = mode == MapViewMode.density
                  ? {
                      for (var poly in combinedPolys)
                        poly.ma: MapStyleUtils.getDensityColor(
                          poly.density,
                          isCommune: false,
                        ),
                    }
                  : null;
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
}
