import 'package:flutter/material.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';

class MapStyleUtils {
  static Color getDensityColor(double density, {bool isCommune = false}) {
    if (isCommune) {
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

  static String getTileUrl(MapViewMode mode, bool isDark) {
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
