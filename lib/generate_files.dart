import 'dart:convert';
import 'dart:io';

import 'package:angersmap_data/models/gtfs_route.dart';
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

    // STOP_TIMES
    final stopTimesList = readFile('$pathDir/stop_times.csv');
    final stopTimes = <GtfsStopTime>[];
    for (Map<String, dynamic> element in stopTimesList) {
      final stopTime = GtfsStopTime.fromJson(element);
      stopTimes.add(stopTime);
    }

    // TRIPS
    final tripsList = readFile('$pathDir/trips.csv');
    final trips = <GtfsTrip>[];
    for (Map<String, dynamic> element in tripsList) {
      final trip = GtfsTrip.fromJson(element);
      trips.add(trip);
    }

    final schema = <String, dynamic>{};

    schema['routes'] = [];

    final Map<String, List<GtfsStop>> stopsHierar = {};

    // Itération sur les routes
    routes.forEach((routeId, route) {
      Set<String> stopsRoute = {};

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
          stopsRoute.add(stop.stopName);

          if (!stopsHierar.containsKey(stop.stopName)) {
            stopsHierar[stop.stopName] = [];
          }
          if (!stopsHierar[stop.stopName]!
              .any((element) => element.stopId == stop.stopId)) {
            stopsHierar[stop.stopName]!.add(stop);
          }
        }
      }
      print('$routeId - ${stopsRoute.length}');
      route.stops = stopsRoute.toList()..sort();

      schema['routes'].add(route.toJson());
    });

    // Transformation liste stops en liste hierarchique

    schema['stops'] = stopsHierar;

    // Ecriture du fichier final
    final jsonFile = File('files/schema_transports.json');
    jsonFile.writeAsStringSync(jsonEncode(schema));

    print('ok');
  } catch (e) {
    print(e.toString());
  }
}
