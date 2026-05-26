import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:viet_wander/domain/entities/committee.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';

class CommitteeLayer {
  static List<Marker> build(MapStatsState state) {
    if (!state.isDetailMode ||
        state.committees.isEmpty ||
        state.selectedCommune == null) {
      return [];
    }

    final targetCommuneName = state.selectedCommune!.ten.toLowerCase().trim();

    final matchedCommittees = state.committees.where((c) {
      final cleanCommitteeName = c.ten
          .toLowerCase()
          .replaceAll('ủy ban nhân dân', '')
          .replaceAll('ubnd', '')
          .trim();
      return cleanCommitteeName == targetCommuneName;
    }).toList();

    return matchedCommittees.map((Committee committee) {
      return Marker(
        point: LatLng(committee.centroidLat, committee.centroidLon),
        width: 12,
        height: 12,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.redAccent,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.redAccent.withValues(alpha: 0.5),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}
