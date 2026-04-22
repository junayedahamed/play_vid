import 'package:flutter/foundation.dart';
import '../models/video.dart';

class VideoProvider extends ChangeNotifier {
  List<Video> _videoList = [];
  int _currentIndex = 0;
  bool _isPlaying = false;

  // Getters
  List<Video> get videoList => _videoList;
  int get currentIndex => _currentIndex;
  Video? get currentVideo =>
      _videoList.isNotEmpty ? _videoList[_currentIndex] : null;
  bool get isPlaying => _isPlaying;

  // Setters and methods
  void setVideoList(List<Video> videos) {
    _videoList = videos;
    _currentIndex = 0;
    notifyListeners();
  }

  void addVideos(List<Video> videos) {
    _videoList.addAll(videos);
    notifyListeners();
  }

  void setCurrentIndex(int index) {
    if (index >= 0 && index < _videoList.length) {
      _currentIndex = index;
      notifyListeners();
    }
  }

  void nextVideo() {
    if (_currentIndex < _videoList.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
  }

  void previousVideo() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void setPlaying(bool playing) {
    _isPlaying = playing;
    notifyListeners();
  }

  void removeVideo(int index) {
    if (index >= 0 && index < _videoList.length) {
      _videoList.removeAt(index);
      if (_currentIndex >= _videoList.length && _currentIndex > 0) {
        _currentIndex--;
      }
      notifyListeners();
    }
  }

  void clearPlaylist() {
    _videoList.clear();
    _currentIndex = 0;
    _isPlaying = false;
    notifyListeners();
  }
}
