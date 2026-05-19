import 'package:flutter/material.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_controller.dart';
import 'package:viet_wander/presentation/controllers/map_statistics/map_stats_state.dart';
import 'package:viet_wander/app/utils/formatters.dart';

class SearchResultsView extends StatefulWidget {
  final MapStatsState state;
  final MapStatsController controller;

  const SearchResultsView({
    super.key,
    required this.state,
    required this.controller,
  });

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  bool _isProvinceExpanded = true;
  bool _isCommuneExpanded = true;
  bool _isCommitteeExpanded = true;

  Widget _buildEmptySearch() {
    return const Center(
      child: Text(
        'Không tìm thấy kết quả',
        style: TextStyle(color: Colors.white54, fontStyle: FontStyle.italic),
      ),
    );
  }

  String _getProvinceName(String parentMa, [String? parentTen]) {
    try {
      if (parentMa.isNotEmpty) {
        final p = widget.state.provinces.firstWhere((p) => p.ma == parentMa);
        return p.tenShort;
      }
      if (parentTen != null && parentTen.isNotEmpty) {
        final p = widget.state.provinces.firstWhere((p) => p.ten == parentTen);
        return p.tenShort;
      }
    } catch (_) {}
    return '';
  }

  Widget _buildProvinceBadge(String pName) {
    if (pName.isEmpty) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.only(left: 6.0),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        pName,
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final controller = widget.controller;

    if (state.filteredProvinces.isEmpty &&
        state.filteredCommunes.isEmpty &&
        state.filteredCommittees.isEmpty) {
      return _buildEmptySearch();
    }

    return CustomScrollView(
      slivers: [
        // -- PROVINCES --
        if (state.filteredProvinces.isNotEmpty)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  title: 'TỈNH / THÀNH PHỐ',
                  color: Colors.amber,
                  isExpanded: _isProvinceExpanded,
                  onToggle: () => setState(
                    () => _isProvinceExpanded = !_isProvinceExpanded,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedCrossFade(
                  firstChild: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(left: 12.0, right: 16.0),
                    itemCount: state.filteredProvinces.length,
                    itemBuilder: (context, index) {
                      final p = state.filteredProvinces[index];
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 12.0,
                            right: 18.0,
                          ),
                          title: Text(
                            p.ten,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '${Formatters.formatNumber(p.population)} người - ${Formatters.formatNumber(p.areaKm2, fractionDigits: 2)} km²',
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            controller.selectProvince(p);
                          },
                        ),
                      );
                    },
                  ),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: _isProvinceExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),

        // -- COMMUNES --
        if (state.filteredCommunes.isNotEmpty)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  title: 'XÃ / PHƯỜNG',
                  color: Colors.tealAccent,
                  isExpanded: _isCommuneExpanded,
                  onToggle: () =>
                      setState(() => _isCommuneExpanded = !_isCommuneExpanded),
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedCrossFade(
                  firstChild: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(left: 12.0, right: 16.0),

                    itemCount: state.filteredCommunes.length,
                    itemBuilder: (context, index) {
                      final c = state.filteredCommunes[index];
                      final pName = _getProvinceName(c.parentMa);
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 12.0,
                            right: 18.0,
                          ),
                          title: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                c.ten,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              _buildProvinceBadge(pName),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              '${Formatters.formatNumber(c.population)} người - ${Formatters.formatNumber(c.areaKm2, fractionDigits: 2)} km²',
                            ),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            controller.selectCommuneByMa(c.ma);
                          },
                        ),
                      );
                    },
                  ),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: _isCommuneExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),

        // -- COMMITTEES --
        if (state.filteredCommittees.isNotEmpty)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _StickyHeaderDelegate(
                  title: 'ỦY BAN NHÂN DÂN',
                  color: Colors.lightBlue,
                  isExpanded: _isCommitteeExpanded,
                  onToggle: () => setState(
                    () => _isCommitteeExpanded = !_isCommitteeExpanded,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: AnimatedCrossFade(
                  firstChild: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.only(left: 12.0, right: 16.0),

                    itemCount: state.filteredCommittees.length,
                    itemBuilder: (context, index) {
                      final c = state.filteredCommittees[index];
                      final pName = _getProvinceName(c.parentMa, c.parentTen);
                      final displayName = c.ten.replaceAll(
                        'Ủy ban nhân dân',
                        'UBND',
                      );
                      return Material(
                        color: Colors.transparent,
                        child: ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.only(
                            left: 12.0,
                            right: 18.0,
                          ),
                          title: Wrap(
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                displayName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              _buildProvinceBadge(pName),
                            ],
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(c.type),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 12,
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            controller.selectCommuneFromCommittee(c);
                          },
                        ),
                      );
                    },
                  ),
                  secondChild: const SizedBox.shrink(),
                  crossFadeState: _isCommitteeExpanded
                      ? CrossFadeState.showFirst
                      : CrossFadeState.showSecond,
                  duration: const Duration(milliseconds: 250),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

// --- STICKY HEADER DELEGATE ---
class _StickyHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String title;
  final Color color;
  final bool isExpanded;
  final VoidCallback onToggle;

  _StickyHeaderDelegate({
    required this.title,
    required this.color,
    required this.isExpanded,
    required this.onToggle,
  });

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: const Color(0xFF020617),
      padding: const EdgeInsets.only(right: 16.0),
      alignment: Alignment.centerLeft,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onToggle,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 16.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
                Icon(
                  isExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: color,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  double get maxExtent => 44.0;

  @override
  double get minExtent => 44.0;

  @override
  bool shouldRebuild(covariant _StickyHeaderDelegate oldDelegate) {
    return oldDelegate.title != title ||
        oldDelegate.color != color ||
        oldDelegate.isExpanded != isExpanded;
  }
}
