import 'package:viet_wander/domain/entities/committee.dart';
import 'package:viet_wander/domain/entities/commune.dart';
import 'package:viet_wander/domain/entities/province.dart';

class MapStatsState {
  final bool isLoading;
  final List<Province> provinces;
  final List<Province> filteredProvinces;
  final List<Commune> filteredCommunes;
  final List<Committee> filteredCommittees;
  final Province? selectedProvince;
  final Commune? selectedCommune;
  final List<Commune> communes;
  final List<Committee> committees;
  final bool isDetailMode;
  final bool isSidebarOpen;
  final double sidebarWidth;
  final bool isDragging;

  MapStatsState({
    this.isLoading = true,
    this.provinces = const [],
    this.filteredProvinces = const [],
    this.filteredCommunes = const [],
    this.filteredCommittees = const [],
    this.selectedProvince,
    this.selectedCommune,
    this.communes = const [],
    this.committees = const [],
    this.isDetailMode = false,
    this.isSidebarOpen = true,
    this.sidebarWidth = 420.0,
    this.isDragging = false,
  });

  MapStatsState copyWith({
    bool? isLoading,
    List<Province>? provinces,
    List<Province>? filteredProvinces,
    List<Commune>? filteredCommunes,
    List<Committee>? filteredCommittees,
    Province? selectedProvince,
    Commune? selectedCommune,
    bool clearSelectedCommune = false,
    bool clearSelectedProvince = false,
    List<Commune>? communes,
    List<Committee>? committees,
    bool? isDetailMode,
    bool? isSidebarOpen,
    double? sidebarWidth,
    bool? isDragging,
  }) {
    return MapStatsState(
      isLoading: isLoading ?? this.isLoading,
      provinces: provinces ?? this.provinces,
      filteredProvinces: filteredProvinces ?? this.filteredProvinces,
      filteredCommunes: filteredCommunes ?? this.filteredCommunes,
      filteredCommittees: filteredCommittees ?? this.filteredCommittees,
      selectedProvince: clearSelectedProvince
          ? null
          : (selectedProvince ?? this.selectedProvince),
      selectedCommune: clearSelectedCommune
          ? null
          : (selectedCommune ?? this.selectedCommune),
      communes: communes ?? this.communes,
      committees: committees ?? this.committees,
      isDetailMode: isDetailMode ?? this.isDetailMode,
      isSidebarOpen: isSidebarOpen ?? this.isSidebarOpen,
      sidebarWidth: sidebarWidth ?? this.sidebarWidth,
      isDragging: isDragging ?? this.isDragging,
    );
  }
}
