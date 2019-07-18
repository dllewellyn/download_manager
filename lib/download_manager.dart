library download_manager;

import 'dart:async';
import 'dart:io';

import 'package:download_manager/src/store.dart';

/// Download manager class. With this class we can download files asynchronously
/// and update the calling application via a stream when the data is available.
///
/// If the modification date is set then the file will only be downloaded if the
/// file does not already exist, or if the modificationDate is newer than the currently
/// downloaded file's date
///
/// To use in this way
/// ```
/// var listOfFiles = [DownloadableFile(Function function, DateTime modificationDate, File name)]
/// DownloadManager.instance.retrieve(listOfFiles);
/// ```
///
/// You can also initialise with a 'retrieval' function, i.e. a function we can call
/// to retrieve the file. This function should take no arguments and return an 'Object' that can
/// be written to disk.
///
class DownloadManager {
  /// Store to use for tracking when files were downloaded
  final Store _store;

  /// A stream with the files which have been downloaded.
  Stream<File> get fileStream => _innerStream.stream;

  // Stream controller
  final StreamController<File> _innerStream =
      StreamController<File>.broadcast();

  DownloadManager(this._store);

  static DownloadManager instance = DownloadManager(SharedPreferencesStore());

  /// Add a file to the download queue
  ///
  /// @param file the file to download
  ///
  /// @note results will appear in [fileStream]
  Future add(DownloadableFile file) async {
    if (file.dateTime != null) {
      var shouldDownload = await _store.shouldDownload(file.destinationFile);

      if (!shouldDownload) {
        return Future.value();
      }
    }

    await _downloadNow(file)
        .catchError((err) => _innerStream.addError(err))
        .then((b) {
      if (file.destinationFile.existsSync()) {
        _innerStream.add(file.destinationFile);
      } else {
        _innerStream
            .addError("Failed to download to ${file.destinationFile.path}");
      }
    });
  }

  Future<File> _downloadNow(DownloadableFile file) async {
    await file.download();
    var exists = await file.destinationFile.exists();

    if (!exists) {
      throw FailedToDownloadException();
    }

    return file.destinationFile;
  }

  void dispose() {
    _innerStream.close();
  }
}

class FailedToDownloadException implements Exception {}

abstract class DownloadableFile {
  /// The date this file was added. This will prevent us from double downloading.
  /// If datetime is left empty, then we will download every time, if it is set
  /// we will only download the file if the file a. does not exist or b. the file
  /// we already have is older than the file we can download
  DateTime get dateTime;

  /// Download the file from server, returning a success or failure
  Future<bool> download();

  /// The underlying file that will be created
  File get destinationFile;
}

class DownloadableFileBasic implements DownloadableFile {
  /// The function you use to retrieve your data. The result
  /// will be written to disk
  final Function retrieveFunction;

  /// Destination file to store the data to
  @override
  final File destinationFile;

  /// The date this file was added. This will prevent us from double downloading.
  /// If datetime is left empty, then we will download every time, if it is set
  /// we will only download the file if the file a. does not exist or b. the file
  /// we already have is older than the file we can download
  @override
  final DateTime dateTime;

  DownloadableFileBasic(this.retrieveFunction, this.destinationFile,
      {this.dateTime});

  @override
  Future<bool> download() async {
    await _writeToFile();
    return destinationFile.exists();
  }

  Future _writeToFile() =>
      Future(() => destinationFile.openWrite().write(retrieveFunction()));
}
