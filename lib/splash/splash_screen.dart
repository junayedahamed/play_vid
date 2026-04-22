import 'package:flutter/material.dart';
import 'package:play_vid/home/my_download_vodeos.dart';
import 'package:play_vid/home/view_model/local_video_fetch.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final LocalVideoFetch localVideoFetch = LocalVideoFetch();
  void pushToVideoScreen() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) =>
              MyDownloadVodeos(localVideoFetch: localVideoFetch),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    pushToVideoScreen();
    return const Scaffold();
  }
}
