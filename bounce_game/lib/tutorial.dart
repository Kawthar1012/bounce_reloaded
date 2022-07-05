import 'dart:async';
import 'package:bounce_game/ball.dart';
import 'package:bounce_game/barrier.dart';
import 'package:bounce_game/block.dart';
import 'package:bounce_game/homepage.dart';
import 'package:bounce_game/levels.dart';
import 'package:bounce_game/obstacle.dart';
import 'package:bounce_game/obstaclelist.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:bounce_game/dict.dart';

class Tutorial extends StatefulWidget {
  @override
  _TutorialState createState() => _TutorialState(language: language);

  Tutorial({Key? key, required this.language}) : super(key: key);
  String language;
}

class _TutorialState extends State<Tutorial> {
  _TutorialState({required this.language});
  String language;

  // initializing booleans to show texts for the demo
  bool gameStarted = false;
  bool leftPressed = false;
  bool rightPressed = false;
  bool jumpPressed = false;
  bool buttonPressed = false;
  bool allPressed = false;
  bool goalReached = false;
  bool gamePaused = false;
  bool obstacleTouched = false;
  late var timer;

  // initializing variables for the ball movement
  static double bounceYpos = 1.05;
  static double bounceXpos = 0;
  double time = 0;
  double height = 0;
  double width = 0;
  double move = 0;
  double initialHeight = bounceYpos;
  double initialWidth = bounceXpos;
  static int lives = 3;
  static double goalXPos = 5;

  List<Obstacle> obstacles = [
    Barrier(startPointX: 0.8, startPointY: 1.05),
    Block(startPointX: 1.5, startPointY: 1, nbOfObstacles: 2),
    Block(startPointX: 2.2, startPointY: 1, nbOfObstacles: 1)
  ];

  // Brings the ball back to its initial height
  // Sets goalReached to true if the y and x position are the same as the goal
  void jump() {
    FlameAudio.play('music/mixkit-player-jumping-in-a-video-game-2043.wav');
    setStateIfMounted(() {
      if (bounceYpos >= -0.55 && goalXPos - bounceXpos <= 0.2) {
        goalReached = true;
      }
      initialHeight = bounceYpos;
      time = 0;
    });
    jumpPressed = true;
  }

  // Moves to the left every second and goes back when too far left
  void moveLeft() {
    if (jumpPressed) {
      width = 0.05;
      move = 0.05;
      if (isOnObstacle() == 'B') {
        // activates another message if touches a pin
        obstacleTouched = true;
        setStateIfMounted(() {
          bounceXpos = initialWidth - width;
          lives -= 1;
          for (var obs in obstacles) {
            obs.startPointX -= move;
          }
          goalXPos -= move;
          if (bounceXpos < -0.95) {
            bounceXpos = -1;
          }
        });
      } else if (isOnObstacle() == 'N' || isOnObstacle() == 'OB') {
        // Moves normally if there is no obstacle or if it's after
        if (bounceXpos > 0) {
          setStateIfMounted(() {
            bounceXpos = initialWidth - width;
          });
        } else {
          if (bounceXpos < -0.95) {
            // stops the ball from going out of the screen
            setStateIfMounted(() {
              bounceXpos = -1;
            });
          } else {
            setStateIfMounted(() {
              bounceXpos = initialWidth - width;
              for (var obs in obstacles) {
                obs.startPointX += move;
              }
              goalXPos += move;
            });
          }
        }
      } else {
        // If an obtsacle is close, we go on to it if we are above, otherwise we go as close as possible
        double coord = 0;
        setStateIfMounted(() {
          for (var obs in obstacles) {
            if (bounceYpos > obs.startPointY - 0.25) {
              // check if we are above the obstacle
              if (bounceXpos <= obs.startPointX + 0.15 &&
                  bounceXpos >= obs.startPointX) {
                // if the ball is before, stops close to the obstacle
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
      buttonPressed = true;
    }
  }

  // Similar to the moveLeft function but opposite direction
  void moveRight() {
    if (buttonPressed) {
      width = 0.05;
      move = 0.05;
      if (isOnObstacle() == 'B') {
        obstacleTouched = true;
        setStateIfMounted(() {
          bounceXpos = initialWidth + width;
          lives -= 1;
          for (var obs in obstacles) {
            obs.startPointX -= move;
          }
          goalXPos -= move;
          if (bounceXpos > 1) {
            bounceXpos = 1;
          }
        });
      } else if (isOnObstacle() == 'N' || isOnObstacle() == 'OA') {
        if (goalXPos <= 1) {
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
            goalXPos -= move;
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
      allPressed = true;
    }
  }

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

  void startTutorial() {
    // uses a function to calculate the position of the ball when flying
    gameStarted = true;
    FlameAudio.play('music/mixkit-player-jumping-in-a-video-game-2043.wav');
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

  // Resets all the values before going out of the page
  void resetTutorial() {
    setStateIfMounted(() {
      timer.cancel();
      gameStarted = false;
      leftPressed = false;
      rightPressed = false;
      jumpPressed = false;
      buttonPressed = false;
      allPressed = false;
      goalReached = false;
      obstacleTouched = false;
      bounceXpos = 0;
      goalXPos = 3;
      gamePaused = false;
      obstacles = [];
    });
  }

  // Prevents an error
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  // Sets the screen to landscape mode
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    if (mounted) {
      timer = Timer.periodic(
          const Duration(seconds: 60), (Timer t) => setStateIfMounted(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    /*
    * Using MediaQuey to define the size of the components depending on the screen size
    * The dictionnary is accessed with the according file
    * If the selected language is 'en', we take the first corresponding elements in the dictionanry
    * If it's another, we take the second element
    */
    return Scaffold(
      appBar: AppBar(
        title: Text(
            language == 'en'
                ? dictionnary["tuto"]![0]
                : dictionnary["tuto"]![1],
            style: TextStyle(
              color: Colors.white,
              fontSize: MediaQuery.of(context).size.height * 0.13 / 2 * 3 / 4,
            )),
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: GestureDetector(
                  onTap: () {
                    startTutorial();
                  },
                  child: Stack(children: [
                    AnimatedContainer(
                        decoration: const BoxDecoration(
                            image: DecorationImage(
                          image: AssetImage("assets/images/Background.png"),
                          fit: BoxFit.cover,
                        )),
                        alignment: Alignment(bounceXpos, bounceYpos),
                        duration: const Duration(milliseconds: 0),
                        child: MyBall()),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 0),
                      alignment: const Alignment(0.8, 1.15),
                      child: ObstacleList(obstacles: obstacles),
                    ),
                    Container(
                      // This container showcases the different messages of the tutorial
                      // depending on the buttons pressed
                      alignment: const Alignment(0, -0.3),
                      child: gameStarted
                          ? allPressed
                              ? (goalXPos <= 1)
                                  ? Text(
                                      language == 'en'
                                          ? dictionnary["jumpEnd"]![0]
                                          : dictionnary["jumpEnd"]![1],
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize:
                                            MediaQuery.of(context).size.height *
                                                0.13 /
                                                2 *
                                                3 /
                                                4,
                                      ))
                                  : (obstacles[0].startPointX - bounceXpos <
                                          0.2)
                                      ? obstacleTouched
                                          ? Text(
                                              language == 'en'
                                                  ? dictionnary["lose1"]![0]
                                                  : dictionnary["lose1"]![1],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.13 /
                                                    2 *
                                                    3 /
                                                    4,
                                              ))
                                          : Text(
                                              language == 'en'
                                                  ? dictionnary["obs"]![0]
                                                  : dictionnary["obs"]![1],
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.13 /
                                                    2 *
                                                    3 /
                                                    4,
                                              ))
                                      : Text(
                                          language == 'en'
                                              ? dictionnary["endTuto"]![0]
                                              : dictionnary["endTuto"]![1],
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.13 /
                                                2 *
                                                3 /
                                                4,
                                          ))
                              : const Text(" ")
                          : Text(
                              language == 'en'
                                  ? dictionnary["startTuto"]![0]
                                  : dictionnary["startTuto"]![1],
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.height *
                                    0.13 /
                                    2 *
                                    3 /
                                    4,
                              )),
                    ),
                    Align(
                      alignment: const Alignment(0.7, 0.9),
                      child: gameStarted
                          ? jumpPressed
                              ? const Text(" ")
                              : Text(
                                  language == 'en'
                                      ? dictionnary["jump"]![0]
                                      : dictionnary["jump"]![1],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        MediaQuery.of(context).size.height *
                                            0.13 /
                                            2 *
                                            3 /
                                            4,
                                  ))
                          : const Text(" "),
                    ),
                    Align(
                        alignment: const Alignment(-0.25, 0.9),
                        child: buttonPressed
                            ? allPressed
                                ? const Text(" ")
                                : Text(
                                    language == 'en'
                                        ? dictionnary["right"]![0]
                                        : dictionnary["right"]![1],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.13 /
                                              2 *
                                              3 /
                                              4,
                                    ))
                            : const Text(" ")),
                    Align(
                        alignment: const Alignment(-0.75, 0.9),
                        child: jumpPressed
                            ? buttonPressed
                                ? const Text(" ")
                                : Text(
                                    language == 'en'
                                        ? dictionnary["left"]![0]
                                        : dictionnary["left"]![1],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize:
                                          MediaQuery.of(context).size.height *
                                              0.13 /
                                              2 *
                                              3 /
                                              4,
                                    ))
                            : const Text(" ")),
                    GestureDetector(
                        // Defines the pause button with the dialog box
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
                                          resetTutorial(),
                                          Navigator.pop(context),
                                          Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      HomePage()))
                                        },
                                    child: Text(language == 'en'
                                        ? dictionnary["home"]![0]
                                        : dictionnary["home"]![1])),
                                ElevatedButton(
                                    onPressed: () => {
                                          gamePaused = false,
                                          startTutorial(),
                                          Navigator.pop(context),
                                        },
                                    child: Text(language == 'en'
                                        ? dictionnary["resume"]![0]
                                        : dictionnary["resume"]![1])),
                              ],
                            ),
                          );
                        },
                        child: Align(
                            // defines the image used depending on if the game is played/paused
                            alignment: const Alignment(0.95, -0.9),
                            child: gameStarted
                                ? gamePaused
                                    ? SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.22 /
                                                2 *
                                                3 /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.22 /
                                                2,
                                        child: Image.asset(
                                            'assets/images/Play.png'),
                                      )
                                    : SizedBox(
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.22 /
                                                2 *
                                                3 /
                                                4,
                                        width:
                                            MediaQuery.of(context).size.height *
                                                0.22 /
                                                2,
                                        child: Image.asset(
                                            'assets/images/Pause.png'),
                                      )
                                : const Text(""))),
                    Align(
                      // Sets the goal
                      alignment: Alignment(goalXPos, -0.45),
                      child: SizedBox(
                          height: MediaQuery.of(context).size.height *
                              0.35 /
                              2 *
                              3 /
                              4,
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
                                  width: MediaQuery.of(context).size.height *
                                      0.23 /
                                      2,
                                  child: Image.asset('assets/images/fr.png'),
                                )
                              : SizedBox(
                                  height: MediaQuery.of(context).size.height *
                                      0.23 /
                                      2 *
                                      3 /
                                      4,
                                  width: MediaQuery.of(context).size.height *
                                      0.23 /
                                      2,
                                  child: Image.asset('assets/images/en.png'),
                                )),
                    ),
                    Container(
                        // shows a dialog if the goal is reached
                        child: goalReached
                            ? AlertDialog(
                                title: Text(language == 'en'
                                    ? dictionnary["congrats"]![0]
                                    : dictionnary["congrats"]![1]),
                                content: Text(language == 'en'
                                    ? dictionnary["finish"]![0]
                                    : dictionnary["finish"]![1]),
                                actions: [
                                  ElevatedButton(
                                      onPressed: () => {
                                            resetTutorial(),
                                            Navigator.pop(context),
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Tutorial(
                                                            language:
                                                                language)))
                                          },
                                      child: Text(language == 'en'
                                          ? dictionnary["restart"]![0]
                                          : dictionnary["restart"]![1])),
                                  ElevatedButton(
                                      onPressed: () => {
                                            resetTutorial(),
                                            Navigator.pop(context),
                                          },
                                      child: Text(language == 'en'
                                          ? dictionnary["home"]![0]
                                          : dictionnary["home"]![1])),
                                ],
                              )
                            : const Text(" ")),
                  ])),
            ),
            // Here are the different buttons
            Container(
              color: Colors.grey.shade400,
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  GestureDetector(
                    // left button
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
                      height:
                          MediaQuery.of(context).size.height * 0.27 / 2 * 3 / 4,
                      width: MediaQuery.of(context).size.height * 0.27 / 2,
                      child: Image.asset('assets/images/Left.png'),
                    ),
                  ),
                  GestureDetector(
                    // right button
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
                      height:
                          MediaQuery.of(context).size.height * 0.27 / 2 * 3 / 4,
                      width: MediaQuery.of(context).size.height * 0.27 / 2,
                      child: Image.asset('assets/images/Right.png'),
                    ),
                  ),
                  SizedBox(
                    // empty space
                    height:
                        MediaQuery.of(context).size.height * 0.27 / 2 * 3 / 4,
                    width: MediaQuery.of(context).size.height * 0.27 / 2,
                    child: const Text(" "),
                  ),
                  GestureDetector(
                    onTap: () {
                      jump();
                    },
                    child: SizedBox(
                      // up button
                      height:
                          MediaQuery.of(context).size.height * 0.27 / 2 * 3 / 4,
                      width: MediaQuery.of(context).size.height * 0.27 / 2,
                      child: Image.asset('assets/images/Up.png'),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
