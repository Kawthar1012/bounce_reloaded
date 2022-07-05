// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:bounce_game/barrier.dart';
import 'package:bounce_game/block.dart';
import 'package:bounce_game/homepage.dart';
import 'package:bounce_game/obstacle.dart';
import 'package:bounce_game/obstaclelist.dart';
import 'package:bounce_game/tutorial.dart';
import 'package:flutter/material.dart';
import 'package:bounce_game/ball.dart';
import 'package:flutter/services.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:bounce_game/dict.dart';
import 'package:bounce_game/levels.dart';

/*
* This class defines the levels depending on the data sent
* Most functions are similar to the tutorial file
*/
class Level extends StatefulWidget {
  @override
  _LevelState createState() => _LevelState(language: language, level: level);

  Level({Key? key, required this.language, required this.level})
      : super(key: key);
  String language;
  int level;
}

class _LevelState extends State<Level> {
  _LevelState({required this.language, required this.level});
  String language;
  int level;

  // initializing variables for buttons
  bool gameStarted = false;
  bool gamePaused = false;
  bool leftPressed = false;
  bool rightPressed = false;
  bool goalReached = false;
  late var timer;

  // initializing variables for the ball movement
  static double bounceYpos = 1.05;
  static double bounceXpos = -0.5;
  static double goalXpos = 5;
  double time = 0;
  double height = 0;
  double width = 0;
  double move = 0;
  double initialHeight = bounceYpos;
  double initialWidth = bounceXpos;
  static int lives = 3;

  // Defines the obstacles for the level
  List<Obstacle> obstacles = [
    //...levels[0]
    Block(startPointX: 0.8, startPointY: 1, nbOfObstacles: 2),
    Block(startPointX: 1.3, startPointY: 1, nbOfObstacles: 3),
    Barrier(startPointX: 1.65, startPointY: 1.05),
    Block(startPointX: 2.1, startPointY: 1, nbOfObstacles: 3),
    Barrier(startPointX: 2.45, startPointY: 1.05),
    Block(startPointX: 2.9, startPointY: 1, nbOfObstacles: 1),
    Block(startPointX: 3.4, startPointY: 1, nbOfObstacles: 2),
    Block(startPointX: 3.8, startPointY: 1, nbOfObstacles: 3)
  ];

  // brings the ball back to its initial height
  void jump() {
    setStateIfMounted(() {
      if (bounceYpos >= -0.55 && goalXpos - bounceXpos <= 0.2) {
        showDialog(
            // shows a dialog box if the goal is reached
            context: context,
            barrierDismissible: true,
            builder: (BuildContext cxt) => AlertDialog(
                  title: Text(language == 'en'
                      ? dictionnary["congrats"]![0]
                      : dictionnary["congrats"]![1]),
                  content: Text(language == 'en'
                      ? dictionnary["finish2"]![0]
                      : dictionnary["finish2"]![1]),
                  actions: [
                    ElevatedButton(
                        onPressed: () => {
                              resetGame(),
                              Navigator.pop(context),
                            },
                        child: Text(language == 'en'
                            ? dictionnary["restart"]![0]
                            : dictionnary["restart"]![1])),
                    ElevatedButton(
                        onPressed: () => {
                              resetGame(),
                              Navigator.pop(context),
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomePage()))
                            },
                        child: Text(language == 'en'
                            ? dictionnary["home"]![0]
                            : dictionnary["home"]![1])),
                  ],
                ));
      }
      initialHeight = bounceYpos;
      time = 0;
    });
  }

  void moveLeft() {
    // moves to the left every second and goes back when too far left
    if (gameStarted) {
      width = 0.03;
      move = 0.07;
      if (isOnObstacle() == 'B') {
        setStateIfMounted(() {
          bounceXpos = initialWidth - width;
          //subtract a life if the ball touches the obstacle
          lives -= 1;
          for (var obs in obstacles) {
            obs.startPointX -= move;
          }
          goalXpos -= move;
          if (lives == 0) {
            resetGame();
            showDialog(
              context: context,
              builder: (BuildContext cxt) => AlertDialog(
                title: Text(language == 'en'
                    ? dictionnary["over"]![0]
                    : dictionnary["over"]![1]),
                content: Text(language == 'en'
                    ? dictionnary["gameover"]![0]
                    : dictionnary["gameover"]![1]),
                actions: [
                  ElevatedButton(
                      onPressed: () => {
                            Navigator.pop(context),
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()))
                          },
                      child: Text(language == 'en'
                          ? dictionnary["home"]![0]
                          : dictionnary["home"]![1])),
                ],
              ),
            );
          }

          if (bounceXpos < -0.95) {
            bounceXpos = -1;
          }
        });
      } else if (isOnObstacle() == 'N' || isOnObstacle() == 'OB') {
        if (bounceXpos > 0) {
          setStateIfMounted(() {
            bounceXpos = initialWidth - width;
          });
        } else {
          if (bounceXpos < -0.95) {
            setStateIfMounted(() {
              bounceXpos = -1;
            });
          } else {
            setStateIfMounted(() {
              bounceXpos = initialWidth - width;
              for (var obs in obstacles) {
                obs.startPointX += move;
              }
              goalXpos += move;
            });
          }
        }
      } else {
        // If an obtsacle is close, we go on to it if we are above, otherwise we go as close as possible
        double coord = 0;
        setStateIfMounted(() {
          for (var obs in obstacles) {
            if (bounceYpos > obs.startPointY - 0.25) {
              if (bounceXpos <= obs.startPointX + 0.15 &&
                  bounceXpos >= obs.startPointX) {
                coord = obs.startPointX + 0.09;
                break;
              }
            }
          }
          if (coord == 0) {
            bounceXpos = initialWidth - width;
          } else {
            bounceXpos = coord;
          }
          if (bounceXpos < -0.95) {
            bounceXpos = -1;
          }
        });
      }
      setStateIfMounted(() {
        initialWidth = bounceXpos;
      });
    }
  }

  void moveRight() {
    // similar to left
    if (gameStarted) {
      width = 0.03;
      move = 0.07;
      if (isOnObstacle() == 'B') {
        setStateIfMounted(() {
          bounceXpos = initialWidth + width;
          lives -= 1;
          for (var obs in obstacles) {
            obs.startPointX -= move;
          }
          goalXpos -= move;
          if (bounceXpos > 1) {
            bounceXpos = 1;
          }
          if (lives == 0) {
            showDialog(
              context: context,
              builder: (BuildContext cxt) => AlertDialog(
                title: Text(language == 'en'
                    ? dictionnary["over"]![0]
                    : dictionnary["over"]![1]),
                content: Text(language == 'en'
                    ? dictionnary["gameover"]![0]
                    : dictionnary["gameover"]![1]),
                actions: [
                  ElevatedButton(
                      onPressed: () => {
                            gamePaused = false,
                            timer.cancel(),
                            gameStarted = false,
                            bounceXpos = 0,
                            goalXpos = 5.5,
                            Navigator.pop(context),
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomePage()))
                          },
                      child: Text(language == 'en'
                          ? dictionnary["home"]![0]
                          : dictionnary["home"]![1])),
                ],
              ),
            );
          }
        });
        //Different interaction of the ball depending on its position
      } else if (isOnObstacle() == 'N' || isOnObstacle() == 'OA') {
        if (goalXpos <= 1) {
          setStateIfMounted(() {
            bounceXpos = initialWidth + width;
          });
          if (bounceXpos >= 0.9) {
            bounceXpos = 0.9;
          }
        } else {
          setStateIfMounted(() {
            bounceXpos = initialWidth + width;
            for (var obs in obstacles) {
              obs.startPointX -= move;
            }
            goalXpos -= move;
          });
          if (bounceXpos > 1) {
            bounceXpos = 1;
          }
        }
      } else {
        // If an obtsacle is close, we go on to it if we are above, otherwise we go as close as possible
        double coord = 0;
        setStateIfMounted(() {
          for (var obs in obstacles) {
            if (bounceYpos > obs.startPointY - 0.25) {
              if (bounceXpos >= obs.startPointX - 0.15 &&
                  bounceXpos <= obs.startPointX) {
                // We are close before the obstacle
                coord = obs.startPointX - 0.09;
                break;
              }
            } else if (bounceXpos <= obs.startPointX + 0.15 &&
                bounceXpos >= obs.startPointX) {
              // We are close after the obstacle
              coord = obs.startPointX + 0.09;
              break;
            }
          }
          if (coord == 0) {
            bounceXpos = initialWidth + width;
          } else {
            bounceXpos = coord;
          }
          if (bounceXpos > 1) {
            bounceXpos = 1;
          }
        });
      }
      setStateIfMounted(() {
        initialWidth = bounceXpos;
      });
    }
  }

//Dynamically show the lives remaining for the ball
  Row showLives() {
    return Row(
      children: [
        for (int life = lives; life > 0; life--)
          Row(
            children: <Widget>[
              Container(
                height: 30,
                width: 30,
                child: Image.asset("assets/images/bounce.png"),
              ),
            ],
          )
      ],
    );
  }

  //Changing the language of the games
  void changeLanguage() {
    setStateIfMounted({
      if (language == 'en') {language = 'fr'} else {language = 'en'}
    });
  }

  /*
  * Defines if we are on or close to an obstacle
  * Returns B if we are on a barrier and we lose a live
  * OB if we are before a block, OA if we are after a block
  * N if we aren't close to an obstacle
  */
  String isOnObstacle() {
    for (var obs in obstacles) {
      if (obs is Barrier &&
          ((bounceXpos >= obs.startPointX - 0.05 &&
                  bounceXpos <= obs.startPointX) ||
              (bounceXpos <= obs.startPointX + 0.05 &&
                  bounceXpos >= obs.startPointX)) &&
          bounceYpos > obs.startPointY - 0.35) {
        return "B";
      } else if (bounceXpos >= obs.startPointX - 0.15 &&
          bounceXpos <= obs.startPointX) {
        return "OB";
      } else if (bounceXpos <= obs.startPointX + 0.15 &&
          bounceXpos >= obs.startPointX) {
        return "OA";
      }
    }
    return "N";
  }

  // resets the values
  void resetGame() {
    setState(() {
      timer.cancel();
      gameStarted = false;
      leftPressed = false;
      rightPressed = false;
      goalReached = false;
      bounceXpos = -0.5;
      goalXpos = 6;
      gamePaused = false;
      obstacles = [];
      lives = 3;
    });
  }

  void startGame() {
    // uses a function to calculate the position of the ball when flying
    FlameAudio.play('music/mixkit-player-jumping-in-a-video-game-2043.wav');
    gameStarted = true;
    Timer.periodic(const Duration(milliseconds: 40), (timer) {
      var v = 6;
      time += 0.05;
      height = -4.9 * time * time +
          v * time; // can control the speed and height by changing v
      setStateIfMounted(() {
        bounceYpos = initialHeight - height;
        var block = 0;
        // Checks if we are close to an obstacle
        for (var obs in obstacles) {
          if ((bounceXpos <= obs.startPointX + 0.05 &&
                  bounceXpos >= obs.startPointX) ||
              (bounceXpos >= obs.startPointX - 0.05 &&
                  bounceXpos <= obs.startPointX)) {
            if (obs is Block) {
              block =
                  obs.nbOfObstacles; // sets the number of block we have to jump
            }
          }
        }
        if (block != 0) {
          bounceYpos =
              1 - (block * 0.25); // Goes over the block if there is an obtsacle
        }
      });

      if (bounceYpos > 1.05) {
        bounceYpos = 1.05;
      }
    });
  }

  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  //Force the application to be in landscape mode only.
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (mounted) {
      timer = Timer.periodic(
          const Duration(seconds: 60), (Timer t) => setState(() {}));
    }
  }

  @override
  /*
  This builds the main components of the page
  The building is similar to the tutorial page
  */
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Expanded(
          flex: 4,
          child: GestureDetector(
              onTap: () {
                startGame();
              },
              child: Stack(children: [
                AnimatedContainer(
                  alignment: Alignment(bounceXpos, bounceYpos),
                  duration: const Duration(milliseconds: 0),
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                    image: AssetImage(
                        "assets/images/Background.png"), // sets the background image
                    fit: BoxFit.cover,
                  )),
                  child: MyBall(),
                ),
                AnimatedContainer(
                  duration: const Duration(milliseconds: 0),
                  alignment: const Alignment(0.8, 1.15),
                  child: ObstacleList(
                      obstacles: obstacles), // showcases the obstacles
                ),
                Container(
                  alignment: const Alignment(0, -0.3),
                  child: gameStarted
                      ? const Text(" ")
                      : Text(
                          language == 'en'
                              ? dictionnary["startGame"]![0]
                              : dictionnary["startGame"]![1],
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.height *
                                0.13 /
                                2 *
                                3 /
                                4,
                          )),
                ),
                GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext cxt) => AlertDialog(
                          title: Text(language == 'en'
                              ? dictionnary["welcome"]![0]
                              : dictionnary["welcome"]![1]),
                          content: Text(language == 'en'
                              ? dictionnary["start"]![0]
                              : dictionnary["start"]![1]),
                          actions: [
                            ElevatedButton(
                                onPressed: () => {
                                      resetGame(),
                                      Navigator.pop(context),
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Tutorial(
                                                    language: "en",
                                                  )))
                                    },
                                child: const Text("OK")),
                            ElevatedButton(
                                onPressed: () => {
                                      Navigator.pop(context),
                                    },
                                child: Text(
                                  language == 'en'
                                      ? dictionnary["resume"]![0]
                                      : dictionnary["resume"]![1],
                                )),
                          ],
                        ),
                      );
                    },
                    child: Align(
                        // info button which leads to the tutorial
                        alignment: const Alignment(-0.95, -0.8),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.22 /
                              2 *
                              3 /
                              4,
                          width: MediaQuery.of(context).size.height * 0.22 / 2,
                          child: Image.asset('assets/images/Info.png'),
                        ))),
                Container(child: showLives()),
                GestureDetector(
                    onTap: () {
                      gamePaused = true;
                      showDialog(
                        context: context,
                        barrierDismissible: true,
                        builder: (BuildContext cxt) => AlertDialog(
                          title: const Text("Pause"),
                          content: Text(
                            language == 'en'
                                ? dictionnary["pause"]![0]
                                : dictionnary["pause"]![1],
                          ),
                          actions: [
                            ElevatedButton(
                                onPressed: () => {
                                      resetGame(),
                                      Navigator.pop(context),
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => HomePage()))
                                    },
                                child: Text(language == 'en'
                                    ? dictionnary["home"]![0]
                                    : dictionnary["home"]![1])),
                            ElevatedButton(
                                onPressed: () => {
                                      gamePaused = false,
                                      startGame(),
                                      Navigator.pop(context),
                                    },
                                child: Text(language == 'en'
                                    ? dictionnary["resume"]![0]
                                    : dictionnary["resume"]![1])),
                          ],
                        ),
                      );
                    },
                    //Putting in the plan and pause buttons on the gamescreen
                    child: Align(
                        alignment: const Alignment(0.95, -0.8),
                        child: gameStarted
                            ? gamePaused
                                ? SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.22 /
                                        2 *
                                        3 /
                                        4,
                                    width: MediaQuery.of(context).size.height *
                                        0.22 /
                                        2,
                                    child:
                                        Image.asset('assets/images/Play.png'),
                                  )
                                : SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.22 /
                                        2 *
                                        3 /
                                        4,
                                    width: MediaQuery.of(context).size.height *
                                        0.22 /
                                        2,
                                    child:
                                        Image.asset('assets/images/Pause.png'),
                                  )
                            : const Text(""))),
                Align(
                  alignment: Alignment(goalXpos, -0.45),
                  child: SizedBox(
                      height:
                          MediaQuery.of(context).size.height * 0.35 / 2 * 3 / 4,
                      width: MediaQuery.of(context).size.height * 0.35 / 2,
                      child: Image.asset('assets/images/Goal.png')),
                ),
                GestureDetector(
                  onTap: changeLanguage,
                  child: Align(
                      alignment: const Alignment(0.75, -0.8),
                      child: language == 'en'
                          ? SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.23 /
                                  2 *
                                  3 /
                                  4,
                              width:
                                  MediaQuery.of(context).size.height * 0.23 / 2,
                              child: Image.asset(
                                  'assets/images/fr.png'), //French Flag
                            )
                          : SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.23 /
                                  2 *
                                  3 /
                                  4,
                              width:
                                  MediaQuery.of(context).size.height * 0.23 / 2,
                              child: Image.asset(
                                  'assets/images/en.png'), //English Flag
                            )),
                )
              ]))),
      // This section handles the second half of the game which has the emulator
      Expanded(
        child: Container(
          color: Colors.grey.shade400,
          height: 90,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: () {
                  moveLeft();
                },
                onLongPressStart: (_) async {
                  leftPressed = true;
                  do {
                    moveLeft();
                    await Future.delayed(const Duration(milliseconds: 50));
                  } while (leftPressed);
                },
                onLongPressEnd: (_) =>
                    setStateIfMounted(() => leftPressed = false),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.27 / 2 * 3 / 4,
                  width: MediaQuery.of(context).size.height * 0.27 / 2,
                  child: Image.asset('assets/images/Left.png'), //Left Button
                ),
              ),
              GestureDetector(
                onTap: () {
                  moveRight();
                },
                onLongPressStart: (_) async {
                  rightPressed = true;
                  do {
                    moveRight();
                    await Future.delayed(const Duration(milliseconds: 50));
                  } while (rightPressed);
                },
                onLongPressEnd: (_) =>
                    setStateIfMounted(() => rightPressed = false),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.27 / 2 * 3 / 4,
                  width: MediaQuery.of(context).size.height * 0.27 / 2,
                  child: Image.asset('assets/images/Right.png'), //Right Button
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.27 / 2 * 3 / 4,
                width: MediaQuery.of(context).size.height * 0.27 / 2,
                child: Text(" "),
              ),
              GestureDetector(
                //Playing music when the ball jumps
                onTap: () {
                  FlameAudio.play(
                      'music/mixkit-player-jumping-in-a-video-game-2043.wav');
                  jump();
                },
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.27 / 2 * 3 / 4,
                  width: MediaQuery.of(context).size.height * 0.27 / 2,
                  child: Image.asset('assets/images/Up.png'), //Up Arrow
                ),
              )
            ],
          ),
        ),
      ),
    ]));
  }

  // On exit, the phone can return to normal (any) orientation
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
