import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:flutter/material.dart';
import 'package:gdsc_hackathon_project/models/media.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

class Helper {
  static Map<String, String> paths = {};
  static void init() {
    ReceivePort _port = ReceivePort();
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
    });
    FlutterDownloader.registerCallback(Helper.downloadCallback);
  }

  static String timeToString() {
    return DateTime.now().toString().replaceAll(RegExp(r'\.|:|-| '), "");
  }

  static downloadFile(Media media) async {
    Directory directory = (await getExternalStorageDirectories())![0];

    final String taskId = (await FlutterDownloader.enqueue(
      url: media.url,
      savedDir: directory.path,
      showNotification: true,
      openFileFromNotification: true,
      saveInPublicStorage: true,
    ))!;
    // await FlutterDownloader.open(taskId: taskId);
  }

  static void downloadCallback(
      String id, DownloadTaskStatus status, int progress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, progress]);
  }
}
