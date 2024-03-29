// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gtfs_trip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GtfsTrip _$GtfsTripFromJson(Map<String, dynamic> json) => GtfsTrip(
      tripId: json['trip_id'] as String,
      routeId: ConvertUtils.fromJsonStringUppercase(json['route_id'] as String),
      serviceId: json['service_id'] as String,
      tripHeadsign: json['trip_headsign'] as String,
      tripShortName: json['trip_short_name'] as String,
      directionId:
          ConvertUtils.fromJsonStringToInt(json['direction_id'] as String),
      shapeId: json['shape_id'] as String,
    );

Map<String, dynamic> _$GtfsTripToJson(GtfsTrip instance) => <String, dynamic>{
      'trip_id': instance.tripId,
      'route_id': instance.routeId,
      'service_id': instance.serviceId,
    };
