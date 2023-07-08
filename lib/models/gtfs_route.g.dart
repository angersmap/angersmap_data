// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gtfs_route.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GtfsRoute _$GtfsRouteFromJson(Map<String, dynamic> json) => GtfsRoute(
      routeId: ConvertUtils.fromJsonStringUppercase(json['route_id'] as String),
      agencyId: json['agency_id'] as String,
      routeShortName: json['route_short_name'] as String,
      routeLongName: json['route_long_name'] as String,
      routeColor: json['route_color'] as String,
      routeTextColor: json['route_text_color'] as String,
    );

Map<String, dynamic> _$GtfsRouteToJson(GtfsRoute instance) => <String, dynamic>{
      'route_id': instance.routeId,
      'route_short_name': instance.routeShortName,
      'route_long_name': instance.routeLongName,
      'route_type': ConvertUtils.toJsonTypeRoute(instance.routeType),
      'route_color': instance.routeColor,
      'route_text_color': instance.routeTextColor,
      'stops': instance.stops,
    };
