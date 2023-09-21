import 'package:angersmap_data/config.dart';
import 'package:angersmap_data/models/gtfs_calendar_dates.dart';
import 'package:angersmap_data/models/gtfs_route.dart';
import 'package:angersmap_data/models/gtfs_stop_time.dart';
import 'package:mysql_client/mysql_client.dart';

import 'package:angersmap_data/generate_files.dart';
import 'package:angersmap_data/models/gtfs_stop.dart';
import 'package:angersmap_data/models/gtfs_trip.dart';

Future<void> generateDb() async {
  final conn = await MySQLConnection.createConnection(
    host: config.dbHost,
    port: 3306,
    collation: 'utf8mb3_general_ci',
    userName: config.dbUsername,
    password: config.dbPassword,
    secure: false,
    databaseName: config.dbName, // optional,
  );

  // actually connect to database
  await conn.connect();

  await conn.execute('SET FOREIGN_KEY_CHECKS = 0');
  await conn.execute('TRUNCATE gtfs_stop_times');
  await conn.execute('TRUNCATE gtfs_trips');
  await conn.execute('TRUNCATE gtfs_stops');
  await conn.execute('TRUNCATE gtfs_routes');
  await conn.execute('TRUNCATE gtfs_calendar_dates');


  int i = 0;
  DateTime dt = DateTime.now();

  // CALENDAR_DATES
  print('Insert CALENDAR_DATES');
  List<Map<String, dynamic>> jsonFile = readFile('gtfs/calendar_dates.csv');
  PreparedStmt stmt = await conn.prepare(
    'INSERT INTO gtfs_calendar_dates (service_id, date, exception_type) VALUES (?, ?, ?)',
  );
  for (Map<String, dynamic> json in jsonFile) {
    final value = GtfsCalendarDates.fromJson(json);
    await stmt.execute([value.serviceId, value.date, value.exceptionType]);
    i++;
  }
  print('CALENDAR_DATES inserted: $i - ${DateTime.now().difference(dt)}');

  // ROUTES
  dt = DateTime.now();
  i = 0;
  print('Insert ROUTES');
  jsonFile = readFile('gtfs/routes.csv');
  stmt = await conn.prepare(
    'INSERT INTO gtfs_routes (route_id, agency_id, route_short_name, route_long_name, route_color, route_text_color) VALUES (?, ?, ?, ?, ?, ?)',
  );
  for (Map<String, dynamic> json in jsonFile) {
    final value = GtfsRoute.fromJson(json);
    await stmt.execute([
      value.routeId,
      value.agencyId,
      value.routeShortName,
      value.routeLongName,
      value.routeColor,
      value.routeTextColor
    ]);
    i++;
  }
  print('ROUTES inserted: $i - ${DateTime.now().difference(dt)}');

  // STOPS
  dt = DateTime.now();
  i = 0;
  print('Insert STOPS');
  jsonFile = readFile('gtfs/stops.csv');
  stmt = await conn.prepare(
    'INSERT INTO gtfs_stops (stop_id,stop_code,stop_name,stop_lat,stop_lon,location_type,stop_timezone,wheelchair_boarding) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
  );
  for (Map<String, dynamic> json in jsonFile) {
    final value = GtfsStop.fromJson(json);
    await stmt.execute([
      value.stopId,
      value.stopCode,
      value.stopName,
      value.stopLat,
      value.stopLon,
      value.locationType,
      '',
      value.wheelchairBoarding
    ]);
    i++;
  }
  print('STOPS inserted: $i - ${DateTime.now().difference(dt)}');

  // TRIPS
  dt = DateTime.now();
  i = 0;
  print('Insert TRIPS');
  jsonFile = readFile('gtfs/trips.csv');
  stmt = await conn.prepare(
    'INSERT INTO gtfs_trips (route_id,service_id,trip_id,trip_headsign,trip_short_name,direction_id,shape_id) VALUES (?, ?, ?, ?, ?, ?, ?)',
  );
  for (Map<String, dynamic> json in jsonFile) {
    final value = GtfsTrip.fromJson(json);
    await stmt.execute([
      value.routeId,
      value.serviceId,
      value.tripId,
      value.tripHeadsign,
      value.tripShortName,
      value.directionId,
      value.shapeId
    ]);
    i++;
  }
  print('TRIPS inserted: $i - ${DateTime.now().difference(dt)}');

  // STOP_TIMES
  dt = DateTime.now();
  i = 0;
  print('Insert STOP_TIMES');
  jsonFile = readFile('gtfs/stop_times.csv');
  stmt = await conn.prepare(
    'INSERT INTO gtfs_stop_times (trip_id,arrival_time,departure_time,stop_id,stop_sequence,pickup_type) VALUES (?, ?, ?, ?, ?, ?)',
  );
  for (Map<String, dynamic> json in jsonFile) {
    final value = GtfsStopTime.fromJson(json);
    await stmt.execute([
      value.tripId,
      value.arrivalTime,
      value.departureTime,
      value.stopId,
      value.stopSequence,
      value.pickupType,
    ]);
    i++;
  }
  print('STOP_TIMES inserted: $i - ${DateTime.now().difference(dt)}');

  await conn.execute('SET FOREIGN_KEY_CHECKS = 1');
  print('Terminé');
}
