import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';

import 'views/search_results_view.dart';
import 'views/province_detail_view.dart';
import 'views/commune_detail_view.dart';

class DataPanel extends ConsumerStatefulWidget {
  const DataPanel({super.key});

  @override
  ConsumerState<DataPanel> createState() => _DataPanelState();
}

class _DataPanelState extends ConsumerState<DataPanel> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapStatsControllerProvider);
    final controller = ref.read(mapStatsControllerProvider.notifier);

    return Container(
      color: const Color(0xFF020617),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    'THỐNG KÊ ĐỊA LÝ',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          if (state.selectedProvince == null) ...[
            TextField(
              controller: _searchController,
              onChanged: controller.searchData,
              decoration: InputDecoration(
                hintText: 'Tìm tỉnh, xã, UBND...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.selectedCommune != null
                ? CommuneDetailView(
                    commune: state.selectedCommune!,
                    state: state,
                    controller: controller,
                  )
                : state.selectedProvince != null
                ? ProvinceDetailView(
                    province: state.selectedProvince!,
                    state: state,
                    controller: controller,
                  )
                : SearchResultsView(state: state, controller: controller),
          ),
        ],
      ),
    );
  }
}
