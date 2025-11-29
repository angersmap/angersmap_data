import 'dart:convert';
import 'dart:io';

import 'package:angersmap_data/config.dart';
import 'package:angersmap_data/generate_files.dart';
import 'package:angersmap_data/models/gtfs_calendar_dates.dart';
import 'package:angersmap_data/models/gtfs_route.dart';
import 'package:angersmap_data/models/gtfs_stop.dart';
import 'package:angersmap_data/models/gtfs_stop_time.dart';
import 'package:angersmap_data/models/gtfs_trip.dart';
import 'package:postgres/postgres.dart';

Future<void> generateDb() async {
  final conn = await Connection.openFromUrl(config.databaseUrl);

  await conn.runTx((trans) async {
    await trans.execute(
        'TRUNCATE gtfs_stop_times, gtfs_trips, gtfs_stops, gtfs_routes, gtfs_calendar_dates RESTART IDENTITY CASCADE');

    DateTime dt = DateTime.now();

    // CALENDAR_DATES
    print('Insert CALENDAR_DATES');

    final file = File('gtfs/calendar_dates_merge.json');
    final stringFiles = file.readAsStringSync();
    List<dynamic> jsonFile = jsonDecode(stringFiles);

    final calendarDatesData = jsonFile
        .map((e) => GtfsCalendarDates.fromJson(e as Map<String, dynamic>))
        .toList();

    if (calendarDatesData.isNotEmpty) {
      await _bulkInsertMultiRow(
        trans,
        'gtfs_calendar_dates',
        ['service_id', 'date', 'exception_type'],
        calendarDatesData
            .map((e) => [e.serviceId, e.date, e.exceptionType])
            .toList(),
      );
    }

    print(
        'CALENDAR_DATES inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');

    // ROUTES
    dt = DateTime.now();
    print('Insert ROUTES');
    jsonFile = readFile('gtfs/routes.csv');

    final routesData = jsonFile
        .map((e) => GtfsRoute.fromJson(e))
        .map((e) => [
              e.routeId,
              e.agencyId,
              e.routeShortName,
              e.routeLongName,
              e.routeColor,
              e.routeTextColor,
              0,
            ])
        .toList();

    if (routesData.isNotEmpty) {
      await _bulkInsertMultiRow(
        trans,
        'gtfs_routes',
        [
          'route_id',
          'agency_id',
          'route_short_name',
          'route_long_name',
          'route_color',
          'route_text_color',
          'route_type',
        ],
        routesData,
      );
    }

    print(
        'ROUTES inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');

    // STOPS
    dt = DateTime.now();
    print('Insert STOPS');
    jsonFile = readFile('gtfs/stops.csv');
    final stopsData = jsonFile
        .map((e) => GtfsStop.fromJson(e))
        .map((e) => [
              e.stopId,
              e.stopCode,
              e.stopName,
              e.stopLat,
              e.stopLon,
              0,
              '',
              false
            ])
        .toList();

    if (stopsData.isNotEmpty) {
      await _bulkInsertMultiRow(
        trans,
        'gtfs_stops',
        [
          'stop_id',
          'stop_code',
          'stop_name',
          'stop_lat',
          'stop_lon',
          'location_type',
          'stop_timezone',
          'wheelchair_boarding'
        ],
        stopsData,
      );
    }

    print(
        'STOPS inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');

    // TRIPS
    dt = DateTime.now();
    print('Insert TRIPS');
    jsonFile = readFile('gtfs/trips.csv');

    final tripsData = jsonFile
        .map((e) => GtfsTrip.fromJson(e))
        .map((e) => [
              e.tripId,
              e.routeId,
              e.serviceId,
              e.tripHeadsign,
              e.tripShortName,
              e.directionId,
              e.shapeId
            ])
        .toList();

    if (tripsData.isNotEmpty) {
      await _bulkInsertMultiRow(
        trans,
        'gtfs_trips',
        [
          'trip_id',
          'route_id',
          'service_id',
          'trip_headsign',
          'trip_short_name',
          'direction_id',
          'shape_id'
        ],
        tripsData,
      );
    }

    print(
        'TRIPS inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');

    // STOP_TIMES - Le plus critique avec des centaines de milliers de lignes
    dt = DateTime.now();
    print('Insert STOP_TIMES');
    jsonFile = readFile('gtfs/stop_times.csv');

    final allRows = jsonFile
        .map((e) => GtfsStopTime.fromJson(e))
        .where((st) =>
            !st.departureTime.startsWith("24:") &&
            !st.arrivalTime.startsWith("24:"))
        .map((e) => [
              e.tripId,
              e.arrivalTime,
              e.departureTime,
              e.stopId,
              e.stopSequence,
              e.pickupType,
            ])
        .toList();

    // Insertion avec des gros chunks pour de gros volumes
    await _bulkInsertMultiRow(
      trans,
      'gtfs_stop_times',
      [
        'trip_id',
        'arrival_time',
        'departure_time',
        'stop_id',
        'stop_sequence',
        'pickup_type'
      ],
      allRows,
      chunkSize: 5000, // Ajuster selon vos besoins
    );

    print(
        'STOP_TIMES inserted: ${jsonFile.length} - ${DateTime.now().difference(dt)}');
  });

  await conn.close();
  print('Terminé');
}

/// Méthode optimisée pour postgres 3.5.9
/// Utilise une requête multi-row INSERT qui est beaucoup plus rapide
Future<void> _bulkInsertMultiRow(
  TxSession conn,
  String tableName,
  List<String> columns,
  List<List<dynamic>> rows, {
  int chunkSize = 1000,
}) async {
  if (rows.isEmpty) return;

  for (var i = 0; i < rows.length; i += chunkSize) {
    final chunk = rows.sublist(
      i,
      i + chunkSize > rows.length ? rows.length : i + chunkSize,
    );

    // Créer les placeholders: ($1, $2, $3), ($4, $5, $6), ...
    final valuePlaceholders = <String>[];
    final allParams = <dynamic>[];

    for (var rowIndex = 0; rowIndex < chunk.length; rowIndex++) {
      final rowPlaceholders = <String>[];
      for (var colIndex = 0; colIndex < columns.length; colIndex++) {
        final paramIndex = rowIndex * columns.length + colIndex + 1;
        rowPlaceholders.add('\$$paramIndex');
        allParams.add(chunk[rowIndex][colIndex]);
      }
      valuePlaceholders.add('(${rowPlaceholders.join(', ')})');
    }

    final sql = '''
      INSERT INTO $tableName (${columns.join(', ')})
      VALUES ${valuePlaceholders.join(', ')}
    ''';
    await conn.execute(sql, parameters: allParams);

    // Afficher la progression tous les 50000 lignes
    if ((i + chunkSize) % 50000 == 0 || (i + chunkSize) >= rows.length) {
      final progress =
          i + chunkSize > rows.length ? rows.length : i + chunkSize;
      print('  Progression: $progress/${rows.length}');
    }
  }
}
