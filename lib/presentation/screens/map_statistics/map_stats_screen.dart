import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'widgets/map_panel/map_panel.dart';
import 'widgets/data_panel/data_panel.dart';

class MapStatsScreen extends ConsumerStatefulWidget {
  const MapStatsScreen({super.key});

  @override
  ConsumerState<MapStatsScreen> createState() => _MapStatsScreenState();
}

class _MapStatsScreenState extends ConsumerState<MapStatsScreen> {
  double _expandedWidth = 420.0;
  bool _isDragging = false;
  static const double _minWidth = 320.0;
  static const double _maxWidth = 650.0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapStatsControllerProvider);
    final controller = ref.read(mapStatsControllerProvider.notifier);

    final double actualWidth = state.isSidebarOpen ? _expandedWidth : 0;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Stack(
        children: [
          Positioned.fill(
            child: MapPanel(rightMargin: actualWidth, isDragging: _isDragging),
          ),

          Positioned(
            top: 24,
            left: 24,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 2.0),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Closing TAB button
          AnimatedPositioned(
            duration: _isDragging
                ? Duration.zero
                : const Duration(milliseconds: 700),
            curve: Curves.easeInOutCubic,
            top: 24,
            right: actualWidth,
            child: MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: controller.toggleSidebar,
                child: Container(
                  width: 44,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF020617),
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      left: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                      bottom: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1),
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(-4, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    state.isSidebarOpen
                        ? Icons.view_sidebar_outlined
                        : Icons.view_sidebar,
                    color: Colors.white54,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),

          // Data Panel
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: AnimatedContainer(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 700),
              curve: Curves.easeInOutCubic,
              width: actualWidth,
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                border: Border(
                  left: BorderSide(
                    color: state.isSidebarOpen
                        ? Colors.white.withValues(alpha: 0.1)
                        : Colors.transparent,
                  ),
                ),
                boxShadow: [
                  if (state.isSidebarOpen)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 20,
                      offset: const Offset(-5, 0),
                    ),
                ],
              ),
              child: ClipRect(
                child: OverflowBox(
                  minWidth: _expandedWidth,
                  maxWidth: _expandedWidth,
                  alignment: Alignment.topRight,
                  child: Row(
                    children: [
                      // DRAG HANDLE
                      GestureDetector(
                        onHorizontalDragStart: (_) =>
                            setState(() => _isDragging = true),
                        onHorizontalDragUpdate: (details) {
                          setState(() {
                            _expandedWidth -= details.delta.dx;
                            if (_expandedWidth > _maxWidth) {
                              _expandedWidth = _maxWidth;
                            }
                            if (_expandedWidth < _minWidth) {
                              controller.closeSidebar();
                              _expandedWidth = 420.0;
                              _isDragging = false;
                            }
                          });
                        },
                        onHorizontalDragEnd: (_) =>
                            setState(() => _isDragging = false),
                        child: MouseRegion(
                          cursor: SystemMouseCursors.resizeLeftRight,
                          child: Container(
                            width: 12,
                            height: double.infinity,
                            color: _isDragging
                                ? Colors.tealAccent.withValues(alpha: 0.1)
                                : Colors.transparent,
                            child: Center(
                              child: Container(
                                width: 3,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Expanded(child: DataPanel()),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
