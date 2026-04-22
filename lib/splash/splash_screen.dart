import 'package:flutter/material.dart';
import 'package:play_vid/home/my_download_vodeos.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void pushToVideoScreen() {
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyDownloadVodeos()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    pushToVideoScreen();
    return const Scaffold();
  }
}
