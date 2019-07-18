import 'dart:async';
import 'dart:io';

import 'package:example/util.dart';
import 'package:flutter/material.dart';
import 'package:download_manager/download_manager.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Download manager - Demo app',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: SafeArea(
          child: DownloadListPage(
              files: ["http://ipv4.download.thinkbroadband.com/100MB.zip"]),
        ),
      ),
    );
  }
}

class DownloadedFile {
  final File file;
  final bool downloaded;

  DownloadedFile(this.file, this.downloaded);
}

class DownloadListPage extends StatefulWidget {
  /// URL of files to download
  final List<String> files;

  const DownloadListPage({Key key, this.files}) : super(key: key);

  @override
  _DownloadListPageState createState() => _DownloadListPageState();
}

class _DownloadListPageState extends State<DownloadListPage> {
  StreamController<List<DownloadableFileBasic>> downloadableFiles =
      StreamController.broadcast();
  List<DownloadableFileBasic> cache = List();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<DownloadedFile>>(
        stream: Observable.combineLatest2(
            downloadableFiles.stream, DownloadManager.instance().allFiles,
            (List<DownloadableFile> downloadable, List<File> downloaded) {
          List<DownloadedFile> files = List();
          downloadable.forEach((f) => files.add(DownloadedFile(
              f.destinationFile,
              downloaded.where((d) => d == f.destinationFile).isNotEmpty)));
          return files;
        }),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          return Center(
            child: Container(
              margin: const EdgeInsets.all(8.0),
              child: ListView(
                  children: snapshot.data
                      .map((x) => Row(
                            children: <Widget>[
                              Container(
                                  margin: const EdgeInsets.all(8.0),
                                  width: MediaQuery.of(context).size.width / 2 -
                                      30,
                                  child: AutoSizeText(x.file.absolute.path,
                                      maxLines: 2)),
                              Container(
                                margin: const EdgeInsets.all(8.0),
                                width:
                                    MediaQuery.of(context).size.width / 2 - 30,
                                child: AutoSizeText(
                                    x.downloaded
                                        ? "Downloaded"
                                        : "Not downloaded",
                                    maxLines: 2),
                              )
                            ],
                          ))
                      .toList()
                        ..add(Row(
                          children: [
                            FlatButton(
                              onPressed: () {
                                DownloadManager.instance().clear();
                              },
                              child: Text("Clear"),
                            ),
                            FlatButton(
                              onPressed: () {
                                cache.forEach(
                                    (f) => DownloadManager.instance().add(f));
                              },
                              child: Text("Download"),
                            )
                          ],
                        ))),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
    widget.files.forEach((f) async {
      var downloadable = DownloadableFileBasic(
          () => _download(f), await UrlToFilename.file(f));

      cache.add(downloadable);
      DownloadManager.instance().add(downloadable);
      downloadableFiles.add(cache);
    });
  }

  Future<String> _download(String url) async {
    return (await http.get(url)).body;
  }

  @override
  void dispose() {
    super.dispose();
    DownloadManager.instance().dispose();
  }
}
