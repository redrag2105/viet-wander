import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';

class MapLayerSwitcher extends ConsumerWidget {
  final bool isDarkMode;
  const MapLayerSwitcher({super.key, required this.isDarkMode});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mapStatsControllerProvider);
    final controller = ref.read(mapStatsControllerProvider.notifier);

    return Container(
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
      child: PopupMenuButton<MapViewMode>(
        icon: Icon(
          Icons.layers_outlined,
          color: isDarkMode ? Colors.white : Colors.black87,
        ),
        tooltip: 'Lớp bản đồ nền',
        position: PopupMenuPosition.under,
        color: isDarkMode ? const Color(0xFF0F172A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onSelected: (mode) => controller.changeMapMode(mode),
        itemBuilder: (context) => [
          _buildItem(
            MapViewMode.minimal,
            Icons.map_outlined,
            'Mặc định',
            state.currentMapMode,
          ),
          _buildItem(
            MapViewMode.satellite,
            Icons.satellite_alt_outlined,
            'Vệ tinh',
            state.currentMapMode,
          ),
          _buildItem(
            MapViewMode.street,
            Icons.directions_car_outlined,
            'Giao thông',
            state.currentMapMode,
          ),
          _buildItem(
            MapViewMode.density,
            Icons.local_fire_department,
            'Mật độ dân số',
            state.currentMapMode,
          ),
        ],
      ),
    );
  }

  PopupMenuItem<MapViewMode> _buildItem(
    MapViewMode mode,
    IconData icon,
    String label,
    MapViewMode currentMode,
  ) {
    final isSelected = mode == currentMode;
    final color = isSelected
        ? Colors.orange
        : (isDarkMode ? Colors.white70 : Colors.black87);

    return PopupMenuItem(
      value: mode,
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            ),
          ),
          if (isSelected) ...[
            const Spacer(),
            const Icon(Icons.check, color: Colors.amber, size: 16),
          ],
        ],
      ),
    );
  }
}
