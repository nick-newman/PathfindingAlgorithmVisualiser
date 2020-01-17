import 'package:stagexl/stagexl.dart';

class Vertex {

  String type;
  List<Vertex> adjacencies = [];
  double minDistance = double.infinity;
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

  void setType(String type) {
    this.type = type;
  }

  int compareTo(Vertex other) {
    return minDistance.compareTo(other.minDistance);
  }

  void moveSprite(double x, double y) {
    sprite.x = x;
    sprite.y = y;
  }

  void addAdjacencies(Vertex vertex) {
    adjacencies.add(vertex);
  }

  // TODO: instead of using highlight, should create vertexless bitmaps stored in arrays for path/visited
  void highlight(String color) {
    int colorInt;
    if (type == 'blank') {
      // Note: blank verticies do not have a drawn sprite
      if (color == 'yellow') {
        colorInt = Color.LightGoldenrodYellow;
      } else if (color == 'blue') {
        colorInt = Color.PaleTurquoise;
      }
      var new_bitmap = Bitmap(BitmapData(30, 30, colorInt));
      sprite.addChild(new_bitmap);
    }
  }
}