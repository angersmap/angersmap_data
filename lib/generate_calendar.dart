import 'dart:convert';
import 'dart:io';

import 'package:angersmap_data/generate_files.dart';
import 'package:angersmap_data/models/gtfs_calendar.dart';
import 'package:intl/intl.dart';

import 'models/gtfs_calendar_dates.dart';

Future<void> generateCalendar() async {
  List<Map<String, dynamic>> jsonCalendarFile = readFile('gtfs/calendar.csv');

  final calendarDatesMerge = <GtfsCalendarDates>[];

  // ETAPE 1 : Création de la liste des dates pour chaque service à partir des dates de début et de fin
  final Map<String, Set<DateTime>> calendarDates = {};
  for (Map<String, dynamic> json in jsonCalendarFile) {
    final value = GtfsCalendar.fromJson(json);

    DateTime startDate = DateTime.parse(value.startDate);
    DateTime endDate = DateTime.parse(value.endDate);

    calendarDates[value.serviceId] =
        _generateDatesList(startDate, endDate, value);
  }

  // ETAPE 2 : Mise à jour de la liste des dates pour chaque service à partir des dates d'exception
  List<Map<String, dynamic>> jsonCalendarDatesFile =
      readFile('gtfs/calendar_dates.csv');
  for (Map<String, dynamic> json in jsonCalendarDatesFile) {
    final value = GtfsCalendarDates.fromJson(json);
    final date = DateTime.parse(value.date);
    if (!calendarDates.containsKey(value.serviceId)) {
      calendarDates[value.serviceId] = <DateTime>{};
    }

    if (value.exceptionType == 1) {
      calendarDates[value.serviceId]!.add(date);
    } else {
      calendarDates[value.serviceId]!.remove(date);
    }
  }

  // ETAPE 3 : Création de la liste des dates
  for (String serviceId in calendarDates.keys) {
    for (DateTime date in calendarDates[serviceId]!) {
      calendarDatesMerge.add(GtfsCalendarDates(
          serviceId: serviceId,
          date: DateFormat('yyyyMMdd').format(date),
          exceptionType: 1));
    }
  }

  final dbStopTimesFile = File('gtfs/calendar_dates_merge.json');
  dbStopTimesFile.writeAsStringSync(
      jsonEncode(calendarDatesMerge.map((e) => e.toJson()).toList()));

}

Set<DateTime> _generateDatesList(
    DateTime startDate, DateTime endDate, GtfsCalendar value) {
  final Set<DateTime> dates = {};

  DateTime date = startDate;

  while (date.isBefore(endDate)) {
    if (value.monday && date.weekday == 1) {
      dates.add(date);
    }
    if (value.tuesday && date.weekday == 2) {
      dates.add(date);
    }
    if (value.wednesday && date.weekday == 3) {
      dates.add(date);
    }
    if (value.thursday && date.weekday == 4) {
      dates.add(date);
    }
    if (value.friday && date.weekday == 5) {
      dates.add(date);
    }
    if (value.saturday && date.weekday == 6) {
      dates.add(date);
    }
    if (value.sunday && date.weekday == 7) {
      dates.add(date);
    }
    date = date.add(Duration(days: 1));
    if(date.hour == 23) {
      date = date.add(Duration(hours: 1));
    }
  }

  return dates;
}
