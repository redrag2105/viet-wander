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
      triggerZoomIndicator();
    } else if (currentZoom != camera.zoom) {
      setState(() => currentZoom = camera.zoom);
      triggerZoomIndicator();
    }
  }

  double _getTargetZoom(double area) {
    if (area > 12000) return 8.75;
    if (area > 8500) return 9.25;
    if (area > 7000) return 9.5;
    return 10.0;
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
        mapController.animatedMove(poly.centroid, 11.5, tickerProvider);
      }
    } else if ((oldCommuneMa != newCommuneMa &&
            next.selectedCommune == null &&
            next.selectedProvince != null) ||
        (oldProvinceMa != newProvinceMa && next.selectedProvince != null)) {
      final targetZoom = _getTargetZoom(next.selectedProvince!.areaKm2);
      mapController.animatedMove(
        LatLng(
          next.selectedProvince!.centroidLat,
          next.selectedProvince!.centroidLon,
        ),
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
    final fillColor = isDarkMode
        ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
        : const Color(0xFF0EA5E9).withValues(alpha: 0.25);
    final borderColor = isDarkMode
        ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
        : const Color(0xFF0284C7).withValues(alpha: 0.8);
    final highlightColor = isDarkMode ? Colors.amber : Colors.deepOrange;

    if (isZoomedIn) {
      return ref
          .watch(communeBasePolygonProvider)
          .maybeWhen(
            data: (basePolygons) => GeoJsonHelper.buildPolygonsFromBase(
              basePolygons: basePolygons,
              fillColor: fillColor,
              borderColor: borderColor,
              borderStrokeWidth: 1.0,
              isDarkMode: isDarkMode,
              selectedMa: state.selectedCommune?.ma,
              highlightColor: highlightColor,
            ),
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

              return GeoJsonHelper.buildPolygonsFromBase(
                basePolygons: combinedPolys,
                fillColor: fillColor,
                borderColor: borderColor,
                borderStrokeWidth: 1.5,
                isDarkMode: isDarkMode,
                selectedMa: state.selectedProvince?.ma,
                highlightColor: highlightColor,
              );
            },
            orElse: () => [],
          );
    }
  }
}
