import 'dart:convert';
import 'dart:io';

import 'package:angersmap_data/models/gtfs_route.dart';
import 'package:angersmap_data/models/gtfs_shape.dart';
import 'package:angersmap_data/models/gtfs_stop.dart';
import 'package:angersmap_data/models/gtfs_stop_time.dart';
import 'package:angersmap_data/models/gtfs_trip.dart';
import 'package:angersmap_data/models/route_type.dart';

List<Map<String, dynamic>> readFile(String filename) {
  final file = File(filename);
  final lines = file.readAsStringSync();
  return processData(lines);
}

List<Map<String, dynamic>> processData(String csvData) {
  // Traitement des données CSV et création du JSON correspondant
  // Code à implémenter selon la structure du fichier GTFS et les besoins spécifiques
  // Voici un exemple simple pour illustrer le processus :

  final lines = csvData.split('\n').where((line) => line.isNotEmpty).toList();
  final headers = lines[0].split(',');

  final jsonData = <Map<String, dynamic>>[];

  for (int i = 1; i < lines.length; i++) {
    final values = lines[i].split(',');

    final entry = <String, dynamic>{};
    for (int j = 0; j < headers.length; j++) {
      entry[headers[j]] = values[j];
    }

    jsonData.add(entry);
  }

  return jsonData;
}

Future<void> generateFiles() async {
  try {
    final String pathDir = 'gtfs';
    // TYPE LINES
    final Map<String, RouteType> typeLines = {};
    final file = File('assets/type_lines.json');
    final jsonTypeLines = jsonDecode(file.readAsStringSync());
    for (String line in jsonTypeLines['tram']) {
      typeLines[line] = RouteType.tram;
    }
    for (String line in jsonTypeLines['day']) {
      typeLines[line] = RouteType.day;
    }
    for (String line in jsonTypeLines['night']) {
      typeLines[line] = RouteType.night;
    }
    for (String line in jsonTypeLines['special']) {
      typeLines[line] = RouteType.special;
    }

    // STOPS
    final stopsList = readFile('$pathDir/stops.csv');
    final stops = <String, GtfsStop>{};
    for (Map<String, dynamic> stopElement in stopsList) {
      final stop = GtfsStop.fromJson(stopElement);
      stops[stop.stopId] = stop;
    }

    // ROUTES
    final routesList = readFile('$pathDir/routes.csv');
    final routes = <String, GtfsRoute>{};
    for (Map<String, dynamic> element in routesList) {
      final route = GtfsRoute.fromJson(element);
      route.routeType = typeLines[route.routeId];
      if (typeLines.containsKey(route.routeId)) {
        routes[route.routeId] = route;
      }
    }


    // TRIPS
    final tripsList = readFile('$pathDir/trips.csv');
    final trips = <GtfsTrip>[];
    for (Map<String, dynamic> element in tripsList) {
      final trip = GtfsTrip.fromJson(element);
      if(routes.containsKey(trip.routeId)) {
        trips.add(trip);
      }
    }


    // STOP_TIMES
    final stopTimesList = readFile('$pathDir/stop_times.csv');
    final stopTimes = <GtfsStopTime>[];
    for (Map<String, dynamic> element in stopTimesList) {
      final stopTime = GtfsStopTime.fromJson(element);
      if(trips.any((trip) => trip.tripId == stopTime.tripId)) {
        stopTimes.add(stopTime);
      }
    }

    // SHAPES
    final shapesList = readFile('$pathDir/shapes.csv');
    final shapes = <GtfsShape>[];
    for (Map<String, dynamic> element in shapesList) {
      final shape = GtfsShape.fromJson(element);
      if(trips.any((trip) => trip.shapeId == shape.shapeId)) {
        shapes.add(shape);
      }
    }


    final schemaRoutes = <GtfsRoute>[];
    final Map<String, List<GtfsStop>> stopsHierar = {};

    final dbRoutesFile = File('db/routes.json');
    dbRoutesFile.writeAsStringSync(jsonEncode(routes.values.toList()));
    print('routes: ${routes.values.length}');

    final dbTripsFile = File('db/trips.json');
    dbTripsFile.writeAsStringSync(jsonEncode(trips));
    print('trips: ${trips.length}');

    final dbStopTimesFile = File('db/stop_times.json');
    dbStopTimesFile.writeAsStringSync(jsonEncode(stopTimes));
    print('stop_times: ${stopTimes.length}');

    final dbStopsFile = File('db/stops.json');
    dbStopsFile.writeAsStringSync(jsonEncode(stops.values.toList()));
    print('stops: ${stops.values.length}');

    // Itération sur les routes
    routes.forEach((routeId, route) {
      final Set<String> stopsRoute = {};
      final List<GtfsShape> routeShapes = [];

      // Récupération trips correspondant à la route
      final List<GtfsTrip> gt =
          trips.where((trip) => trip.routeId == routeId).toList();

      // Itération sur les trips
      for (GtfsTrip t in gt) {
        // Récupération stoptimes correspondant au trip
        final List<GtfsStopTime> gstList =
            stopTimes.where((st) => st.tripId == t.tripId).toList();

        for (GtfsStopTime st in gstList) {
          final GtfsStop stop = stops[st.stopId]!;
          stopsRoute.add(st.stopId);

          if (!stopsHierar.containsKey(stop.stopName)) {
            stopsHierar[stop.stopName] = [];
          }
          if (!stopsHierar[stop.stopName]!
              .any((element) => element.stopId == stop.stopId)) {
            stopsHierar[stop.stopName]!.add(stop);
          }
        }

        final tripShapes = shapes.where((shape) => shape.shapeId == t.shapeId).toList();
        if(tripShapes.length > routeShapes.length) {
          routeShapes.clear();
          routeShapes.addAll(tripShapes);
        }
      }

      print('$routeId - ${stopsRoute.length} - ${routeShapes.length}');
      route.stops = stopsRoute.toList()..sort();
      route.shapes = routeShapes;

      schemaRoutes.add(route);
    });

    schemaRoutes.sort((a, b) {
      if(a.routeType?.name == b.routeType?.name) {
        return a.routeId.compareTo(b.routeId);
      } else {
        return a.routeType!.name.compareTo(b.routeType!.name);
      }

    });
    // Transformation liste stops en liste hierarchique

    final schema = <String, dynamic>{};
    schema['stops'] = stopsHierar;
    schema['routes'] = schemaRoutes.map((e) => e.toJson()).toList();

    // Ecriture du fichier final
    final jsonFile = File('files/schema_transports.json');
    jsonFile.writeAsStringSync(jsonEncode(schema));

    print('ok');
  } catch (e) {
    print(e.toString());
  }
}
