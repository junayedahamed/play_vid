import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:volume_controller/volume_controller.dart';

class PlayerViewModel extends ChangeNotifier {
  final String filePath;
  late VideoPlayerController controller;
  final VolumeController _volumeController = VolumeController.instance;

  bool _showOverlayProgressBar = false;
  bool get showOverlayProgressBar => _showOverlayProgressBar;

  bool _showOverlaySoundBar = false;
  bool get showOverlaySoundBar => _showOverlaySoundBar;

  double _volumeValue = 0;
  double get volumeValue => _volumeValue;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  double _dragStartVolume = 0;
  double _dragStartY = 0;

  double _dragStartX = 0;
  Duration _dragStartPosition = Duration.zero;

  Timer? _hideOverlayTimer;

  final List<double?> _aspectRatios = [null, 16 / 9, 4 / 3, 1 / 1];
  int _currentAspectRatioIndex = 0;
  double? get currentAspectRatio => _aspectRatios[_currentAspectRatioIndex];

  PlayerViewModel({required this.filePath}) {
    _init();
  }

  Future<void> _init() async {
    controller = VideoPlayerController.file(File(filePath));
    await controller.initialize();
    controller.addListener(_videoListener);
    _volumeValue = await _volumeController.getVolume();
    _isMuted = await _volumeController.isMuted();
    notifyListeners();
  }

  void _videoListener() {
    notifyListeners();
  }

  void togglePlay() {
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
    notifyListeners();
  }

  void play() {
    controller.play();
    notifyListeners();
  }

  void pause() {
    controller.pause();
    notifyListeners();
  }

  void handleTap() {
    if (_showOverlayProgressBar) {
      _showOverlayProgressBar = false;
      notifyListeners();
      return;
    }
    _showOverlayProgressBar = true;
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(
      const Duration(seconds: 2, milliseconds: 200),
      () {
        _showOverlayProgressBar = false;
        notifyListeners();
      },
    );
    notifyListeners();
  }

  void onVerticalDragStart(DragStartDetails details) async {
    _showOverlaySoundBar = true;
    _dragStartY = details.globalPosition.dy;
    _dragStartVolume = await _volumeController.getVolume();
    _volumeValue = _dragStartVolume;
    notifyListeners();
  }

  void onVerticalDragUpdate(DragUpdateDetails details, double height) {
    final deltaY = _dragStartY - details.globalPosition.dy;
    final volumeDelta = deltaY / height;
    _volumeValue = (_dragStartVolume + volumeDelta).clamp(0.0, 1.0);
    _volumeController.setVolume(_volumeValue);
    notifyListeners();
  }

  void onVerticalDragEnd(DragEndDetails details) {
    _showOverlaySoundBar = false;
    notifyListeners();
  }

  void onHorizontalDragStart(DragStartDetails details) {
    _showOverlayProgressBar = true;
    _dragStartX = details.globalPosition.dx;
    _dragStartPosition = controller.value.position;
    _hideOverlayTimer?.cancel();
    notifyListeners();
  }

  void onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    _showOverlayProgressBar = true;
    // Calculate drag distance from start point
    final deltaX = details.globalPosition.dx - _dragStartX;

    // Use a sensitivity factor to make seeking less extreme.
    // 0.2 means a full screen drag moves through 20% of the video.
    const sensitivity = 0.2;
    final seekRelative = (deltaX / width) * sensitivity;

    final seekDuration = controller.value.duration * seekRelative;
    var newPosition = _dragStartPosition + seekDuration;

    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    } else if (newPosition > controller.value.duration) {
      newPosition = controller.value.duration;
    }

    controller.seekTo(newPosition);
    notifyListeners();
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(const Duration(seconds: 1), () {
      _showOverlayProgressBar = false;
      notifyListeners();
    });
  }

  Future<void> updateMuteStatus(bool isMute) async {
    await _volumeController.setMute(isMute);
    if (Platform.isIOS) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    _isMuted = await _volumeController.isMuted();
    notifyListeners();
  }

  void toggleSystemUI() {
    _volumeController.showSystemUI = !_volumeController.showSystemUI;
    notifyListeners();
  }

  bool get showSystemUI => _volumeController.showSystemUI;

  void setVolume(double value) {
    _volumeValue = value;
    _volumeController.setVolume(value);
    notifyListeners();
  }

  void onSliderSeek(double value) {
    final destination = controller.value.duration * value;
    controller.seekTo(destination);
    notifyListeners();
  }

  void toggleAspectRatio() {
    _currentAspectRatioIndex =
        (_currentAspectRatioIndex + 1) % _aspectRatios.length;
    notifyListeners();
  }

  void toggleRotation(BuildContext context) {
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  void resetRotation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    controller.removeListener(_videoListener);
    controller.dispose();
    _hideOverlayTimer?.cancel();
    super.dispose();
  }
}
