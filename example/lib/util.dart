import 'dart:io';
import 'package:path_provider/path_provider.dart';

class UrlToFilename {
  static Future<File> file(String url) => getApplicationDocumentsDirectory()
          .then((dir) => Directory(dir.path + "/data/"))
          .then((dir) async {
        if (!await dir.exists()) {
          dir.create();
        }

        return File("${dir.path}/${url.split('/').last}");
      });
}
