import 'package:flutter/material.dart';

class InfoTableWidget extends StatelessWidget {
  final double area;
  final int population;
  final double density;
  final String addressTitle;
  final String addressData;

  const InfoTableWidget({
    super.key,
    required this.area,
    required this.population,
    required this.density,
    required this.addressTitle,
    required this.addressData,
  });

  TableRow _buildTableRow(String label, String value) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Text(
            value.isNotEmpty ? value : 'Đang cập nhật...',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Table(
        columnWidths: const {0: FlexColumnWidth(4), 1: FlexColumnWidth(6)},
        border: TableBorder(
          horizontalInside: BorderSide(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        children: [
          _buildTableRow('Diện tích (km²)', area.toStringAsFixed(2)),
          _buildTableRow('Dân số (người)', population.toString()),
          _buildTableRow('Mật độ (người/km²)', density.toStringAsFixed(2)),
          _buildTableRow(addressTitle, addressData),
        ],
      ),
    );
  }
}
