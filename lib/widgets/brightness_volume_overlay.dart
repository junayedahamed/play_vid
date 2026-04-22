import 'package:flutter/cupertino.dart';
import 'package:better_player/better_player.dart';
import 'package:provider/provider.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:play_vid/providers/device_controls_provider.dart';

class BrightnessVolumeOverlay extends StatefulWidget {
  final BetterPlayerController playerController;

  const BrightnessVolumeOverlay({super.key, required this.playerController});

  @override
  State<BrightnessVolumeOverlay> createState() =>
      _BrightnessVolumeOverlayState();
}

class _BrightnessVolumeOverlayState extends State<BrightnessVolumeOverlay> {
  bool _showBrightnessIndicator = false;
  bool _showVolumeIndicator = false;

  @override
  void initState() {
    super.initState();
    VolumeController.instance.showSystemUI = false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        _handleVerticalDrag(details, context);
      },
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Invisible drag area
          SizedBox.expand(
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onVerticalDragUpdate: (details) {
                _handleVerticalDrag(details, context);
              },
            ),
          ),
          // Brightness indicator (left side)
          if (_showBrightnessIndicator)
            Positioned(
              left: 20,
              top: MediaQuery.of(context).size.height * 0.3,
              child: Consumer<DeviceControlsProvider>(
                builder: (context, controlsProvider, _) {
                  return _buildIndicatorOverlay(
                    icon: CupertinoIcons.brightness,
                    value: controlsProvider.brightness,
                  );
                },
              ),
            ),
          // Volume indicator (right side)
          if (_showVolumeIndicator)
            Positioned(
              right: 20,
              top: MediaQuery.of(context).size.height * 0.3,
              child: Consumer<DeviceControlsProvider>(
                builder: (context, controlsProvider, _) {
                  return _buildIndicatorOverlay(
                    icon: controlsProvider.isMuted
                        ? CupertinoIcons.speaker_slash_fill
                        : CupertinoIcons.speaker_2_fill,
                    value: controlsProvider.isMuted
                        ? 0
                        : controlsProvider.volume,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndicatorOverlay({
    required IconData icon,
    required double value,
  }) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: CupertinoColors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: CupertinoColors.white, size: 32),
          const SizedBox(height: 12),
          Container(
            width: 60,
            height: 4,
            decoration: BoxDecoration(
              color: CupertinoColors.systemGrey4,
              borderRadius: BorderRadius.circular(2),
            ),
            child: Stack(
              children: [
                Container(
                  width: 60 * value,
                  height: 4,
                  decoration: BoxDecoration(
                    color: CupertinoColors.systemBlue,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(value * 100).toStringAsFixed(0)}%',
            style: const TextStyle(color: CupertinoColors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _handleVerticalDrag(DragUpdateDetails details, BuildContext context) {
    final dx = details.globalPosition.dx;
    final screenWidth = MediaQuery.of(context).size.width;
    const dragSensitivity = 0.005; // Sensitivity for drag

    // Left side: brightness control
    if (dx < screenWidth * 0.3) {
      _handleBrightnessDrag(details, dragSensitivity, context);
    }
    // Right side: volume control
    else if (dx > screenWidth * 0.7) {
      _handleVolumeDrag(details, dragSensitivity, context);
    }
  }

  void _handleBrightnessDrag(
    DragUpdateDetails details,
    double sensitivity,
    BuildContext context,
  ) {
    setState(() => _showBrightnessIndicator = true);

    final controlsProvider = context.read<DeviceControlsProvider>();
    final delta =
        -details.delta.dy *
        sensitivity; // Negative because swipe down = decrease

    controlsProvider.setBrightness(controlsProvider.brightness + delta);

    // Apply brightness to device
    ScreenBrightness.instance.setScreenBrightness(controlsProvider.brightness);

    // Hide indicator after drag ends
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showBrightnessIndicator = false);
      }
    });
  }

  void _handleVolumeDrag(
    DragUpdateDetails details,
    double sensitivity,
    BuildContext context,
  ) {
    setState(() => _showVolumeIndicator = true);

    final controlsProvider = context.read<DeviceControlsProvider>();
    final delta = -details.delta.dy * sensitivity;

    controlsProvider.setVolume(controlsProvider.volume + delta);

    // Apply volume to device
    VolumeController.instance.setVolume(controlsProvider.volume);

    // Apply to player
    widget.playerController.setVolume(controlsProvider.volume);

    // Hide indicator after drag ends
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        setState(() => _showVolumeIndicator = false);
      }
    });
  }
}
