// ignore_for_file: deprecated_member_use

/*
  This file represents the homepage where we have buttons to access the pages.
  */

import 'dart:async';

import 'package:bounce_game/level.dart';
import 'package:bounce_game/tutorial.dart';
import 'package:flutter/material.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:bounce_game/dict.dart';
import 'package:bounce_game/animatedBall.dart';
import 'package:flutter/services.dart';

// Each page is a statefulWidget which creates a state
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// Below is the main code for the homepage
class _HomePageState extends State<HomePage> {
  // initial values for the ball's movement
  static double bounceXpos = 0;
  static double bounceYpos = 0.8;
  double time = 0;
  double height = 0;
  double width = 0;
  double initialHeight = bounceYpos;
  late var timer;

  String lan = "en";

  // Starts the background music
  void startBgmMusic() {
    FlameAudio.bgm.initialize();
    FlameAudio.bgm.play('music/Fluffing-a-Duck.mp3');
  }

  // Changes the language in this page
  void changeLanguage() {
    setState(() {
      if (lan == 'en') {
        lan = 'fr';
      } else {
        lan = 'en';
      }
    });
  }

  // Here we build the different components that are part of the page
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (mounted) {
      timer = new Timer.periodic(
          Duration(seconds: 60), (Timer t) => setState(() {}));
    }
  }

  @override
  /*
  Comments are apparently not supported in a build function in flutter
  This builds the main components starting with a gesture detector to start the game
  The background and ball are positionned with an animatedcontainer
  After, there are the tap to play text and the different buttons (info and pause)
  Pause isn't positionned properly as of now, issue has yet to be found
  Then comes the expanded with a grey background and a row where all elements have the same space
  There I placed our 3 buttons: left, right and up linked to the function above
  Left and right are moved as long as the button is pressed, using booleans for that
  */
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(// We use a column to represent items
            children: [
      Expanded(
        flex: 5,
        child: Stack(children: [
          AnimatedContainer(
            // sets the animated ball with the defined positions
            alignment: Alignment(bounceXpos, bounceYpos),
            duration: const Duration(milliseconds: 0),
            decoration: const BoxDecoration(
                image: DecorationImage(
              image: AssetImage("assets/images/Background.png"),
              fit: BoxFit.cover,
            )),
            child: animatedBall(),
          ),
          Align(
              // Sizes are defined using mediaQuery to be responsive
              alignment: const Alignment(0, -0.8),
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.25 / 2 * 3 / 4,
                  width: MediaQuery.of(context).size.height * 0.6 / 2,
                  child: Text(
                    "Bounce Reloaded",
                    style: TextStyle(
                        fontSize: MediaQuery.of(context).size.height *
                            0.1 /
                            2 *
                            3 /
                            4),
                  ))),
          Align(
              alignment: const Alignment(0, -0.3),
              child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2 / 2 * 3 / 4,
                  width: MediaQuery.of(context).size.height * 0.5 / 2,
                  child: ElevatedButton(
                    onPressed: () => {
                      // Loads the first level
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => Level(
                                language: lan,
                                level: 1,
                              )))
                    },
                    child: Text(lan == "en"
                        ? dictionnary["play"]![0]
                        : dictionnary["play"]![1]),
                  ))),
          Align(
              alignment: const Alignment(0, 0),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.2 / 2 * 3 / 4,
                width: MediaQuery.of(context).size.height * 0.5 / 2,
                child: ElevatedButton(
                    onPressed: () => {
                          showDialog(
                              // dialog box to access the tutorial
                              context: context,
                              barrierDismissible: true,
                              builder: (BuildContext cxt) => AlertDialog(
                                      title: Text(lan == 'en'
                                          ? dictionnary["welcome"]![0]
                                          : dictionnary["welcome"]![1]),
                                      content: Text(lan == 'en'
                                          ? dictionnary["start"]![0]
                                          : dictionnary["start"]![1]),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () => {
                                                  Navigator.pop(context),
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Tutorial(
                                                                language: lan,
                                                              )))
                                                },
                                            child: const Text("OK")),
                                        ElevatedButton(
                                            onPressed: () => {
                                                  Navigator.pop(context),
                                                },
                                            child: Text(lan == 'en'
                                                ? dictionnary["cancel"]![0]
                                                : dictionnary["cancel"]![1]))
                                      ]))
                        },
                    child: Text(lan == 'en'
                        ? dictionnary["tuto"]![0]
                        : dictionnary["tuto"]![1])),
              )),
          GestureDetector(
            // Change the language with that button
            onTap: changeLanguage,
            child: Align(
                alignment: const Alignment(0, 0.3),
                child: lan == 'en'
                    ? SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.23 /
                            2 *
                            3 /
                            4,
                        width: MediaQuery.of(context).size.height * 0.23 / 2,
                        child: Image.asset('assets/images/fr.png'),
                      )
                    : SizedBox(
                        height: MediaQuery.of(context).size.height *
                            0.23 /
                            2 *
                            3 /
                            4,
                        width: MediaQuery.of(context).size.height * 0.23 / 2,
                        child: Image.asset('assets/images/en.png'),
                      )),
          )
        ]),
      )
    ]));
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
  }
}
