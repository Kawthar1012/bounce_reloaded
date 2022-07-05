import 'package:flutter/material.dart';

class MyBall extends StatelessWidget {
  // object for the ball, can modify the height and width
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.27 / 2,
      width: MediaQuery.of(context).size.height * 3 / 4 * 0.27 / 2,
      child: Image.asset('assets/images/bounce.png'),
    );
  }
}
