import 'dart:developer';

import 'package:checksum/models/gtfs_calendar_dates.dart';
import 'package:checksum/models/gtfs_route.dart';
import 'package:mysql_client/mysql_client.dart';

import 'generate_files.dart';
import 'models/gtfs_stop.dart';

Future<void> generateDb() async {
  // final conn = await MySQLConnection.createConnection(
  //   host: 'rapa3054.odns.fr',
  //   port: 3306,
  //   collation: 'utf8mb3_general_ci',
  //   userName: 'rapa3054_angersmap',
  //   password: 'syLi=gGT)@o@',
  //   secure: false,
  //   databaseName: 'rapa3054_angersmap', // optional,
  // );

  final conn = await MySQLConnection.createConnection(
    host: 'rapa3054.odns.fr',
    port: 3306,
    collation: 'utf8mb3_general_ci',
    userName: 'rapa3054_angersmap_test',
    password: '{E=[OV2sxB&D',
    secure: false,
    databaseName: 'rapa3054_angersmap_test', // optional,
  );

  // actually connect to database
  await conn.connect();

  await conn.execute('SET FOREIGN_KEY_CHECKS = 0');
  await conn.execute('TRUNCATE gtfs_stop_times');
  await conn.execute('TRUNCATE gtfs_trips');
  await conn.execute('TRUNCATE gtfs_stops');
  await conn.execute('TRUNCATE gtfs_routes');
  await conn.execute('TRUNCATE gtfs_calendar_dates');
  await conn.execute('SET FOREIGN_KEY_CHECKS = 1');

  // CALENDAR_DATES
  print('Insert CALENDAR_DATES');
  final calendarDatesJson = readFile('gtfs/calendar_dates.csv');
  PreparedStmt stmt = await conn.prepare(
    'INSERT INTO gtfs_calendar_dates (service_id, date, exception_type) VALUES (?, ?, ?)',
  );
  for (Map<String, dynamic> calendarDateJson in calendarDatesJson) {
    final value = GtfsCalendarDates.fromJson(calendarDateJson);
    await stmt.execute([value.serviceId, value.date, value.exceptionType]);
  }

  // ROUTES
  print('Insert ROUTES');
  final routesJson = readFile('gtfs/routes.csv');
  stmt = await conn.prepare(
    'INSERT INTO gtfs_routes (route_id, agency_id, route_short_name, route_long_name, route_color, route_text_color) VALUES (?, ?, ?, ?, ?, ?)',
  );
  for (Map<String, dynamic> routeJson in routesJson) {
    final value = GtfsRoute.fromJson(routeJson);
    await stmt.execute([
      value.routeId,
      value.agencyId,
      value.routeShortName,
      value.routeLongName,
      value.routeColor,
      value.routeTextColor
    ]);
  }

  // STOPS
  print('Insert STOPS');
  final stopsJson = readFile('gtfs/stops.csv');
  stmt = await conn.prepare(
    'INSERT INTO gtfs_stops (stop_id,stop_code,stop_name,stop_lat,stop_lon,location_type,stop_timezone,wheelchair_boarding) VALUES (?, ?, ?, ?, ?, ?, ?, ?)',
  );
  for (Map<String, dynamic> json in stopsJson) {
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
  }

  print('Terminé');
}
