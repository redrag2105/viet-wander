class Commune {
  final String id;
  final String ma;
  final String parentMa;
  final String ten;
  final double areaKm2;
  final int population;
  final double density;
  final String capital;
  final String decree;
  final String searchKey;

  const Commune({
    required this.id,
    required this.ma,
    required this.parentMa,
    required this.ten,
    required this.areaKm2,
    required this.population,
    required this.density,
    required this.capital,
    required this.decree,
    required this.searchKey,
  });
}
