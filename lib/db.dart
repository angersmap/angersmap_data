import 'dart:convert';
import 'dart:io';

import 'package:angersmap_data/config.dart';
import 'package:angersmap_data/generate_files.dart';
import 'package:angersmap_data/models/gtfs_calendar_dates.dart';
import 'package:angersmap_data/models/gtfs_route.dart';
import 'package:angersmap_data/models/gtfs_stop.dart';
import 'package:angersmap_data/models/gtfs_stop_time.dart';
import 'package:angersmap_data/models/gtfs_trip.dart';
import 'package:mysql_utils/mysql_utils.dart';

Future<void> generateDb() async {
  var conn = MysqlUtils(
      settings: {
        'host': config.dbHost,
        'port': 3306,
        'user': config.dbUsername,
        'password': config.dbPassword,
        'db': config.dbName,
        'maxConnections': 10,
        'prefix': '',
        'secure': false,
        'pool': true,
        'collation': 'utf8mb3_general_ci',
        'sqlEscape': true,
      },
      errorLog: (error) {
        print(error);
      },
      // sqlLog: (sql) {
      //   print(sql);
      // },
      connectInit: (db1) async {
        print('whenComplete');
      });

  // actually connect to database
  await conn.startTrans();

  await conn.query('SET FOREIGN_KEY_CHECKS = 0');
  await conn.query('TRUNCATE gtfs_stop_times');
  await conn.query('TRUNCATE gtfs_trips');
  await conn.query('TRUNCATE gtfs_stops');
  await conn.query('TRUNCATE gtfs_routes');
  await conn.query('TRUNCATE gtfs_calendar_dates');

  DateTime dt = DateTime.now();

  // CALENDAR_DATES
  print('Insert CALENDAR_DATES');

  final file = File('gtfs/calendar_dates_merge.json');
  final stringFiles = file.readAsStringSync();
  List<dynamic> jsonFile = jsonDecode(stringFiles);

  await conn.insertAll(
      table: 'gtfs_calendar_dates',
      insertData: jsonFile
          .map((e) => GtfsCalendarDates.fromJson(e as Map<String, dynamic>))
          .map((e) => {
                'service_id': e.serviceId,
                'date': e.date,
                'exception_type': e.exceptionType
              })
          .toList());

  print(
      'CALENDAR_DATES inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');

  // ROUTES
  dt = DateTime.now();
  print('Insert ROUTES');
  jsonFile = readFile('gtfs/routes.csv');

  await conn.insertAll(
      table: 'gtfs_routes',
      insertData: jsonFile
          .map((e) => GtfsRoute.fromJson(e))
          .map((e) => {
                'route_id': e.routeId,
                'agency_id': e.agencyId,
                'route_short_name': e.routeShortName,
                'route_long_name': e.routeLongName,
                'route_color': e.routeColor,
                'route_text_color': e.routeTextColor
              })
          .toList());

  print(
      'ROUTES inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');

  // STOPS
  dt = DateTime.now();
  print('Insert STOPS');
  jsonFile = readFile('gtfs/stops.csv');
  await conn.insertAll(
      table: 'gtfs_stops',
      insertData: jsonFile
          .map((e) => GtfsStop.fromJson(e))
          .map((e) => {
                'stop_id': e.stopId,
                'stop_code': e.stopCode,
                'stop_name': e.stopName,
                'stop_lat': e.stopLat,
                'stop_lon': e.stopLon,
                'location_type': 0,
                'stop_timezone': '',
                'wheelchair_boarding': 0
              })
          .toList());

  print(
      'STOPS inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');

  // TRIPS
  dt = DateTime.now();
  print('Insert TRIPS');
  jsonFile = readFile('gtfs/trips.csv');

  await conn.insertAll(
      table: 'gtfs_trips',
      debug: true,
      insertData: jsonFile
          .map((e) => GtfsTrip.fromJson(e))
          .map((e) => {
                'route_id': e.routeId,
                'service_id': e.serviceId,
                'trip_id': e.tripId,
                'trip_headsign': e.tripHeadsign,
                'trip_short_name': e.tripShortName,
                'direction_id': e.directionId,
                'shape_id': e.shapeId
              })
          .toList());

  print(
      'TRIPS inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');

  // STOP_TIMES
  dt = DateTime.now();
  print('Insert STOP_TIMES');
  jsonFile = readFile('gtfs/stop_times.csv');
  const chunkSize = 100000;

  final allRows = jsonFile
      .map((e) => GtfsStopTime.fromJson(e))
      .map((e) => {
            'trip_id': e.tripId,
            'arrival_time': e.arrivalTime,
            'departure_time': e.departureTime,
            'stop_id': e.stopId,
            'stop_sequence': e.stopSequence,
            'pickup_type': e.pickupType,
          })
      .toList();

// Insertion par morceaux
  for (var i = 0; i < allRows.length; i += chunkSize) {
    final chunk = allRows.sublist(
      i,
      i + chunkSize > allRows.length ? allRows.length : i + chunkSize,
    );

    await conn.insertAll(
      table: 'gtfs_stop_times',
      insertData: chunk,
    );

    print('Chunk inséré : ${i ~/ chunkSize + 1}');
  }

  print(
      'STOP_TIMES inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');

  await conn.query('SET FOREIGN_KEY_CHECKS = 1');

  await conn.commit();
  await conn.close();
  print('Terminé');
}
