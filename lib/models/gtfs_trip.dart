import 'package:angersmap_data/models/convert_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gtfs_trip.g.dart';

@JsonSerializable()
class GtfsTrip {
  @JsonKey(name: 'trip_id')
  String tripId;
  @JsonKey(name: 'route_id', fromJson: ConvertUtils.fromJsonStringUppercase)
  String routeId;
  @JsonKey(name: 'service_id')
  String serviceId;
  @JsonKey(name: 'trip_headsign', includeToJson: false)
  String tripHeadsign;
  @JsonKey(name: 'trip_short_name', includeToJson: false)
  String tripShortName;
  @JsonKey(
      name: 'direction_id',
      includeToJson: false,
      fromJson: ConvertUtils.fromJsonStringToInt)
  int directionId;
  @JsonKey(name: 'shape_id', includeToJson: false)
  String shapeId;

  GtfsTrip(
      {required this.tripId,
      required this.routeId,
      required this.serviceId,
      required this.tripHeadsign,
      required this.tripShortName,
      required this.directionId,
      required this.shapeId});

  factory GtfsTrip.fromJson(Map<String, dynamic> json) =>
      _$GtfsTripFromJson(json);

  Map<String, dynamic> toJson() => _$GtfsTripToJson(this);
}
