import 'dart:convert';
import 'dart:io';

import 'package:angersmap_data/checksum.dart';
import 'package:angersmap_data/config.dart';
import 'package:angersmap_data/db.dart';

Future<void> main(List<dynamic> args) async {
  config = Config.fromJson(jsonDecode(File(args[0]).readAsStringSync()));

  // await extractGtfs();
  // await generateFiles();
  // await generateCalendar();
  await generateDb();
  checksum();
}
