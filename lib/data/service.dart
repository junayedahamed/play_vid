import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:play_vid/data/ip_tv_model.dart';

class Service {
  Future<List<IpTvModel>> getTvList() async {
    try {
      final response = await http.get(
        Uri.parse('https://iptv-org.github.io/api/streams.json'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body) as List<dynamic>;
        return data.map((json) => IpTvModel.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load TV list');
      }
    } catch (e) {
      // print(stackTrace);
      throw Exception('Error fetching TV list: $e');
    }
  }

  Future<List<String>> getStreamUrlTypes(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      if (response.statusCode == 200) {
        final contentType = response.headers['content-type'];
        if (contentType != null) {
          return contentType.split(',').map((type) => type.trim()).toList();
        }
      }
      throw Exception('Failed to fetch stream URL types');
    } catch (e) {
      throw Exception('Error fetching stream URL types: $e');
    }
  }
}
