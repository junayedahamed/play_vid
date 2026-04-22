import 'package:flutter/material.dart';

class DownloadvideoFetch extends ChangeNotifier {
  List videoList = [];
  Future<void> downloadVideo() async {
    notifyListeners();
  }
}
