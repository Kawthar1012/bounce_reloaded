import 'obstacle.dart';

// building the object for the model, this will be represented by "barrier.png"
class Barrier extends Obstacle {
  Barrier({required double startPointX, required double startPointY})
      : super(startPointX: startPointX, startPointY: startPointY);
}
