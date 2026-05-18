import 'package:flutter/material.dart';
import 'package:viet_wander/domain/entities/province.dart';
import 'package:viet_wander/domain/entities/commune.dart';
import 'package:viet_wander/domain/entities/committee.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';

class SearchResultsView extends StatelessWidget {
  final MapStatsState state;
  final MapStatsController controller;

  const SearchResultsView({
    super.key,
    required this.state,
    required this.controller,
  });

  Widget _buildEmptySearch() {
    return const Center(
      child: Text(
        'Không tìm thấy kết quả',
        style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (state.filteredProvinces.isEmpty &&
        state.filteredCommunes.isEmpty &&
        state.filteredCommittees.isEmpty) {
      return _buildEmptySearch();
    }

    return ListView(
      padding: const EdgeInsets.only(right: 8.0),
      children: [
        if (state.filteredProvinces.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'TỈNH / THÀNH PHỐ',
              style: TextStyle(
                color: Colors.amber,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...state.filteredProvinces.map((Province p) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                p.ten,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text('${p.population} người - ${p.areaKm2} km²'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 12),
              onTap: () {
                FocusScope.of(context).unfocus();
                controller.selectProvince(p);
              },
            );
          }),
        ],
        if (state.filteredCommunes.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'XÃ / PHƯỜNG',
              style: TextStyle(
                color: Colors.tealAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...state.filteredCommunes.map((Commune c) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                c.ten,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text('${c.population} người - ${c.areaKm2} km²'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 12),
              onTap: () {
                FocusScope.of(context).unfocus();
                controller.selectCommuneByMa(c.ma);
              },
            );
          }),
        ],
        if (state.filteredCommittees.isNotEmpty) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'ỦY BAN NHÂN DÂN',
              style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...state.filteredCommittees.map((Committee c) {
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                c.ten,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(c.type),
              trailing: const Icon(Icons.arrow_forward_ios, size: 12),
              onTap: () {
                FocusScope.of(context).unfocus();
                if (c.parentMa.length == 2) {
                  controller.selectProvinceByMa(c.parentMa);
                } else {
                  controller.selectCommuneByMa(c.parentMa);
                }
              },
            );
          }),
        ],
      ],
    );
  }
}
