import 'package:flutter/material.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:viet_wander/app/config/app_config.dart';
import 'package:viet_wander/data/providers/polygon_provider.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';
import 'package:viet_wander/presentation/screens/map_statistics/utils/map_animation_extension.dart';
import 'package:viet_wander/presentation/screens/map_statistics/widgets/map_layers/committee_layer.dart';
import 'package:viet_wander/presentation/screens/map_statistics/widgets/map_layers/commune_layer.dart';
import 'package:viet_wander/presentation/screens/map_statistics/widgets/map_layers/map_layer_switcher.dart';
import 'package:viet_wander/presentation/screens/map_statistics/widgets/map_layers/province_layer.dart';

import 'map_controls.dart';
import 'map_panel_logic.dart';

class MapPanel extends ConsumerStatefulWidget {
  final double rightMargin;
  final bool isDragging;

  const MapPanel({super.key, this.rightMargin = 0.0, this.isDragging = false});

  @override
  ConsumerState<MapPanel> createState() => _MapPanelState();
}

class _MapPanelState extends ConsumerState<MapPanel>
    with TickerProviderStateMixin, MapPanelLogic {
  @override
  void dispose() {
    zoomTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapStatsControllerProvider);
    final double rightOffset = widget.rightMargin + 24.0;
    final Duration moveDuration = widget.isDragging
        ? Duration.zero
        : const Duration(milliseconds: 700);

    ref.listen<MapStatsState>(
      mapStatsControllerProvider,
      listenToMapStateChanges,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: AppConfig.defaultMapCenter,
              interactionOptions: const InteractionOptions(
                scrollWheelVelocity: 0.0025,
              ),
              cameraConstraint: CameraConstraint.contain(
                bounds: AppConfig.mapBounds,
              ),
              initialZoom: AppConfig.defaultMapZoom,
              minZoom: 5.5,
              maxZoom: state.currentMapMode == MapViewMode.minimal
                  ? 16.0
                  : 20.0,
              onPositionChanged: handleZoomChange,
              onTap: handleMapTap,
            ),
            children: [
              ColorFiltered(
                colorFilter:
                    isDarkMode &&
                        (state.currentMapMode == MapViewMode.satellite)
                    ? ColorFilter.mode(
                        Colors.black.withValues(alpha: 0.45),
                        BlendMode.darken,
                      )
                    : const ColorFilter.mode(
                        Colors.transparent,
                        BlendMode.srcOver,
                      ),
                child: TileLayer(
                  urlTemplate: getTileUrl(state.currentMapMode, isDarkMode),
                  errorImage: const AssetImage(
                    'assets/images/map_tile_error.png',
                  ),
                  tileProvider: CancellableNetworkTileProvider(),
                  subdomains: const ['a', 'b', 'c', 'd'],
                ),
              ),
              PolygonLayer(
                polygons: buildPolygons(state),
                // polygonCulling: currentZoom >= 11,
              ),
              MarkerLayer(
                markers: ProvinceLayer.build(state, currentZoom, isDarkMode),
              ),
              MarkerLayer(
                markers: CommuneLayer.build(
                  state,
                  currentZoom,
                  isDarkMode,
                  ref
                      .watch(communeBasePolygonProvider)
                      .whenOrNull(data: (d) => d),
                ),
              ),
              MarkerLayer(markers: CommitteeLayer.build(state)),
            ],
          ),

          // Buttons overlay
          AnimatedPositioned(
            duration: moveDuration,
            curve: Curves.easeInOutCubic,
            top: 24,
            right: rightOffset + 30,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                MapLayerSwitcher(isDarkMode: isDarkMode),
                const SizedBox(width: 12),
                MapThemeToggle(isDarkMode: isDarkMode, onToggle: toggleTheme),
              ],
            ),
          ),

          // ZOOM INDICATOR
          AnimatedPositioned(
            duration: moveDuration,
            curve: Curves.easeInOutCubic,
            bottom: 20,
            right: rightOffset + 3,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: showZoomIndicator ? 1.0 : 0.0,
              child: Text(
                '${currentZoom.toStringAsFixed(2)}x',
                style: TextStyle(
                  color: isDarkMode ? Colors.black : Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: isDarkMode ? Colors.white70 : Colors.black87,
                      blurRadius: 12,
                      offset: Offset(2, 2),
                    ),
                    Shadow(
                      color: isDarkMode ? Colors.white : Colors.black,
                      blurRadius: 16,
                      offset: Offset(0, 0),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // NÚT ZOOM CỘNG/TRỪ
          AnimatedPositioned(
            duration: moveDuration,
            curve: Curves.easeInOutCubic,
            bottom: 61,
            right: rightOffset,
            child: MapZoomControls(
              isDarkMode: isDarkMode,
              onZoomIn: () {
                mapController.animatedMove(
                  mapController.camera.center,
                  currentZoom + 1,
                  tickerProvider,
                );
                triggerZoomIndicator();
              },
              onZoomOut: () {
                mapController.animatedMove(
                  mapController.camera.center,
                  currentZoom - 1,
                  tickerProvider,
                );
                triggerZoomIndicator();
              },
            ),
          ),
        ],
      ),
    );
  }
}
