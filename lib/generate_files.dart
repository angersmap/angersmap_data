import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:checksum/models/gtfs_route.dart';
import 'package:checksum/models/gtfs_stop.dart';
import 'package:checksum/models/gtfs_stop_time.dart';
import 'package:checksum/models/gtfs_trip.dart';
import 'package:http/http.dart';

Future<void> extractGtfs(String url, String pathDir) async {
  try {
    Map<String, List<dynamic>> files = {};

    // Téléchargement du fichier zip GTFS
    final response = await get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Sauvegarde du fichier zip localement
      final bytes = response.bodyBytes;
      final file = File('gtfs/fichier_gtfs.zip');
      file.writeAsBytesSync(bytes);

      final dir = Directory(pathDir);
      if (!dir.existsSync()) {
        dir.create();
      }

      // Décompression du fichier zip
      final archive = ZipDecoder().decodeBytes(bytes);

      // Extraction des fichiers CSV
      final csvFiles = archive
          .where((file) => file.isFile && file.name.endsWith('.txt'))
          .toList();

      // Parcours des fichiers CSV
      for (final csvFile in csvFiles) {
        // Nom du fichier CSV
        final fileName = csvFile.name.split('.').first;

        // Extraction des données du fichier CSV
        final csvData = utf8.decode(csvFile.content);

        // Traitement des données du fichier CSV
        // final jsonData = processData(csvData);

        // files[fileName] = jsonDecode(jsonData);
        // Création du fichier JSON correspondant à chaque ligne de transport
        final jsonFile = File('$pathDir/$fileName.csv');
        jsonFile.writeAsStringSync(csvData);
      }

      print('Terminé');
    } else {
      print('Erreur lors du téléchargement du fichier GTFS');
    }

    log('ok');
  } catch (e) {
    log(e.toString());
  }
}

void cleanDir(String pathDir) {
  final dir = Directory(pathDir);
  final files = dir.listSync();
  for (FileSystemEntity file in files) {
    file.deleteSync();
  }
}

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

Future<void> main() async {
  try {
    final String pathDir = 'gtfs';

    cleanDir(pathDir);
    await extractGtfs(
        'https://chouette.enroute.mobi/api/v1/datas/Irigo/gtfs.zip', pathDir);

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
      routes[route.routeId] = route;
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
    schema['stops'] = stops;
    schema['routes'] = {};

    // Itération sur les routes
    routes.forEach((routeId, route) {

      Set<String> stopsRoute = {};

      // Récupération trips correspondant à la route
      final List<GtfsTrip> gt =
          trips.where((trip) => trip.routeId == routeId).toList();
      print('$routeId - ${gt.length}');

      // Itération sur les trips
      for(GtfsTrip t in gt) {

        // Récupération stoptimes correspondant au trip
        final List<GtfsStopTime> gstList = stopTimes.where((st) => st.tripId == t.tripId).toList();
        for(GtfsStopTime st in gstList) {
          final GtfsStop stop = stops[st.stopId]!;
          stopsRoute.add(stop.stopName);
        }
      }

      route.stops = stopsRoute.toList()..sort();
      schema['routes'][routeId] = route.toJson();
    });

    final jsonFile = File('files/schema.json');
    jsonFile.writeAsStringSync(jsonEncode(schema));

    Map<String, List<dynamic>> files = {};

    // final conn = await MySQLConnection.createConnection(
    //   host: 'rapa3054.odns.fr',
    //   port: 3306,
    //   collation: 'utf8mb3_general_ci',
    //   userName: 'rapa3054_angersmap',
    //   password: 'syLi=gGT)@o@',
    //   secure: false,
    //   databaseName: 'rapa3054_angersmap', // optional,
    // );
    //
    // // actually connect to database
    // await conn.connect();
    // final result = await conn.execute("SELECT * FROM gtfs_stops");
    // final Map<String, GtfsStop> stops = {};
    // for (final row in result.rows) {
    //   print(row.assoc());
    //   final GtfsStop stop = GtfsStop.fromJson(row.assoc());
    //   stops[stop.stopId] = stop;
    // }
    log('ok');
  } catch (e) {
    log(e.toString());
  }
}
