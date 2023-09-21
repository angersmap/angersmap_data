import 'package:angersmap_data/models/convert_utils.dart';
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
  @JsonKey(name: 'shape_pt_sequence')
  String shapePtSequence;
  @JsonKey(name: 'shape_dist_traveled')
  String shapeDistTraveled;


  GtfsShape(
      {required this.shapeId,
      required this.shapePtLat,
      required this.shapePtLon,
      required this.shapePtSequence,
      required this.shapeDistTraveled});


  factory GtfsShape.fromJson(Map<String, dynamic> json) =>
      _$GtfsShapeFromJson(json);

  Map<String, dynamic> toJson() => _$GtfsShapeToJson(this);
}
