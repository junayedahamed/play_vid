import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
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
  Timer? _hideOverlayTimer;

  PlayerViewModel({required this.filePath}) {
    _init();
  }

  Future<void> _init() async {
    controller = VideoPlayerController.file(File(filePath));
    await controller.initialize();
    _volumeValue = await _volumeController.getVolume();
    _isMuted = await _volumeController.isMuted();
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
    _showOverlayProgressBar = true;
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(
      const Duration(seconds: 1, milliseconds: 200),
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

  void onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    _showOverlayProgressBar = true;
    final relative = details.localPosition.dx / width;
    final position = controller.value.duration * relative.clamp(0, 1);
    controller.seekTo(position);
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

  @override
  void dispose() {
    controller.dispose();
    _hideOverlayTimer?.cancel();
    super.dispose();
  }
}
