// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gtfs_shape.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GtfsShape _$GtfsShapeFromJson(Map<String, dynamic> json) => GtfsShape(
  shapeId: json['shape_id'] as String,
  shapePtLat: json['shape_pt_lat'] as String,
  shapePtLon: json['shape_pt_lon'] as String,
);

Map<String, dynamic> _$GtfsShapeToJson(GtfsShape instance) => <String, dynamic>{
  'shape_id': instance.shapeId,
  'shape_pt_lat': instance.shapePtLat,
  'shape_pt_lon': instance.shapePtLon,
};
