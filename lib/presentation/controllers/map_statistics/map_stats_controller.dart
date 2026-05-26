import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:tiengviet/tiengviet.dart';
import 'package:viet_wander/data/providers/local/local_data.dart';
import 'package:viet_wander/domain/entities/commune.dart';
import 'package:viet_wander/domain/entities/province.dart';
import 'package:viet_wander/domain/entities/committee.dart';
import 'map_stats_state.dart';

class MapStatsController extends StateNotifier<MapStatsState> {
  final Ref _ref;

  MapStatsController(this._ref) : super(MapStatsState()) {
    Future.delayed(const Duration(milliseconds: 3000), () {
      _init();
    });
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
      filteredCommunes: repo.getAllCommunes().take(100).toList(),
      filteredCommittees: repo.getAllCommittees().take(100).toList(),
    );
  }

  void toggleSidebar() {
    state = state.copyWith(isSidebarOpen: !state.isSidebarOpen);
  }

  void openSidebar() {
    state = state.copyWith(isSidebarOpen: true);
  }

  void closeSidebar() {
    state = state.copyWith(isSidebarOpen: false);
  }

  // Hàm cập nhật state kéo
  void updateDragging(bool isDragging) {
    state = state.copyWith(isDragging: isDragging);
  }

  void updateSidebarWidth(double width) {
    state = state.copyWith(sidebarWidth: width);
  }

  void searchData(String query) {
    if (query.isEmpty) {
      final repo = _ref.read(mapRepositoryProvider);
      state = state.copyWith(
        filteredProvinces: state.provinces,
        filteredCommunes: repo.getAllCommunes().take(100).toList(),
        filteredCommittees: repo.getAllCommittees().take(100).toList(),
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
        .take(100)
        .toList();

    final allCommittees = repo.getAllCommittees();
    final filteredCommittees = allCommittees
        .where((c) {
          return c.searchKey.contains(searchKeyLower);
        })
        .take(100)
        .toList();

    state = state.copyWith(
      filteredProvinces: filteredProvinces,
      filteredCommunes: filteredCommunes,
      filteredCommittees: filteredCommittees,
    );
  }

  /// Chọn một Tỉnh
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

  void selectCommuneFromCommittee(Committee c) {
    try {
      final repo = _ref.read(mapRepositoryProvider);

      final province = state.provinces.firstWhere(
        (p) =>
            (c.parentMa.isNotEmpty && p.ma == c.parentMa) ||
            p.ten == c.parentTen,
      );

      final provinceCommunes = repo.getCommunesByProvince(province.ma);

      final commune = provinceCommunes.firstWhere((commune) {
        return c.ten.toLowerCase().contains(commune.ten.toLowerCase());
      });

      selectCommuneByMa(commune.ma);
    } catch (e) {
      try {
        final province = state.provinces.firstWhere(
          (p) =>
              (c.parentMa.isNotEmpty && p.ma == c.parentMa) ||
              p.ten == c.parentTen,
        );
        selectProvinceByMa(province.ma);
      } catch (_) {
        resetToListView();
      }
    }
  }

  void selectCommuneByMa(String ma) {
    if (state.selectedCommune?.ma == ma) {
      unselectCommune();
      return;
    }

    try {
      final repo = _ref.read(mapRepositoryProvider);

      final allCommunes = repo.getAllCommunes();
      final commune = allCommunes.firstWhere((c) => c.ma == ma);

      Province? currentProvince = state.selectedProvince;
      List<Commune> currentCommunesList = state.communes;
      List<Committee> currentCommitteesList = state.committees;

      if (currentProvince?.ma != commune.parentMa) {
        // Lấy thông tin Tỉnh mới và update toàn bộ danh sách liên quan
        currentProvince = state.provinces.firstWhere(
          (p) => p.ma == commune.parentMa,
        );
        currentCommunesList = repo.getCommunesByProvince(commune.parentMa);
        currentCommitteesList = repo.getCommitteesByProvince(commune.parentMa);
      }

      state = state.copyWith(
        selectedProvince: currentProvince,
        selectedCommune: commune,
        communes: currentCommunesList,
        committees: currentCommitteesList,
        isDetailMode: true,
      );
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

  void changeMapMode(MapViewMode mode) {
    state = state.copyWith(currentMapMode: mode);
  }
}

final mapStatsControllerProvider =
    StateNotifierProvider<MapStatsController, MapStatsState>((ref) {
      return MapStatsController(ref);
    });
