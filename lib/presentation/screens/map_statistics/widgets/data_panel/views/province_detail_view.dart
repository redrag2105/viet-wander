import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:viet_wander/domain/entities/province.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';
import 'package:viet_wander/app/utils/formatters.dart';
import 'package:viet_wander/presentation/screens/map_statistics/widgets/environment/environment_cards_widget.dart';
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
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // STICKY PROVINCE NAME
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTitleDelegate(
            title: province.ten.toUpperCase(),
            onBackTap: controller.resetToListView,
          ),
        ),

        // WEATHER & AQI CARDS
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
            child: EnvironmentCardsWidget(
              location: LatLng(
                province.hqLat != 0 ? province.hqLat : province.centroidLat,
                province.hqLon != 0 ? province.hqLon : province.centroidLon,
              ),
            ),
          ),
        ),

        // DETAIL TABLE
        SliverToBoxAdapter(
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
              listTileTheme: ListTileThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: ExpansionTile(
                title: const Text(
                  'Thông tin chi tiết',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                initiallyExpanded: true,
                tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  InfoTableWidget(
                    area: province.areaKm2,
                    population: province.population,
                    density: province.density,
                    addressTitle: 'Trụ sở',
                    addressData: province.address,
                  ),
                ],
              ),
            ),
          ),
        ),

        // COMMUNE LABEL
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(0, 24, 0, 8),
            child: Text(
              'DANH SÁCH XÃ / PHƯỜNG',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
          ),
        ),

        // COMMUNES LIST
        SliverList.separated(
          itemCount: state.communes.length,
          separatorBuilder: (_, _) =>
              Divider(color: Colors.white.withValues(alpha: 0.1)),
          itemBuilder: (context, index) {
            final commune = state.communes[index];
            return Material(
              color: Colors.transparent,
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                title: Text(
                  commune.ten,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                subtitle: Text(
                  'Dân số: ${Formatters.formatNumber(commune.population)} người',
                ),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12),
                onTap: () => controller.selectCommuneByMa(commune.ma),
              ),
            );
          },
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 40)),
      ],
    );
  }
}

// --- DELEGATE STICKY HEADER ---
class _StickyTitleDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final VoidCallback onBackTap;

  _StickyTitleDelegate({required this.title, required this.onBackTap});

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          color: const Color(0xFF020617).withValues(alpha: 0.75),
          alignment: Alignment.centerLeft,
          padding: const EdgeInsets.only(right: 16),
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: onBackTap,
              ),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(covariant _StickyTitleDelegate oldDelegate) {
    return title != oldDelegate.title;
  }
}
