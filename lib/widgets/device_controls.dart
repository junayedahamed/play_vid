import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
// import 'package:auto_orientation/auto_orientation.dart';
import 'package:play_vid/providers/device_controls_provider.dart';

class DeviceControls extends StatefulWidget {
  const DeviceControls({Key? key}) : super(key: key);

  @override
  State<DeviceControls> createState() => _DeviceControlsState();
}

class _DeviceControlsState extends State<DeviceControls> {
  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceControlsProvider>(
      builder: (context, controlsProvider, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Orientation lock button
            // CupertinoButton(
            //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            //   color: controlsProvider.isOrientationLocked
            //       ? CupertinoColors.systemBlue
            //       : CupertinoColors.systemGrey3,
            //   onPressed: () async {
            //     if (controlsProvider.isOrientationLocked) {
            //       // Unlock orientation - allow all orientations
            //       await AutoOrientation.fullAutoMode();
            //       controlsProvider.setOrientationLocked(false);
            //     } else {
            //       // Lock orientation to portrait
            //       await AutoOrientation.portraitUpMode();
            //       controlsProvider.setOrientationLocked(true);
            //     }
            //   },
            //   child: const Icon(
            //     CupertinoIcons.lock,
            //     color: CupertinoColors.white,
            //   ),
            // ),
          ],
        );
      },
    );
  }
}
