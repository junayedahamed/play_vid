import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:play_vid/screens/home_screen.dart';
import 'package:play_vid/providers/video_provider.dart';
import 'package:play_vid/providers/device_controls_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => VideoProvider()),
        ChangeNotifierProvider(create: (_) => DeviceControlsProvider()),
      ],
      child: CupertinoApp(
        title: 'Play Vid',
        theme: const CupertinoThemeData(
          brightness: Brightness.dark,
          primaryColor: CupertinoColors.systemBlue,
        ),
        debugShowCheckedModeBanner: false,
        home: const HomeScreen(),
      ),
    );
  }
}
