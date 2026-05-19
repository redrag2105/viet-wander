import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AppConfig {
  // Tâm bản đồ mặc định (Gần Đà Nẵng)
  static const LatLng defaultMapCenter = LatLng(16.042078, 113.206230);
  static const double defaultMapZoom = 5.75;
  static final LatLngBounds mapBounds = LatLngBounds(
    const LatLng(4.2842, 95.0),
    const LatLng(26.0, 134.2776),
  );
}
