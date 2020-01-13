import 'package:test_project3/edge.dart';
import 'package:stagexl/stagexl.dart';

class Vertex {

  String type;
  List<Edge> adjacencies = [];
  double minDistance = double.infinity;
  Vertex previous;

  Sprite sprite;
  Bitmap bitmap;

  Vertex(this.type, this.bitmap) {
    sprite = Sprite();
    sprite.width = 30;
    sprite.height = 30;
    sprite.addChild(bitmap);
  }

  void setType(String type) {
    this.type = type;
  }

  String getType() {
    return type;
  }

  int compareTo(Vertex other) {
    return minDistance.compareTo(other.minDistance);
  }

  void moveSprite(double x, double y) {
    sprite.x = x;
    sprite.y = y;
  }

  Sprite getSprite() {
    return sprite;
  }

  void setPrevious(Vertex vertex) {
    previous = vertex;
  }

  void setMinDistance(double number) {
    minDistance = number;
  }

  double getMinDistance() {
    return minDistance;
  }

  void addAdjacencies(Edge edge) {
    adjacencies.add(edge);
  }

  List<Edge> getAdjacencies() {
    return adjacencies;
  }

  void visit() {
    //TODO: changes type, cost, color
    //should visit, if already visited, do nothing but note this
  }

/*

  Bitmap getBitmap() {
    return bitmap;
  }

  void visitSprite() {
    sprite.removeChild(bitmap);
    var new_bitmap = Bitmap(BitmapData(30, 30, Color.PaleTurquoise));
    sprite.addChild(new_bitmap);
  }
*/
}