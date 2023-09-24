import 'package:json_annotation/json_annotation.dart';

import 'convert_utils.dart';

part 'gtfs_stop.g.dart';

@JsonSerializable()
class GtfsStop {
  @JsonKey(name: 'stop_id')
  String stopId;
  @JsonKey(name: 'stop_code', fromJson: ConvertUtils.fromJsonStringToInt)
  int stopCode;
  @JsonKey(
      name: 'stop_name',
      fromJson: ConvertUtils.fromJsonStringUppercase,
      includeToJson: false)
  String stopName;
  @JsonKey(name: 'stop_lat', fromJson: ConvertUtils.fromJsonStringToDouble)
  double stopLat;
  @JsonKey(name: 'stop_lon', fromJson: ConvertUtils.fromJsonStringToDouble)
  double stopLon;

  GtfsStop(
      {required this.stopId,
      required this.stopCode,
      required this.stopName,
      required this.stopLat,
      required this.stopLon,});

  factory GtfsStop.fromJson(Map<String, dynamic> json) =>
      _$GtfsStopFromJson(json);

  /// Connect the generated [_$PersonToJson] function to the `toJson` method.
  Map<String, dynamic> toJson() => _$GtfsStopToJson(this);
}
