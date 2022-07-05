import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';

//Initializing the music and specifying the file
void startBgmMusic() {
  FlameAudio.bgm.initialize();
  FlameAudio.bgm.play('music/Fluffing-a-Duck.mp3');
}

class bounce extends StatefulWidget {
  @override
  _bounceState createState() => _bounceState();
}

class _bounceState extends State<bounce> with TickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('music/Fluffing-a-Duck.mp3');
    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
      lowerBound: 0,
      upperBound: 100,
    );

    controller.addListener(() {
      setState(() {});
    });

    controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

//Specifying the widget for the ball
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: controller.value),
      child: Container(
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        width: 70.0,
        height: 70.0,
      ),
    );
  }
}

//Adaptive size for the ball
class animatedBall extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: MediaQuery.of(context).size.height * 0.83 / 2,
        width: MediaQuery.of(context).size.height * 3 / 4 * 0.25 / 2,
        child: bounce());
  }
}
