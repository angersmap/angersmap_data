import 'package:checksum/models/convert_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gtfs_route.g.dart';

@JsonSerializable()
class GtfsRoute {
  @JsonKey(name: 'route_id', fromJson: ConvertUtils.fromJsonStringUppercase)
  String routeId;
  @JsonKey(name: 'route_short_name')
  String routeShortName;
  @JsonKey(name: 'route_long_name')
  String routeLongName;
  @JsonKey(name: 'route_type', fromJson: ConvertUtils.fromJsonStringToInt)
  int routeType;

  @JsonKey(name: 'route_color')
  String routeColor;

  @JsonKey(name: 'route_text_color')
  String routeTextColor;

  @JsonKey(includeFromJson: false, includeToJson: true)
  List<String> stops = [];


  GtfsRoute(
      {required this.routeId,
        required this.routeShortName,
        required this.routeLongName,
        required this.routeType,
        required this.routeColor,
      required this.routeTextColor});

  factory GtfsRoute.fromJson(Map<String, dynamic> json) =>
      _$GtfsRouteFromJson(json);

  Map<String, dynamic> toJson() => _$GtfsRouteToJson(this);


}
