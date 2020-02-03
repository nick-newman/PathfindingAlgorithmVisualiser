import 'package:stagexl/stagexl.dart';

class Node {
  String type;
  Bitmap bitmap;
  int row, column;
  double minDistance = double.infinity;
  Node previous;
  List<Node> adjacencies = [];

  Node(this.bitmap, this.type, this.row, this.column) {
    //bitmap.x = (row / 32).truncate();
    //bitmap.y = (column / 32).truncate();
  }

  void highlight(int color) {
    int x = bitmap.x, y = bitmap.y;
    bitmap = Bitmap(BitmapData(30, 30, color));
    bitmap.x = x;
    bitmap.y = y;
  }

}