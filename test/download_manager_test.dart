import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:download_manager/download_manager.dart';
import 'package:mockito/mockito.dart';

import 'mocks.dart';

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

    var downloadManager = DownloadManager(MockStore());
    expectLater(downloadManager.fileStream, emits(testBFile));

    await downloadManager
        .add(DownloadableFileBasic(() => "Test string", testBFile));
    setupFile(testBFile);
  });

  test('test that downloader will double download if the date time is null',
      () async {
    File testCFile = File("test_c.txt");
    setupFile(testCFile);

    var downloadManager = DownloadManager(MockStore());
    expectLater(
        downloadManager.fileStream, emitsInOrder([testCFile, testCFile]));
    expectLater(downloadManager.allFiles, emits([testCFile]));

    await downloadManager
        .add(DownloadableFileBasic(() => "Test string", testCFile));
    await downloadManager
        .add(DownloadableFileBasic(() => "Test string", testCFile));
    setupFile(testCFile);
  });

  test(
      'test that downloader will not double download if the date is not exceeded',
      () async {
    File testCFile = File("test_c.txt");
    setupFile(testCFile);

    var date = DateTime.now();

    var store = MockStore();
    when(store.shouldDownload(testCFile))
        .thenAnswer((_) => Future.value(false));

    var downloadManager = DownloadManager(store);
    expectLater(downloadManager.fileStream, emits(testCFile));
    expectLater(downloadManager.allFiles, emits([testCFile]));

    await downloadManager.add(
        DownloadableFileBasic(() => "Test string", testCFile, dateTime: null));
    assert(testCFile.existsSync());
    await downloadManager
        .add(DownloadableFileBasic(() => "Abc", testCFile, dateTime: date));

    // The second file should not have been downloaded - only the first
    expect(testCFile.readAsStringSync(), "Test string");
    setupFile(testCFile);
  });

  test("test that the clear button deletes all files", () async {
    File testFileD = File("test_file_e.txt");
    File testFileE = File("test_file_d.txt");

    setupFile(testFileE);
    setupFile(testFileD);

    var downloadFile = DownloadableFileBasic(() => "Test string", testFileE);
    var downloadFileOther =
        DownloadableFileBasic(() => "Test string", testFileD);

    var downloadManager = DownloadManager(MockStore());
    expectLater(
        downloadManager.allFiles,
        emitsInOrder([
          [testFileE],
          [testFileE, testFileD],
          []
        ]));
    await downloadManager.add(downloadFile);
    await downloadManager.add(downloadFileOther);

    assert(testFileD.existsSync());
    assert(testFileE.existsSync());

    await downloadManager.clear();

    assert(!testFileD.existsSync());
    assert(!testFileE.existsSync());
  });
}

void setupFile(File file) {
  if (file.existsSync()) {
    file.deleteSync();
  }
}
