// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gtfs_calendar.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GtfsCalendar _$GtfsCalendarFromJson(Map<String, dynamic> json) => GtfsCalendar(
      serviceId: json['service_id'] as String,
      monday: ConvertUtils.fromJsonStringToBool(json['monday'] as String),
      tuesday: ConvertUtils.fromJsonStringToBool(json['tuesday'] as String),
      wednesday: ConvertUtils.fromJsonStringToBool(json['wednesday'] as String),
      thursday: ConvertUtils.fromJsonStringToBool(json['thursday'] as String),
      friday: ConvertUtils.fromJsonStringToBool(json['friday'] as String),
      saturday: ConvertUtils.fromJsonStringToBool(json['saturday'] as String),
      sunday: ConvertUtils.fromJsonStringToBool(json['sunday'] as String),
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
    );
