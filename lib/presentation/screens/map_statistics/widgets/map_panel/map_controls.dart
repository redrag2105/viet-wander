import 'package:flutter/material.dart';

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
