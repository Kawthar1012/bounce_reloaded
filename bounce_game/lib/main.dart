// Here is the main page where we load the home page

import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';

import 'homepage.dart';

void startBgmMusic() {
  FlameAudio.bgm.initialize();
  FlameAudio.bgm.play('music/Fluffing-a-Duck.mp3');
}

//Main entry point of the application
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
