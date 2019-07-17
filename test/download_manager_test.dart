import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:download_manager/download_manager.dart';

void main() {
  test('tests the model can store a file on disk', () async {
    File testFile = File("test_file.txt");
    setupFile(testFile);

    var downloadFile = DownloadableFileBasic(() => "Test string", testFile);
    var result = await downloadFile.download();
    assert(result);
    assert(testFile.existsSync());
    expect(testFile.readAsStringSync(), "Test string");

    setupFile(testFile);
  });

  test('test that downloader can download a file', () async {
    File testBFile = File("test_b.txt");
    setupFile(testBFile);

    await DownloadManager.instance.add(DownloadableFileBasic(() => "Test string", testBFile));
    expectLater(DownloadManager.instance.fileStream, emits(testBFile));
    setupFile(testBFile);


  });
}

void setupFile(File file) {
  if (file.existsSync()) {
    file.deleteSync();
  }
}
