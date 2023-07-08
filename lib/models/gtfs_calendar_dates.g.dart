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
