import 'package:flutter/cupertino.dart';
import '../player_view_model/player_view_model.dart';

class AudioSettingsDialog extends StatelessWidget {
  final PlayerViewModel viewModel;

  const AudioSettingsDialog({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    bool tempValue = viewModel.isAudioDisabled;
    return StatefulBuilder(
      builder: (context, setDialogState) {
        return CupertinoAlertDialog(
          title: const Text('Audio Settings'),
          content: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () {
                setDialogState(() => tempValue = !tempValue);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    tempValue
                        ? CupertinoIcons.check_mark_circled_solid
                        : CupertinoIcons.circle,
                  ),
                  const SizedBox(width: 8),
                  const Text('Disable Audio'),
                ],
              ),
            ),
          ),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () {
                viewModel.setAudioDisabled(tempValue);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}

void showAudioDialog(BuildContext context, PlayerViewModel viewModel) {
  showCupertinoDialog(
    context: context,
    builder: (context) => AudioSettingsDialog(viewModel: viewModel),
  );
}
