import 'dart:convert';
import 'dart:io';

import 'package:angersmap_data/checksum.dart';
import 'package:angersmap_data/config.dart';
import 'package:angersmap_data/db.dart';
import 'package:angersmap_data/extract_gtfs.dart';
import 'package:angersmap_data/generate_calendar.dart';
import 'package:angersmap_data/generate_files.dart';

Future<void> main(List<dynamic> args) async {
  config = Config.fromJson(jsonDecode(File(args[0]).readAsStringSync()));

  // await extractGtfs();
  // await generateFiles();
  // await generateCalendar();
  await generateDb();
  checksum();
}
