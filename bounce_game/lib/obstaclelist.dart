import 'package:bounce_game/block.dart';
import 'package:bounce_game/obstacle.dart';
import 'package:flutter/widgets.dart';

/*
* This builds the level based on the data received about the obstacles
* A barrier will appear only once therefore it only needs coordinates
* Blocks can be on top of each other so we also need a number as argument
* Depending on the type of obstacles, they will be shown differently
*/
class ObstacleList extends StatelessWidget {
  final List<Obstacle> obstacles;

  const ObstacleList({Key? key, required this.obstacles}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: obstacles.map((Obstacle obs) {
        if (obs is Block) {
          if (obs.nbOfObstacles == 1) {
            // We vary the size of the image depending on the type of obstacle
            return Align(
                alignment: Alignment(obs.startPointX, obs.startPointY),
                child: AnimatedContainer(
                    width: MediaQuery.of(context).size.height * 0.25 / 2,
                    height:
                        MediaQuery.of(context).size.height * 3 / 4 * 0.25 / 2,
                    duration: const Duration(milliseconds: 0),
                    child: Image.asset("assets/images/Block.png")));
          } else if (obs.nbOfObstacles == 2) {
            return Align(
                alignment: Alignment(obs.startPointX, obs.startPointY),
                child: AnimatedContainer(
                    width: MediaQuery.of(context).size.height * 0.25 / 2,
                    height:
                        MediaQuery.of(context).size.height * 0.5 / 2 * 3 / 4,
                    duration: const Duration(milliseconds: 0),
                    child: Image.asset("assets/images/Block2.png")));
          } else {
            return Align(
                alignment: Alignment(obs.startPointX, obs.startPointY),
                child: AnimatedContainer(
                    width: MediaQuery.of(context).size.height * 0.25 / 2,
                    height:
                        MediaQuery.of(context).size.height * 0.75 / 2 * 3 / 4,
                    duration: const Duration(milliseconds: 0),
                    child: Image.asset("assets/images/Block3.png")));
          }
        } else {
          return Align(
              alignment: Alignment(obs.startPointX, obs.startPointY),
              child: AnimatedContainer(
                  width: MediaQuery.of(context).size.height * 0.35 / 2,
                  height: MediaQuery.of(context).size.height * 0.35 / 2 * 3 / 4,
                  duration: const Duration(milliseconds: 0),
                  child: Image.asset("assets/images/Barrier.png")));
        }
      }).toList(),
    );
  }
}
