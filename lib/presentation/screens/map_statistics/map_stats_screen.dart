import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/map_panel.dart';
import 'widgets/data_panel.dart';

class MapStatsScreen extends ConsumerWidget {
  const MapStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: Row(
        children: [
          const Expanded(
            flex: 13,
            child: Padding(padding: EdgeInsets.all(16.0), child: MapPanel()),
          ),

          Container(
            width: 1,
            height: double.infinity,
            color: Colors.white.withValues(alpha: 0.05),
          ),

          const Expanded(flex: 7, child: DataPanel()),
        ],
      ),
    );
  }
}
