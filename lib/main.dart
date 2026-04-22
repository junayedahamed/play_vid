import 'package:flutter/material.dart';
import 'package:play_vid/home/player/player_view_model/player_view_model.dart';
import 'package:play_vid/splash/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:play_vid/home/videos/view_model/local_video_fetch.dart';
import 'package:audio_service/audio_service.dart';
import 'package:play_vid/home/player/audio_player_handler.dart';

late AudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.play_vid.channel.audio',
      androidNotificationChannelName: 'Video Player Audio',
      androidNotificationOngoing: true,
      androidStopForegroundOnPause: true,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocalVideoFetch()),
        ChangeNotifierProvider(
          create: (_) => PlayerViewModel(assetEntities: [], currentIndex: 0),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}
