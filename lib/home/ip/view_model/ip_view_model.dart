import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:play_vid/data/ip_tv_model.dart';

import '../../../data/service.dart';

class IpViewModel extends ChangeNotifier {
  IpViewModel() {
    getTvList();
  }
  List<IpTvModel> _tvList = [];
  bool _isLoading = false;

  List<IpTvModel> get tvList => _tvList;
  bool get isLoading => _isLoading;

  final service = Service();
  Future<void> getTvList() async {
    try {
      _isLoading = true;
      notifyListeners();
      _tvList = await service.getTvList();
      _isLoading = false;
    } catch (e) {
      log('Error fetching TV list: $e');
    } finally {
      notifyListeners();
      _isLoading = false;
    }
  }

  // Future<List<String>> getStreamUrlTypes(String url) async {
  //   try {
  //     final response = await service.getStreamUrlTypes(url);
  //     return response;
  //   } catch (e) {
  //     log('Error fetching stream URL types: $e');
  //     return [];
  //   }
  // }
}
