import 'package:stagexl/stagexl.dart';

class Node {
  String type;
  Bitmap bitmap;
  num row, column, minDistance = double.infinity;
  Node previous;
  List<Node> adjacencies = [];

  Node(this.bitmap, this.type, this.row, this.column) {
    bitmap.x = (row / 32).truncate();
    bitmap.y = (column / 32).truncate();
  }
}