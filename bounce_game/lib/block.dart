import 'obstacle.dart';

// building the object for the model, this will be represented by "block.png"
class Block extends Obstacle {
  int nbOfObstacles = 1;

  Block(
      {required double startPointX,
      required double startPointY,
      required this.nbOfObstacles})
      : super(startPointX: startPointX, startPointY: startPointY);
}
