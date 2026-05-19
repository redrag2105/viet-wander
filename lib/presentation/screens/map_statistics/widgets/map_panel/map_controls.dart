import 'package:flutter/material.dart';
import 'package:viet_wander/presentation/screens/map_statistics/widgets/data_panel/data_panel.dart';

class MapZoomControls extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onZoomIn;
  final VoidCallback onZoomOut;

  const MapZoomControls({
    super.key,
    required this.isDarkMode,
    required this.onZoomIn,
    required this.onZoomOut,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: 'zoomIn',
          backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          onPressed: onZoomIn,
          child: Icon(
            Icons.add,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'zoomOut',
          backgroundColor: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          onPressed: onZoomOut,
          child: Icon(
            Icons.remove,
            color: isDarkMode ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }
}

class MapThemeToggle extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback onToggle;

  const MapThemeToggle({
    super.key,
    required this.isDarkMode,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(30),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E293B) : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) {
            return RotationTransition(
              turns: child.key == const ValueKey('icon_dark')
                  ? Tween<double>(begin: 0.5, end: 0).animate(animation)
                  : Tween<double>(begin: 0, end: 0.5).animate(animation),
              child: ScaleTransition(scale: animation, child: child),
            );
          },
          child: isDarkMode
              ? const Icon(
                  Icons.nightlight_round,
                  key: ValueKey('icon_dark'),
                  color: Colors.yellow,
                  size: 24,
                )
              : const Icon(
                  Icons.wb_sunny_rounded,
                  key: ValueKey('icon_light'),
                  color: Colors.orange,
                  size: 24,
                ),
        ),
      ),
    );
  }
}

class MapSidebarControls extends StatelessWidget {
  final double actualWidth;
  final double expandedWidth;
  final bool isSidebarOpen;
  final bool isDragging;
  final VoidCallback onBackTap;
  final VoidCallback onToggleSidebar;
  final Function(DragUpdateDetails) onDragUpdate;
  final VoidCallback onDragStart;
  final VoidCallback onDragEnd;

  const MapSidebarControls({
    super.key,
    required this.actualWidth,
    required this.expandedWidth,
    required this.isSidebarOpen,
    required this.isDragging,
    required this.onBackTap,
    required this.onToggleSidebar,
    required this.onDragUpdate,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    final Duration duration = isDragging
        ? Duration.zero
        : const Duration(milliseconds: 700);

    return Stack(
      children: [
        // Back button
        Positioned(
          top: 24,
          left: 24,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: onBackTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ),

        // Toggle Sidebar Button
        AnimatedPositioned(
          duration: duration,
          curve: Curves.easeInOutCubic,
          top: 24,
          right: actualWidth,
          child: GestureDetector(
            onTap: onToggleSidebar,
            child: Container(
              width: 44,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFF020617),
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(12),
                ),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              ),
              child: Icon(
                isSidebarOpen
                    ? Icons.view_sidebar_outlined
                    : Icons.view_sidebar,
                color: Colors.white54,
              ),
            ),
          ),
        ),

        // Sidebar (DataPanel)
        Positioned(
          top: 0,
          bottom: 0,
          right: 0,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeInOutCubic,
            width: actualWidth,
            decoration: BoxDecoration(
              color: const Color(0xFF020617),
              border: Border(
                left: BorderSide(
                  color: isSidebarOpen
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.transparent,
                ),
              ),
            ),
            child: ClipRect(
              child: OverflowBox(
                minWidth: expandedWidth,
                maxWidth: expandedWidth,
                alignment: Alignment.topRight,
                child: Row(
                  children: [
                    // Handle kéo sidebar
                    GestureDetector(
                      onHorizontalDragStart: (_) => onDragStart(),
                      onHorizontalDragUpdate: onDragUpdate,
                      onHorizontalDragEnd: (_) => onDragEnd(),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.resizeLeftRight,
                        child: Container(
                          width: 12,
                          height: double.infinity,
                          color: isDragging
                              ? const Color(0x456E6E6E)
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
    );
  }
}
