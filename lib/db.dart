import 'dart:convert';
import 'dart:io';

import 'package:angersmap_data/config.dart';
import 'package:angersmap_data/generate_files.dart';
import 'package:angersmap_data/models/gtfs_calendar_dates.dart';
import 'package:angersmap_data/models/gtfs_route.dart';
import 'package:angersmap_data/models/gtfs_stop.dart';
import 'package:angersmap_data/models/gtfs_stop_time.dart';
import 'package:angersmap_data/models/gtfs_trip.dart';
import 'package:supabase/supabase.dart';

Future<void> generateDb() async {
  final supabase = SupabaseClient(config.supabaseUrl, config.supabaseKey);

  print('--- VIDAGE DES TABLES ---');
  // On vide les tables avant de les remplir à nouveau
  await supabase.from('gtfs_stop_times').delete().neq('trip_id', 'impossible');
  print('gtfs_stop_times vidée');
  await supabase.from('gtfs_trips').delete().neq('trip_id', 'impossible');
  print('gtfs_trips vidée');
  await supabase.from('gtfs_stops').delete().neq('stop_id', 'impossible');
  print('gtfs_stops vidée');
  await supabase.from('gtfs_routes').delete().neq('route_id', 'impossible');
  print('gtfs_routes vidée');
  await supabase
      .from('gtfs_calendar_dates')
      .delete()
      .neq('service_id', 'impossible');
  print('gtfs_calendar_dates vidée');
  print('--- FIN VIDAGE DES TABLES ---');

  DateTime dt = DateTime.now();

  // CALENDAR_DATES
  print('Insert CALENDAR_DATES');

  final file = File('gtfs/calendar_dates_merge.json');
  final stringFiles = file.readAsStringSync();
  List<dynamic> jsonFile = jsonDecode(stringFiles);

  await supabase
      .from('gtfs_calendar_dates')
      .insert(
        jsonFile
            .map((e) => GtfsCalendarDates.fromJson(e as Map<String, dynamic>))
            .map(
              (e) => {
                'service_id': e.serviceId,
                'date': e.date,
                'exception_type': e.exceptionType,
              },
            )
            .toList(),
      );

  print(
    'CALENDAR_DATES inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}',
  );

  // ROUTES
  dt = DateTime.now();
  print('Insert ROUTES');
  jsonFile = readFile('gtfs/routes.csv');

  await supabase
      .from('gtfs_routes')
      .insert(
        jsonFile
            .map((e) => GtfsRoute.fromJson(e))
            .map(
              (e) => {
                'route_id': e.routeId,
                'agency_id': e.agencyId,
                'route_short_name': e.routeShortName,
                'route_long_name': e.routeLongName,
                'route_color': e.routeColor,
                'route_text_color': e.routeTextColor,
              },
            )
            .toList(),
      );

  print(
    'ROUTES inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}',
  );

  // STOPS
  dt = DateTime.now();
  print('Insert STOPS');
  jsonFile = readFile('gtfs/stops.csv');
  await supabase
      .from('gtfs_stops')
      .insert(
        jsonFile
            .map((e) => GtfsStop.fromJson(e))
            .map(
              (e) => {
                'stop_id': e.stopId,
                'stop_code': e.stopCode,
                'stop_name': e.stopName,
                'stop_lat': e.stopLat,
                'stop_lon': e.stopLon,
                'location_type': 0,
                'stop_timezone': '',
                'wheelchair_boarding': 0,
              },
            )
            .toList(),
      );

  print(
    'STOPS inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}',
  );

  // TRIPS
  dt = DateTime.now();
  print('Insert TRIPS');
  jsonFile = readFile('gtfs/trips.csv');

  await supabase
      .from('gtfs_trips')
      .insert(
        jsonFile
            .map((e) => GtfsTrip.fromJson(e))
            .map(
              (e) => {
                'route_id': e.routeId,
                'service_id': e.serviceId,
                'trip_id': e.tripId,
                'trip_headsign': e.tripHeadsign,
                'trip_short_name': e.tripShortName,
                'direction_id': e.directionId,
                'shape_id': e.shapeId,
              },
            )
            .toList(),
      );

  print(
    'TRIPS inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}',
  );

  // STOP_TIMES
  dt = DateTime.now();
  print('Insert STOP_TIMES');
  jsonFile = readFile('gtfs/stop_times.csv');
  const chunkSize = 10000;

  final allRows = jsonFile.map((e) => GtfsStopTime.fromJson(e)).map((e) {
    final arrivalArray = e.arrivalTime.split(':');
    final departureArray = e.departureTime.split(':');
    final arrivalHour = int.parse(arrivalArray.first);
    final departureHour = int.parse(departureArray.first);
    final arrivalNextDay = arrivalHour > 23;
    final departureNextDay = departureHour > 23;
    final arrival = [
      arrivalNextDay ? (arrivalHour - 24) : arrivalHour,
      arrivalArray[1],
      arrivalArray[2],
    ].join(':');
    final departure = [
      departureNextDay ? (departureHour - 24) : departureHour,
      departureArray[1],
      departureArray[2],
    ].join(':');
    return {
      'trip_id': e.tripId,
      'arrival_time': arrival,
      'departure_time': departure,
      'stop_id': e.stopId,
      'stop_sequence': e.stopSequence,
      'pickup_type': e.pickupType,
      'next_day_arrival': arrivalNextDay,
      'next_day_departure': departureNextDay,
    };
  }).toList();

  // Insertion par morceaux
  for (var i = 0; i < allRows.length; i += chunkSize) {
    final chunk = allRows.sublist(
      i,
      i + chunkSize > allRows.length ? allRows.length : i + chunkSize,
    );

    await supabase.from('gtfs_stop_times').insert(chunk);

    print('Chunk inséré : ${i ~/ chunkSize + 1}');
  }

  print(
    'STOP_TIMES inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}',
  );

  print('Terminé');
}
