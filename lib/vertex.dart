import 'package:stagexl/stagexl.dart';

class Vertex {
  String type;
  List<Vertex> adjacencies = [];
  double minDistance = double.infinity;
  double estDistance = double.infinity;
  int row, col;
  Vertex previous;

  Sprite sprite;
  Bitmap bitmap;

  Vertex(this.type, this.bitmap, this.row, this.col) {
    sprite = Sprite();
    sprite.width = 30;
    sprite.height = 30;
    sprite.addChild(bitmap);
  }

  void moveSprite(double x, double y) {
    sprite.x = x;
    sprite.y = y;
  }

  Future<void> highlight(String color) async {
    int colorInt;
    if (type != 'start' && type != 'end') {
      if (color == 'yellow') {
        colorInt = Color.LightGoldenrodYellow;
      } else if (color == 'blue') {
        colorInt = Color.PaleTurquoise;
      }
      var new_bitmap = Bitmap(BitmapData(30, 30, colorInt));
      sprite.addChild(new_bitmap);
      type = 'visited';
    }
  }
}
