import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:viet_wander/domain/entities/province.dart';

class MapLayerUtils {
  static List<Shadow> getTextHalo(bool isDarkMode) {
    final Color haloColor = isDarkMode ? Colors.black87 : Colors.white;
    return [
      Shadow(offset: const Offset(-1.5, -1.5), color: haloColor),
      Shadow(offset: const Offset(1.5, -1.5), color: haloColor),
      Shadow(offset: const Offset(-1.5, 1.5), color: haloColor),
      Shadow(offset: const Offset(1.5, 1.5), color: haloColor),
    ];
  }

  static Widget buildCapitalLabel(Province p, bool isDarkMode) {
    final starColor = isDarkMode ? Colors.yellowAccent : Colors.red;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              left: 0,
              top: 0,
              child: Icon(
                Icons.star,
                color: isDarkMode ? Colors.black87 : Colors.white,
                size: 18,
              ),
            ),
            Positioned(
              right: 0,
              top: 0,
              child: Icon(
                Icons.star,
                color: isDarkMode ? Colors.black87 : Colors.white,
                size: 18,
              ),
            ),
            Positioned(
              left: 0,
              bottom: 0,
              child: Icon(
                Icons.star,
                color: isDarkMode ? Colors.black87 : Colors.white,
                size: 18,
              ),
            ),
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                Icons.star,
                color: isDarkMode ? Colors.black87 : Colors.white,
                size: 18,
              ),
            ),
            Icon(Icons.star, color: starColor, size: 16),
          ],
        ),
        Text(
          p.tenShort.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Times New Roman',
            color: isDarkMode ? Colors.white : Colors.black87,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            shadows: getTextHalo(isDarkMode),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  static Widget buildNormalLabel(Province p, bool isDarkMode) {
    return Text(
      p.tenShort.toUpperCase(),
      style: TextStyle(
        fontFamily: 'Times New Roman',
        color: isDarkMode ? Colors.white : Colors.black87,
        fontSize: 11,
        fontWeight: FontWeight.w800,
        shadows: getTextHalo(isDarkMode),
      ),
      textAlign: TextAlign.center,
    );
  }

  static Marker buildIslandMarker(String name, LatLng point, bool isDarkMode) {
    return Marker(
      point: point,
      width: 150,
      height: 50,
      alignment: Alignment.center,
      child: Text(
        name,
        style: TextStyle(
          fontFamily: 'Times New Roman',
          color: isDarkMode ? const Color(0xFFDA5C5C) : const Color(0xFFAB0A0A),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          shadows: getTextHalo(isDarkMode),
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
