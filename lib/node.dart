import 'package:stagexl/stagexl.dart';

class Node {
  String type;
  Node previous;
  List<Node> adjacencies = [];
  double minDistance = double.infinity;
  int row, col;
  Sprite sprite;
  Bitmap bitmap;

  Node(this.type, this.bitmap, this.row, this.col) {
    sprite = Sprite();
    sprite.width = 30;
    sprite.height = 30;
    sprite.addChild(bitmap);
  }

  void move(int x, int y) {
    sprite.x = x;
    sprite.y = y;
  }

  void highlight() async {
    Bitmap newBitmap;
    if (type == 'visited') {
      newBitmap = Bitmap(BitmapData(30, 30, Color.PaleTurquoise));
    } else {
      newBitmap = Bitmap(BitmapData(30, 30, Color.LightGoldenrodYellow));
    }
    sprite.removeChild(bitmap);
    sprite.addChild(newBitmap);
  }
}
