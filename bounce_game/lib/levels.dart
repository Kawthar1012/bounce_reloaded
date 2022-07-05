// Here is the data for the different levels

import 'package:bounce_game/barrier.dart';
import 'package:bounce_game/block.dart';

var levels = [
  [
    Block(startPointX: 1.2, startPointY: 1, nbOfObstacles: 2),
    Block(startPointX: 1.7, startPointY: 1, nbOfObstacles: 3),
    Barrier(startPointX: 2.05, startPointY: 1.05),
    Block(startPointX: 2.5, startPointY: 1, nbOfObstacles: 3),
    Barrier(startPointX: 3, startPointY: 1.05),
    Barrier(startPointX: 3.05, startPointY: 1.05),
    Barrier(startPointX: 3.1, startPointY: 1.05),
    Block(startPointX: 3.8, startPointY: 1, nbOfObstacles: 1),
    Block(startPointX: 4.15, startPointY: 1, nbOfObstacles: 2),
    Block(startPointX: 4.5, startPointY: 1, nbOfObstacles: 3)
  ]
];
