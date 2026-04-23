import "dart:async";
import "dart:io";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:photo_manager/photo_manager.dart";
import "package:video_player/video_player.dart";
import "package:volume_controller/volume_controller.dart";

enum VideoRepeatMode { off, one, all, shuffle }

/// [PlayerViewModel] handles the business logic for the video player screen,
/// including video initialization, playback controls, gesture handling for volume/seeking,
/// and maintaining the state of the player UI.
class PlayerViewModel extends ChangeNotifier {
  /// List of [AssetEntity] representing the videos available to play.
  final List<AssetEntity> assetEntities;

  /// Index of the currently playing video in [assetEntities].
  int currentIndex;

  /// The [VideoPlayerController] that manages the actual video playback.
  VideoPlayerController? _controller;
  VideoPlayerController get controller => _controller!;

  /// Returns true if the video controller is initialized and ready.
  bool get isInitialized =>
      _controller != null && _controller!.value.isInitialized;

  /// Instance of [VolumeController] for managing system and app volume.
  final VolumeController _volumeController = VolumeController.instance;

  /// Whether to show the main progress bar and controls overlay.
  bool _showOverlayProgressBar = false;
  bool get showOverlayProgressBar => _showOverlayProgressBar;

  /// Whether to show the vertical volume adjustment overlay.
  bool _showOverlaySoundBar = false;
  bool get showOverlaySoundBar => _showOverlaySoundBar;

  /// Whether to show the horizontal seek adjustment overlay.
  bool _showOverlaySeek = false;
  bool get showOverlaySeek => _showOverlaySeek;

  /// Current seek offset being displayed during horizontal drag.
  Duration _seekValue = Duration.zero;
  Duration get seekValue => _seekValue;

  /// Current volume level (0.0 to 1.0).
  double _volumeValue = 0;
  double get volumeValue => _volumeValue;

  /// Whether the player is currently muted.
  bool _isMuted = false;
  bool get isMuted => _isMuted;

  /// Whether all audio is explicitly disabled for the session.
  bool _isAudioDisabled = false;
  bool get isAudioDisabled => _isAudioDisabled;

  /// The current video repetition behavior.
  VideoRepeatMode _repeatMode = VideoRepeatMode.off;
  VideoRepeatMode get repeatMode => _repeatMode;

  /// The current playback speed (e.g., 1.0, 1.5, 2.0).
  double _playbackSpeed = 1.0;
  double get playbackSpeed => _playbackSpeed;

  /// Stores the volume level at the start of a vertical drag gesture.
  double _dragStartVolume = 0;

  /// Stores the Y-coordinate at the start of a vertical drag gesture.
  double _dragStartY = 0;

  /// Stores the X-coordinate at the start of a horizontal drag gesture.
  double _dragStartX = 0;

  /// Stores the video position at the start of a horizontal drag gesture.
  Duration _dragStartPosition = Duration.zero;

  /// Timer used to automatically hide the overlay after inactivity.
  Timer? _hideOverlayTimer;

  /// List of supported aspect ratios for the video player.
  final List<double?> _aspectRatios = [null, 16 / 9, 4 / 3, 1 / 1];

  /// Current index in [_aspectRatios].
  int _currentAspectRatioIndex = 0;
  double? get currentAspectRatio => _aspectRatios[_currentAspectRatioIndex];

  /// The title of the current video asset.
  String get currentTitle => assetEntities.isEmpty
      ? ""
      : assetEntities[currentIndex].title ?? "Unknown";

  /// Whether the player is currently in background audio mode.
  bool _isBackgroundPlay = false;
  bool get isBackgroundPlay => _isBackgroundPlay;

  PlayerViewModel({required this.assetEntities, required this.currentIndex}) {
    if (assetEntities.isNotEmpty) {
      _init();
    }
  }

  /// Updates the playlist and index, then re-initializes.
  Future<void> updateAssets(List<AssetEntity> assets, int index) async {
    assetEntities.clear();
    assetEntities.addAll(assets);
    currentIndex = index;
    await _reInitialize();
  }

  /// Initializes the video player by loading the file from [AssetEntity],
  /// setting up the controller, listeners, and initial volume states.
  Future<void> _init() async {
    if (assetEntities.isEmpty) return;
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

  /// Listener attached to the [VideoPlayerController] to monitor playback progress.
  /// It triggers [_handleVideoEnd] when the video reaches its duration.
  void _videoListener() {
    if (_controller == null) return;

    if (_controller!.value.position >= _controller!.value.duration) {
      _handleVideoEnd();
    }
    notifyListeners();
  }

  /// Handles logic when a video finishes playing based on the current [_repeatMode].
  void _handleVideoEnd() {
    if (_controller == null) return;
    switch (_repeatMode) {
      case VideoRepeatMode.one:
        // Restart current video.
        _controller!.seekTo(Duration.zero);
        _controller!.play();
        break;
      case VideoRepeatMode.all:
        // Play next, wrapping around to the start if at the end.
        playNext();
        break;
      case VideoRepeatMode.shuffle:
        // Play next (standard behavior here, could be enhanced with true randomization).
        playNext();
        break;
      case VideoRepeatMode.off:
        // Play next only if there are more videos in the list.
        if (currentIndex < assetEntities.length - 1) {
          playNext();
        }
        break;
    }
  }

  /// Advances to the next video in the list.
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

  /// Moves to the previous video in the list.
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

  /// Disposes of the current controller and re-runs initialization for a new video index.
  Future<void> _reInitialize() async {
    if (_controller != null) {
      final oldController = _controller;
      _controller = null; // Set to null before disposal
      notifyListeners(); // Notify UI that controller is null (will show loader)

      oldController!.removeListener(_videoListener);
      await oldController.dispose();
    }
    await _init();
  }

  /// Explicitly disables or enables audio for the video.
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

  /// Cycles through available repeat modes: off -> one -> all -> shuffle.
  void cycleRepeatMode() {
    _repeatMode = VideoRepeatMode
        .values[(_repeatMode.index + 1) % VideoRepeatMode.values.length];
    notifyListeners();
  }

  /// Toggles background playback.
  void toggleBackgroundPlay(BuildContext context) {
    _isBackgroundPlay = true;
    // Pop the player screen to show the floating bar in the list view
    Navigator.pop(context);
    notifyListeners();
  }

  /// Stops the current video and clears the controller.
  Future<void> stop() async {
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      await _controller!.dispose();
      _controller = null;
      _isBackgroundPlay = false;
      notifyListeners();
    }
  }

  /// Exits background mode and returns to full video player.
  void exitBackgroundMode(BuildContext context) {
    _isBackgroundPlay = false;
    notifyListeners();
  }

  /// Toggles between play and pause states.
  void togglePlay() {
    if (_controller == null) return;
    if (_controller!.value.isPlaying) {
      pause();
    } else {
      play();
      resetOverlayTimer();
    }
  }

  /// Updates the video playback speed.
  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _controller?.setPlaybackSpeed(speed);
    notifyListeners();
  }

  /// Schedules a timer to hide the progress bar overlay after 2 seconds of inactivity.
  void resetOverlayTimer() {
    if (!_showOverlayProgressBar) return;
    _hideOverlayTimer?.cancel();
    _hideOverlayTimer = Timer(const Duration(seconds: 2), () {
      _showOverlayProgressBar = false;
      notifyListeners();
    });
  }

  /// Resumes video playback.
  void play() {
    _controller?.play();
    notifyListeners();
  }

  /// Pauses video playback.
  void pause() {
    _controller?.pause();
    notifyListeners();
  }

  /// Handles a tap on the video surface to show or hide the controls overlay.
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

  /// Initiates vertical drag gesture handling for volume control.
  void onVerticalDragStart(DragStartDetails details) async {
    _showOverlaySoundBar = true;
    _dragStartY = details.globalPosition.dy;
    _dragStartVolume = await _volumeController.getVolume();
    _volumeValue = _dragStartVolume;
    notifyListeners();
  }

  /// Updates volume based on the vertical distance dragged.
  void onVerticalDragUpdate(DragUpdateDetails details, double height) {
    final deltaY = _dragStartY - details.globalPosition.dy;
    final volumeDelta = deltaY / height;
    _volumeValue = (_dragStartVolume + volumeDelta).clamp(0.0, 1.0);
    _volumeController.setVolume(_volumeValue);
    notifyListeners();
  }

  /// Ends the vertical drag gesture and hides the volume overlay.
  void onVerticalDragEnd(DragEndDetails details) {
    _showOverlaySoundBar = false;
    notifyListeners();
  }

  /// Initiates horizontal drag gesture handling for seeking within the video.
  void onHorizontalDragStart(DragStartDetails details) {
    if (_controller == null) return;
    // Show the small seek overlay and hide the main progress bar overlay if visible
    _showOverlaySeek = true;
    _showOverlayProgressBar = false;
    _dragStartX = details.globalPosition.dx;
    _dragStartPosition = _controller!.value.position;
    _seekValue = Duration.zero; // Reset current seek offset
    _hideOverlayTimer?.cancel();
    notifyListeners();
  }

  /// Updates the video position based on the horizontal distance dragged.
  void onHorizontalDragUpdate(DragUpdateDetails details, double width) {
    if (_controller == null) return;
    final deltaX = details.globalPosition.dx - _dragStartX;
    // Lower sensitivity for precise seeking
    const sensitivity = 0.5;
    final seekRelative = (deltaX / width) * sensitivity;
    final seekDuration = _controller!.value.duration * seekRelative;
    var newPosition = _dragStartPosition + seekDuration;

    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    } else if (newPosition > _controller!.value.duration) {
      newPosition = _controller!.value.duration;
    }

    // Update the seek value for UI display (e.g., +10s or -10s)
    _seekValue = newPosition - _dragStartPosition;

    _controller!.seekTo(newPosition);
    notifyListeners();
  }

  /// Ends the horizontal drag gesture and hides the seek overlay.
  void onHorizontalDragEnd(DragEndDetails details) {
    // Hide seek overlay immediately on release
    _showOverlaySeek = false;
    // We don't necessarily show progress bar here unless we want to
    notifyListeners();
  }

  /// Updates the mute status of the device/application.
  Future<void> updateMuteStatus(bool isMute) async {
    await _volumeController.setMute(isMute);
    if (Platform.isIOS) {
      // Small delay for IOS to ensure the system mute status is correctly updated.
      await Future.delayed(const Duration(milliseconds: 50));
    }
    _isMuted = await _volumeController.isMuted();
    notifyListeners();
  }

  /// Toggles whether the system volume UI (the native volume bar) should be visible.
  void toggleSystemUI() {
    _volumeController.showSystemUI = !_volumeController.showSystemUI;
    notifyListeners();
  }

  /// Whether the system volume UI is currently enabled.
  bool get showSystemUI => _volumeController.showSystemUI;

  /// Sets the volume level directly.
  void setVolume(double value) {
    _volumeValue = value;
    _volumeController.setVolume(value);
    notifyListeners();
  }

  /// Seeks to a specific point in the video when adjusting the progress slider.
  void onSliderSeek(double value) {
    if (_controller == null) return;
    final destination = _controller!.value.duration * value;
    _controller!.seekTo(destination);
    resetOverlayTimer();
    notifyListeners();
  }

  /// Cycles through different video aspect ratios (Fit, 16:9, 4:3, 1:1).
  void toggleAspectRatio() {
    _currentAspectRatioIndex =
        (_currentAspectRatioIndex + 1) % _aspectRatios.length;
    resetOverlayTimer();
    notifyListeners();
  }

  /// Toggles the device orientation between portrait and landscape.
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

  /// Forces the device orientation back to portrait.
  void resetRotation() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  void dispose() {
    // Clean up controller and listeners when the view model is destroyed.
    if (_controller != null) {
      _controller!.removeListener(_videoListener);
      _controller!.dispose();
    }
    _hideOverlayTimer?.cancel();
    super.dispose();
  }
}
