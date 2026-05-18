import 'package:flutter/material.dart';
import 'package:viet_wander/domain/entities/commune.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'info_table_widget.dart';

class CommuneDetailView extends StatelessWidget {
  final Commune commune;
  final MapStatsController controller;

  const CommuneDetailView({
    super.key,
    required this.commune,
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
              onPressed: () => controller.selectCommuneByMa(commune.ma),
            ),
            Expanded(
              child: Text(
                commune.ten.toUpperCase(),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        InfoTableWidget(
          area: commune.areaKm2,
          population: commune.population,
          density: commune.density,
          addressTitle: 'Trụ sở',
          addressData: commune.capital,
        ),
      ],
    );
  }
}
