// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gtfs_calendar_dates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GtfsCalendarDates _$GtfsCalendarDatesFromJson(Map<String, dynamic> json) =>
    GtfsCalendarDates(
      serviceId: json['service_id'] as String,
      date: json['date'] as String,
      exceptionType:
          ConvertUtils.fromJsonStringToInt(json['exception_type'] as String),
    );

Map<String, dynamic> _$GtfsCalendarDatesToJson(GtfsCalendarDates instance) =>
    <String, dynamic>{
      'service_id': instance.serviceId,
      'date': instance.date,
      'exception_type': ConvertUtils.toJsonString(instance.exceptionType),
    };
