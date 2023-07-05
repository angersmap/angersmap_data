import 'package:checksum/models/convert_utils.dart';
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

  GtfsTrip(
      {required this.tripId, required this.routeId, required this.serviceId});

  factory GtfsTrip.fromJson(Map<String, dynamic> json) =>
      _$GtfsTripFromJson(json);

  Map<String, dynamic> toJson() => _$GtfsTripToJson(this);
}
