import 'dart:io';
import 'package:path/path.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert'; // for the utf8.encode method

void checksum() {
  final Map<String, dynamic> files =
      browseDirectory('${Directory.current.path}/files');
  print(files);
  final File file = File('${Directory.current.path}/files/versions.json');
  file.writeAsStringSync(jsonEncode(files));
}

Map<String, dynamic> browseDirectory(String uri) {
  final Map<String, dynamic> files = {};
  final List<FileSystemEntity> entries = Directory(uri).listSync();
  for (final FileSystemEntity entity in entries) {
    if (entity is File) {
      files[basenameWithoutExtension(entity.path)] = getSha1(entity.path);
    } else {
      files[basename(entity.path)] = browseDirectory(entity.path);
    }
  }
  return files;
}

String getSha1(String uri) =>
    sha1.convert(File(uri).readAsBytesSync()).toString();
