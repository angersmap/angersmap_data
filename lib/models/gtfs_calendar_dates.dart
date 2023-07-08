import 'package:angersmap_data/models/convert_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gtfs_calendar_dates.g.dart';

@JsonSerializable(createToJson: false)
class GtfsCalendarDates {
  @JsonKey(name: 'service_id')
  String serviceId;
  String date;
  @JsonKey(name: 'exception_type', fromJson: ConvertUtils.fromJsonStringToInt)
  int exceptionType;

  GtfsCalendarDates(
      {required this.serviceId,
      required this.date,
      required this.exceptionType});

  factory GtfsCalendarDates.fromJson(Map<String, dynamic> json) =>
      _$GtfsCalendarDatesFromJson(json);
}
