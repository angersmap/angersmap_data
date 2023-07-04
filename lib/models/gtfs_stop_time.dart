import 'package:json_annotation/json_annotation.dart';

import 'convert_utils.dart';

part 'gtfs_stop_time.g.dart';

@JsonSerializable()
class GtfsStopTime {

  @JsonKey(name: 'trip_id')
  String tripId;

  @JsonKey(name: 'arrival_time')
  String arrivalTime;

  @JsonKey(name: 'departure_time')
  String departureTime;

  @JsonKey(name: 'stop_id')
  String stopId;

  @JsonKey(name: 'stop_sequence')
  String stopSequence;


  GtfsStopTime({required this.tripId, required this.arrivalTime, required this.departureTime,
      required this.stopId, required this.stopSequence});

  factory GtfsStopTime.fromJson(Map<String, dynamic> json) =>
      _$GtfsStopTimeFromJson(json);

  Map<String, dynamic> toJson() => _$GtfsStopTimeToJson(this);

}
