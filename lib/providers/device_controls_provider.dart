import 'package:flutter/foundation.dart';

class DeviceControlsProvider extends ChangeNotifier {
  double _brightness = 0.5; // 0.0 to 1.0
  double _volume = 0.5; // 0.0 to 1.0
  bool _isMuted = false;
  bool _isOrientationLocked = false;

  // Getters
  double get brightness => _brightness;
  double get volume => _volume;
  bool get isMuted => _isMuted;
  bool get isOrientationLocked => _isOrientationLocked;

  // Brightness methods
  void setBrightness(double value) {
    _brightness = value.clamp(0.0, 1.0);
    notifyListeners();
  }

  void increaseBrightness(double delta) {
    setBrightness(_brightness + delta);
  }

  void decreaseBrightness(double delta) {
    setBrightness(_brightness - delta);
  }

  // Volume methods
  void setVolume(double value) {
    _volume = value.clamp(0.0, 1.0);
    _isMuted = false;
    notifyListeners();
  }

  void increaseVolume(double delta) {
    setVolume(_volume + delta);
  }

  void decreaseVolume(double delta) {
    setVolume(_volume - delta);
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    notifyListeners();
  }

  void setMuted(bool muted) {
    _isMuted = muted;
    notifyListeners();
  }

  // Orientation methods
  void toggleOrientationLock() {
    _isOrientationLocked = !_isOrientationLocked;
    notifyListeners();
  }

  void setOrientationLocked(bool locked) {
    _isOrientationLocked = locked;
    notifyListeners();
  }

  // Reset all to defaults
  void reset() {
    _brightness = 0.5;
    _volume = 0.5;
    _isMuted = false;
    _isOrientationLocked = false;
    notifyListeners();
  }
}
