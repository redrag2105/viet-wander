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
import 'package:viet_wander/presentation/screens/map_statistics/widgets/map_layer_builder.dart';

import 'map_controls.dart';

class MapPanel extends ConsumerStatefulWidget {
  const MapPanel({super.key});

  @override
  ConsumerState<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends ConsumerState<MapPanel>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  double _currentZoom = 6.0;
  bool _isDarkMode = false;

  int _getZoomTier(double zoom) {
    if (zoom <= 7.0) return 1;
    if (zoom <= 7.5) return 2;
    if (zoom < 11) return 3;
    return 4;
  }

  void _handleZoomChange(MapCamera camera, bool hasGesture) {
    int oldTier = _getZoomTier(_currentZoom);
    int newTier = _getZoomTier(camera.zoom);

    if (oldTier != newTier) {
      setState(() => _currentZoom = camera.zoom);
    } else if (_currentZoom != camera.zoom) {
      _currentZoom = camera.zoom;
    }
  }

  void _toggleTheme() {
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapStatsControllerProvider);

    final isParsingProvinces = ref.watch(provinceBasePolygonProvider).isLoading;
    final isParsingCommunes = ref.watch(communeBasePolygonProvider).isLoading;

    // Listen for state changes to zoom map
    ref.listen<MapStatsState>(mapStatsControllerProvider, (previous, next) {
      final oldCommuneMa = previous?.selectedCommune?.ma;
      final newCommuneMa = next.selectedCommune?.ma;

      final oldProvinceMa = previous?.selectedProvince?.ma;
      final newProvinceMa = next.selectedProvince?.ma;

      if (oldCommuneMa != newCommuneMa && next.selectedCommune != null) {
        final communePolysInfo = ref
            .read(communeBasePolygonProvider)
            .whenOrNull(data: (d) => d);
        if (communePolysInfo != null) {
          final poly = communePolysInfo
              .where((p) => p.ma == newCommuneMa)
              .firstOrNull;
          if (poly != null && poly.points.isNotEmpty) {
            // Calculate a fast unweighted centroid from polygon points
            double sumLat = 0;
            double sumLon = 0;
            for (var pt in poly.points) {
              sumLat += pt.latitude;
              sumLon += pt.longitude;
            }
            final center = LatLng(
              sumLat / poly.points.length,
              sumLon / poly.points.length,
            );

            // Zoom to Commune
            _mapController.animatedMove(
              center,
              11.5, // Standard zoom level deep enough for Communes
              this,
            );
          }
        }
      } else if (oldCommuneMa != newCommuneMa &&
          next.selectedCommune == null &&
          next.selectedProvince != null) {
        // Zoom back to Province
        double targetZoom = 9.0;
        final area = next.selectedProvince!.areaKm2;
        if (area > 12000) {
          targetZoom = 8.75;
        } else if (area > 8500) {
          targetZoom = 9.25;
        } else if (area > 7000) {
          targetZoom = 9.5;
        } else {
          targetZoom = 10.0;
        }

        _mapController.animatedMove(
          LatLng(
            next.selectedProvince!.centroidLat,
            next.selectedProvince!.centroidLon,
          ),
          targetZoom,
          this,
        );
      } else if (oldCommuneMa != newCommuneMa &&
          next.selectedCommune == null &&
          next.selectedProvince == null) {
        // Reset Zoom
        _mapController.animatedMove(
          AppConfig.defaultMapCenter,
          AppConfig.defaultMapZoom,
          this,
        );
      } else if (oldProvinceMa != newProvinceMa &&
          next.selectedProvince != null) {
        // Zoom to Province
        double targetZoom = 9.0;
        final area = next.selectedProvince!.areaKm2;
        if (area > 12000) {
          targetZoom = 8.75;
        } else if (area > 8500) {
          targetZoom = 9.25;
        } else if (area > 7000) {
          targetZoom = 9.5;
        } else {
          targetZoom = 10.0;
        }

        _mapController.animatedMove(
          LatLng(
            next.selectedProvince!.centroidLat,
            next.selectedProvince!.centroidLon,
          ),
          targetZoom,
          this,
        );
      } else if (oldProvinceMa != newProvinceMa &&
          next.selectedProvince == null) {
        // Reset Zoom
        _mapController.animatedMove(
          AppConfig.defaultMapCenter,
          AppConfig.defaultMapZoom,
          this,
        );
      }
    });

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: AppConfig.defaultMapCenter,
              interactionOptions: const InteractionOptions(
                scrollWheelVelocity: 0.0025,
              ),
              cameraConstraint: CameraConstraint.containCenter(
                bounds: LatLngBounds(
                  const LatLng(7.0, 100.0),
                  const LatLng(24.0, 115.0),
                ),
              ),
              initialZoom: AppConfig.defaultMapZoom,
              minZoom: 5.5,
              maxZoom: 12.0,
              onPositionChanged: _handleZoomChange,
              onTap: (tapPosition, point) {
                final isZoomedIn = _currentZoom >= 11;

                if (isZoomedIn) {
                  final asyncCommunes = ref.read(communeBasePolygonProvider);
                  asyncCommunes.whenData((basePolygons) {
                    String? clickedCommuneMa;
                    for (var poly in basePolygons) {
                      if (GeoJsonHelper.isPointInsidePolygon(
                        point,
                        poly.points,
                      )) {
                        clickedCommuneMa = poly.ma;
                        break;
                      }
                    }
                    if (clickedCommuneMa != null) {
                      ref
                          .read(mapStatsControllerProvider.notifier)
                          .selectCommuneByMa(clickedCommuneMa);
                    } else {
                      ref
                          .read(mapStatsControllerProvider.notifier)
                          .selectCommuneByMa('');
                    }
                  });
                  return;
                }

                final asyncProvinces = ref.read(provinceBasePolygonProvider);

                asyncProvinces.whenData((basePolygons) {
                  String? clickedMa;

                  // Duyệt qua tất cả các đa giác để xem điểm click nằm trong đa giác nào
                  for (var poly in basePolygons) {
                    if (GeoJsonHelper.isPointInsidePolygon(
                      point,
                      poly.points,
                    )) {
                      clickedMa = poly.ma;
                      break;
                    }
                  }

                  if (clickedMa != null) {
                    ref
                        .read(mapStatsControllerProvider.notifier)
                        .selectProvinceByMa(clickedMa);
                  } else {
                    ref
                        .read(mapStatsControllerProvider.notifier)
                        .resetToListView();
                  }
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate: _isDarkMode
                    ? 'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png'
                    : 'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              PolygonLayer(
                polygons: _buildPolygons(state),
                polygonCulling: true,
              ),
              MarkerLayer(
                markers: MapLayerBuilders.buildProvinceLabels(
                  state,
                  _currentZoom,
                  _isDarkMode,
                ),
              ),
              MarkerLayer(
                markers: MapLayerBuilders.buildCommuneLabels(
                  state,
                  _currentZoom,
                  _isDarkMode,
                  ref
                      .watch(communeBasePolygonProvider)
                      .whenOrNull(data: (d) => d),
                ),
              ),
              MarkerLayer(
                markers: MapLayerBuilders.buildCommitteeMarkers(state),
              ),
            ],
          ),

          Positioned(
            top: 16,
            right: 16,
            child: MapThemeToggle(
              isDarkMode: _isDarkMode,
              onToggle: _toggleTheme,
            ),
          ),
          Positioned(
            bottom: 24,
            right: 24,
            child: MapZoomControls(
              isDarkMode: _isDarkMode,
              onZoomIn: () => _mapController.animatedMove(
                _mapController.camera.center,
                _currentZoom + 1,
                this,
              ),
              onZoomOut: () => _mapController.animatedMove(
                _mapController.camera.center,
                _currentZoom - 1,
                this,
              ),
            ),
          ),

          if (state.isLoading || isParsingProvinces || isParsingCommunes)
            Container(
              color: const Color(0xFF0F172A).withValues(alpha: 0.8),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF38BDF8)),
              ),
            ),
        ],
      ),
    );
  }

  // DRAW POLYGONS
  List<Polygon> _buildPolygons(MapStatsState state) {
    final isZoomedIn = _currentZoom >= 11;

    final Color fillColor = _isDarkMode
        ? const Color(0xFF38BDF8).withValues(alpha: 0.15)
        : const Color(0xFF0EA5E9).withValues(alpha: 0.25);
    final Color borderColor = _isDarkMode
        ? const Color(0xFF38BDF8).withValues(alpha: 0.6)
        : const Color(0xFF0284C7).withValues(alpha: 0.8);
    final Color highlightColor = _isDarkMode ? Colors.amber : Colors.deepOrange;

    if (isZoomedIn) {
      final asyncCommunes = ref.watch(communeBasePolygonProvider);

      return asyncCommunes.maybeWhen(
        data: (basePolygons) {
          return GeoJsonHelper.buildPolygonsFromBase(
            basePolygons: basePolygons,
            fillColor: fillColor,
            borderColor: borderColor,
            borderStrokeWidth: 1.0,
            isDarkMode: _isDarkMode,
            selectedMa: state.selectedCommune?.ma,
            highlightColor: highlightColor,
          );
        },
        orElse: () => [],
      );
    } else {
      final asyncProvinces = ref.watch(provinceBasePolygonProvider);

      return asyncProvinces.maybeWhen(
        data: (basePolygons) => GeoJsonHelper.buildPolygonsFromBase(
          basePolygons: basePolygons,
          fillColor: fillColor,
          borderColor: borderColor,
          borderStrokeWidth: 1.5,
          isDarkMode: _isDarkMode,
          selectedMa: state.selectedProvince?.ma,
          highlightColor: highlightColor,
        ),
        orElse: () => [],
      );
    }
  }
}
