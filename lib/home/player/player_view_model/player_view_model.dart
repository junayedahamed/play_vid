import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:photo_manager/photo_manager.dart";
import "package:video_player/video_player.dart";
import "package:volume_controller/volume_controller.dart";

enum VideoRepeatMode { off, one, all, shuffle }

class PlayerViewModel extends ChangeNotifier {
  final List<AssetEntity> assetEntities;
  int currentIndex;

  VideoPlayerController? _controller;
  VideoPlayerController get controller => _controller!;

  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  final VolumeController _volumeController = VolumeController.instance;

  bool _showOverlayProgressBar = false;
  bool get showOverlayProgressBar => _showOverlayProgressBar;

  bool _showOverlaySoundBar = false;
  bool get showOverlaySoundBar => _showOverlaySoundBar;

  double _volumeValue = 0;
  double get volumeValue => _volumeValue;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isAudioDisabled = false;
  bool get isAudioDisabled => _isAudioDisabled;

  VideoRepeatMode _repeatMode = VideoRepeatMode.off;
  VideoRepeatMode get repeatMode => _repeatMode;

  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  double _dragStartVolume = 0;
  double _dragStartY = 0;

  double _dragStartX = 0;
  Duration _dragStartPosition = Duration.zero;

  Timer? _hideOverlayTimer;

  final List<double?> _aspectRatios = [null, 16 / 9, 4 / 3, 1 / 1];
  int _currentAspectRatioIndex = 0;
  double? get currentAspectRatio => _aspectRatios[_currentAspectRatioIndex];

  String get currentTitle => assetEntities[currentIndex].title ?? "Unknown";

  PlayerViewModel({required this.assetEntities, required this.currentIndex}) {
    _init();
  }

  Future<void> _init() async {
    final file = await assetEntities[currentIndex].file;
    if (file == null) return;

    final newController = VideoPlayerController.file(file);
    await newController.initialize();
    await newController.setPlaybackSpeed(_playbackSpeed);

    _controller = newController;
    _controller!.addListener(_videoListener);

    _volumeValue = await _volumeController.getVolume();
    _isMuted = await _volumeController.isMuted();

    if (_isAudioDisabled) {
      await _controller!.setVolume(0);
    }

    _controller!.play();
    notifyListeners();
  }

  void _videoListener() {
    if (_controller == null) return;
    if (_controller!.value.position >= _controller!.value.duration) {
      _handleVideoEnd();
    }
    notifyListeners();
  }

  void _handleVideoEnd() {
    if (_controller == null) return;
    switch (_repeatMode) {
      case VideoRepeatMode.one:
        _controller!.seekTo(Duration.zero);
        _controller!.play();
        break;
      case VideoRepeatMode.all:
        playNext();
        break;
      case VideoRepeatMode.shuffle:
        playNext();
        break;
      case VideoRepeatMode.off:
        if (currentIndex < assetEntities.length - 1) {
          playNext();
        }
        break;
    }
  }

  Future<void> playNext() async {
    if (currentIndex < assetEntities.length - 1) {
      currentIndex++;
    } else if (_repeatMode == VideoRepeatMode.all) {
      currentIndex = 0;
    } else {
      return;
    }
    await _reInitialize();
  }

  Future<void> playPrevious() async {
    if (currentIndex > 0) {
      currentIndex--;
    } else if (_repeatMode == VideoRepeatMode.all) {
      currentIndex = assetEntities.length - 1;
    } else {
      return;
    }
    await _reInitialize();
  }

  Future<void> _reInitialize() async {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      await _controller!.dispose();
      _controller = null;
      notifyListeners();
    }
    await _init();
  }

  void setAudioDisabled(bool disabled) {
    _isAudioDisabled = disabled;
    if (_controller != null) {
      if (_isAudioDisabled) {
        _controller!.setVolume(0);
      } else {
        _controller!.setVolume(_isMuted ? 0 : _volumeValue);
      }
    }
    notifyListeners();
  }

  void cycleRepeatMode() {
    _repeatMode = VideoRepeatMode
        .values[(_repeatMode.index + 1) % VideoRepeatMode.values.length];
    notifyListeners();
  }

  void toggleBackgroundPlay() {}

  void togglePlay() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      _controller!.pause();
    } else {
      _controller!.play();
      resetOverlayTimer();
    }
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _controller?.setPlaybackSpeed(speed);
    notifyListeners();
  }

  void resetOverlayTimer() {
    if (!_showOverlayProgressBar) return;
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(const Duration(seconds: 2), () {
      _showOverlayProgressBar = false;
      notifyListeners();
    });
  }

  void play() {
    _controller?.play();
    notifyListeners();
  }

  void pause() {
    _controller?.pause();
    notifyListeners();
  }

  void handleTap() {
    if (_showOverlayProgressBar) {
      _showOverlayProgressBar = false;
      _hideOverlayTimer?.cancel();
      notifyListeners();
      return;
    }
    _showOverlayProgressBar = true;
    resetOverlayTimer();
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
    if (_controller == null) return;
    _showOverlayProgressBar = true;
    _dragStartX = details.globalPosition.dx;
    _dragStartPosition = _controller!.value.position;
    _hideOverlayTimer?.cancel();
    notifyListeners();
  }

  void onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    if (_controller == null) return;
    _showOverlayProgressBar = true;
    final deltaX = details.globalPosition.dx - _dragStartX;
    const sensitivity = 0.2;
    final seekRelative = (deltaX / width) * sensitivity;
    final seekDuration = _controller!.value.duration * seekRelative;
    var newPosition = _dragStartPosition + seekDuration;

    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    } else if (newPosition > _controller!.value.duration) {
      newPosition = _controller!.value.duration;
    }

    _controller!.seekTo(newPosition);
    notifyListeners();
  }

  void onHorizontalDragEnd(DragEndDetails details) {
    resetOverlayTimer();
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
    if (_controller == null) return;
    final destination = _controller!.value.duration * value;
    _controller!.seekTo(destination);
    resetOverlayTimer();
    notifyListeners();
  }

  void toggleAspectRatio() {
    _currentAspectRatioIndex =
        (_currentAspectRatioIndex + 1) % _aspectRatios.length;
    resetOverlayTimer();
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
    resetOverlayTimer();
  }

  void resetRotation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }
    _hideOverlayTimer?.cancel();
    super.dispose();
  }
}
