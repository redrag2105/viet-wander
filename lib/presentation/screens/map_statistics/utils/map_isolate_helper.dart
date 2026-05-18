import 'package:viet_wander/app/utils/geojson_helper.dart';

class GeoJsonParseParams {
  final String geoJsonString;

  GeoJsonParseParams({required this.geoJsonString});
}

List<BasePolygon> parsePolygonsInBackground(GeoJsonParseParams params) {
  return GeoJsonHelper.parseToBasePolygons(params.geoJsonString);
}
