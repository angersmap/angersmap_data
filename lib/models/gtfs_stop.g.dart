// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gtfs_stop.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GtfsStop _$GtfsStopFromJson(Map<String, dynamic> json) => GtfsStop(
      stopId: json['stop_id'] as String,
      stopCode: ConvertUtils.fromJsonStringToInt(json['stop_code'] as String),
      stopName:
          ConvertUtils.fromJsonStringUppercase(json['stop_name'] as String),
      stopLat: ConvertUtils.fromJsonStringToDouble(json['stop_lat'] as String),
      stopLon: ConvertUtils.fromJsonStringToDouble(json['stop_lon'] as String),
      locationType:
          ConvertUtils.fromJsonStringToInt(json['location_type'] as String),
      wheelchairBoarding: ConvertUtils.fromJsonStringToInt(
          json['wheelchair_boarding'] as String),
    );

Map<String, dynamic> _$GtfsStopToJson(GtfsStop instance) => <String, dynamic>{
      'stop_id': instance.stopId,
      'stop_code': instance.stopCode,
      'stop_name': instance.stopName,
      'stop_lat': instance.stopLat,
      'stop_lon': instance.stopLon,
      'location_type': instance.locationType,
      'wheelchair_boarding': instance.wheelchairBoarding,
    };
