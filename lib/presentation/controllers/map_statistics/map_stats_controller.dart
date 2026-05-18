import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tiengviet/tiengviet.dart';
import 'package:viet_wander/data/providers/local/local_data.dart';
import 'package:viet_wander/domain/entities/province.dart';
import 'map_stats_state.dart';

class MapStatsController extends StateNotifier<MapStatsState> {
  final Ref _ref;

  MapStatsController(this._ref) : super(MapStatsState()) {
    _init();
  }

  Future<void> _init() async {
    state = state.copyWith(isLoading: true);

    final repo = _ref.read(mapRepositoryProvider);
    await repo.initializeData();

    final allProvinces = repo.getAllProvinces();

    state = state.copyWith(
      isLoading: false,
      provinces: allProvinces,
      filteredProvinces: allProvinces,
      filteredCommunes: repo.getAllCommunes().take(50).toList(),
      filteredCommittees: repo.getAllCommittees().take(50).toList(),
    );
  }

  void searchData(String query) {
    if (query.isEmpty) {
      final repo = _ref.read(mapRepositoryProvider);
      state = state.copyWith(
        filteredProvinces: state.provinces,
        filteredCommunes: repo.getAllCommunes().take(50).toList(),
        filteredCommittees: repo.getAllCommittees().take(50).toList(),
      );
      return;
    }

    final searchKeyLower = TiengViet.parse(query).toLowerCase();
    final repo = _ref.read(mapRepositoryProvider);

    final filteredProvinces = state.provinces.where((p) {
      return p.searchKey.contains(searchKeyLower) ||
          p.tenShort.toLowerCase().contains(searchKeyLower);
    }).toList();

    final allCommunes = repo.getAllCommunes();
    final filteredCommunes = allCommunes
        .where((c) {
          return c.searchKey.contains(searchKeyLower);
        })
        .take(50)
        .toList();

    final allCommittees = repo.getAllCommittees();
    final filteredCommittees = allCommittees
        .where((c) {
          return c.searchKey.contains(searchKeyLower);
        })
        .take(50)
        .toList();

    state = state.copyWith(
      filteredProvinces: filteredProvinces,
      filteredCommunes: filteredCommunes,
      filteredCommittees: filteredCommittees,
    );
  }

  /// Xử lý khi chọn một Tỉnh (từ danh sách hoặc từ Click bản đồ)
  void selectProvince(Province province) {
    final repo = _ref.read(mapRepositoryProvider);

    // Lấy danh sách xã và UBND của riêng tỉnh đó
    final communes = repo.getCommunesByProvince(province.ma);
    final committees = repo.getCommitteesByProvince(province.ma);

    state = state.copyWith(
      selectedProvince: province,
      clearSelectedCommune: true,
      communes: communes,
      committees: committees,
      isDetailMode: true,
    );
  }

  void selectProvinceByMa(String ma) {
    if (state.selectedProvince?.ma == ma) {
      resetToListView();
      return;
    }

    try {
      // Tìm Province object dựa trên mã truyền vào
      final province = state.provinces.firstWhere((p) => p.ma == ma);
      selectProvince(province);
    } catch (e) {
      // Nếu không tìm thấy (hoặc user click ra ngoài biển), reset UI
      resetToListView();
    }
  }

  void selectCommuneByMa(String ma) {
    if (state.selectedCommune?.ma == ma) {
      // Unselect if clicking the already selected commune
      unselectCommune();
      return;
    }

    try {
      final repo = _ref.read(mapRepositoryProvider);

      final allCommunes = repo.getAllCommunes();
      final commune = allCommunes.firstWhere((c) => c.ma == ma);

      state = state.copyWith(selectedCommune: commune, isDetailMode: true);
    } catch (e) {
      unselectCommune();
    }
  }

  void unselectCommune() {
    state = state.copyWith(clearSelectedCommune: true);
    if (state.selectedProvince == null) {
      state = state.copyWith(isDetailMode: false);
    }
  }

  void resetToListView() {
    state = state.copyWith(
      isDetailMode: false,
      clearSelectedProvince: true,
      clearSelectedCommune: true,
      communes: [],
      committees: [],
    );
  }
}

final mapStatsControllerProvider =
    StateNotifierProvider<MapStatsController, MapStatsState>((ref) {
      return MapStatsController(ref);
    });
