import 'package:angersmap_data/models/convert_utils.dart';
import 'package:json_annotation/json_annotation.dart';

part 'gtfs_calendar.g.dart';

@JsonSerializable(createToJson: false)
class GtfsCalendar {
  @JsonKey(name: 'service_id')
  String serviceId;
  @JsonKey(fromJson: ConvertUtils.fromJsonStringToBool)
  bool monday;
  @JsonKey(fromJson: ConvertUtils.fromJsonStringToBool)
  bool tuesday;
  @JsonKey(fromJson: ConvertUtils.fromJsonStringToBool)
  bool wednesday;
  @JsonKey(fromJson: ConvertUtils.fromJsonStringToBool)
  bool thursday;
  @JsonKey(fromJson: ConvertUtils.fromJsonStringToBool)
  bool friday;
  @JsonKey(fromJson: ConvertUtils.fromJsonStringToBool)
  bool saturday;
  @JsonKey(fromJson: ConvertUtils.fromJsonStringToBool)
  bool sunday;
  @JsonKey(name: 'start_date')
  String startDate;
  @JsonKey(name: 'end_date')
  String endDate;

  GtfsCalendar(
      {required this.serviceId,
      required this.monday,
      required this.tuesday,
      required this.wednesday,
      required this.thursday,
      required this.friday,
      required this.saturday,
      required this.sunday,
      required this.startDate,
      required this.endDate});

  factory GtfsCalendar.fromJson(Map<String, dynamic> json) =>
      _$GtfsCalendarFromJson(json);
}
