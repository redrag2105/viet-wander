import 'package:flutter/material.dart';
import 'package:viet_wander/domain/entities/province.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';
import 'info_table_widget.dart';

class ProvinceDetailView extends StatelessWidget {
  final Province province;
  final MapStatsState state;
  final MapStatsController controller;

  const ProvinceDetailView({
    super.key,
    required this.province,
    required this.state,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: controller.resetToListView,
            ),
            Expanded(
              child: Text(
                province.ten.toUpperCase(),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: const Text(
              'Thông tin chi tiết',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            initiallyExpanded: true,
            tilePadding: EdgeInsets.zero,
            children: [
              InfoTableWidget(
                area: province.areaKm2,
                population: province.population,
                density: province.density,
                addressTitle: 'Trụ sở',
                addressData: province.capital,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'DANH SÁCH XÃ / PHƯỜNG',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(right: 8.0),
            itemCount: state.communes.length,
            separatorBuilder: (_, _) =>
                Divider(color: Colors.white.withValues(alpha: 0.1)),
            itemBuilder: (context, index) {
              final commune = state.communes[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  commune.ten,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text('Dân số: ${commune.population} người'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                onTap: () => controller.selectCommuneByMa(commune.ma),
              );
            },
          ),
        ),
      ],
    );
  }
}
