import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NavigationHelper {
  static push(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
  }

  static pop(BuildContext context) {
    Navigator.of(context).pop();
  }

  static showLoader(context, {String message = "Loading"}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
          content: Row(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(width: 30),
          Text(message)
        ],
      )),
    );
  }

  static Future<List<PlatformFile>> pickFiles() async {
    final FilePickerResult? res = await FilePicker.platform
        .pickFiles(withData: true, allowMultiple: true);
    if (res == null) {
      return [];
    }
    return res.files;
  }
}
