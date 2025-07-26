import 'package:json_annotation/json_annotation.dart';

part 'gtfs_shape.g.dart';

@JsonSerializable()
class GtfsShape {
  @JsonKey(name: 'shape_id')
  String shapeId;
  @JsonKey(name: 'shape_pt_lat')
  String shapePtLat;
  @JsonKey(name: 'shape_pt_lon')
  String shapePtLon;


  GtfsShape(
      {required this.shapeId,
      required this.shapePtLat,
      required this.shapePtLon});


  factory GtfsShape.fromJson(Map<String, dynamic> json) =>
      _$GtfsShapeFromJson(json);

  Map<String, dynamic> toJson() => _$GtfsShapeToJson(this);
}
