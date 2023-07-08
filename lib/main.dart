import 'package:checksum/checksum.dart';
import 'package:checksum/db.dart';
import 'package:checksum/extract_gtfs.dart';
import 'package:checksum/generate_files.dart';

Future<void> main() async {

  final String pathDir = 'gtfs';
  // await extractGtfs(pathDir);
  // await generateFiles(pathDir);
  await generateDb();
  // checksum();

}