import 'package:flutter/material.dart';
import 'package:play_vid/home/videos/my_download_videos.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _pushToVideoScreen();
  }

  void _pushToVideoScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MyDownloadVideos()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Icon(
          Icons.play_circle_filled_rounded,
          size: 100,
          color: Colors.blue,
        ),
      ),
    );
  }
}
