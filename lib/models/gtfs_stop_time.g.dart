// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gtfs_stop_time.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GtfsStopTime _$GtfsStopTimeFromJson(Map<String, dynamic> json) => GtfsStopTime(
  tripId: json['trip_id'] as String,
  arrivalTime: json['arrival_time'] as String,
  departureTime: json['departure_time'] as String,
  stopId: json['stop_id'] as String,
  stopSequence: ConvertUtils.fromJsonStringToInt(
    json['stop_sequence'] as String,
  ),
  pickupType: ConvertUtils.fromJsonStringToInt(json['pickup_type'] as String),
);

Map<String, dynamic> _$GtfsStopTimeToJson(GtfsStopTime instance) =>
    <String, dynamic>{
      'trip_id': instance.tripId,
      'arrival_time': instance.arrivalTime,
      'departure_time': instance.departureTime,
      'stop_id': instance.stopId,
      'stop_sequence': instance.stopSequence,
      'pickup_type': instance.pickupType,
    };
