

import 'dart:io';

import 'package:download_manager/download_manager.dart';

void main() {

  File testFile = File("Testfile");
  if (testFile.existsSync()) {
    testFile.deleteSync();
  }

  DownloadManager.instance.add(DownloadableFileBasic(() => "Test string", testFile));

  print(testFile.readAsStringSync());
}