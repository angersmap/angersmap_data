import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:http/http.dart';

void cleanDir(String pathDir) {
  final dir = Directory(pathDir);
  final files = dir.listSync();
  for (FileSystemEntity file in files) {
    file.deleteSync();
  }
}


Future<void> _extractGtfs(String url, String pathDir) async {
  try {
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

    print('ok');
  } catch (e) {
    print(e.toString());
  }
}

Future<void> extractGtfs(String pathDir) async {
  cleanDir(pathDir);
  await _extractGtfs(
  'https://chouette.enroute.mobi/api/v1/datas/Irigo/gtfs.zip', pathDir);
}