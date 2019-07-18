import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';

abstract class Store {
  void storeDate(File file);
  Future<bool> shouldDownload(File file);
}

class SharedPreferencesStore implements Store {
  @override
  Future<bool> shouldDownload(File file) {
    return SharedPreferences.getInstance().then((p) {
      var retVal = false;

      if (p.containsKey(file.absolute.path)) {
        retVal = DateTime.parse(p.getString(file.absolute.path))
            .isAfter(DateTime.now());
      }

      return retVal;
    });
  }

  @override
  void storeDate(File file) => SharedPreferences.getInstance().then((p) {
        p.setString(file.absolute.path, DateTime.now().toString());
      });
}
