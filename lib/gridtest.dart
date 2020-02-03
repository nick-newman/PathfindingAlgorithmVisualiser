import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:test_project3/node.dart';

class GridTest extends DisplayObjectContainer {

  @override
  var stage;
  var canvas, renderLoop;
  int row, column;
  Node startNode, endNode;
  Bitmap startBitmap, endBitmap, backgroundBitmap;
  Sprite startSprite = Sprite(), endSprite = Sprite();
  final nodes = List<List<Node>>.generate(25, (i) => List<Node>.generate(25, (j) => null));

  GridTest() {
    var options = StageOptions()
      ..backgroundColor = Color.White
      ..renderEngine = RenderEngine.WebGL;
    canvas = querySelector('#stage');
    stage = Stage(canvas, width: 801, height: 801, options: options);
    renderLoop = RenderLoop();
    renderLoop.addStage(stage);

    for (var i = 0; i < 26; i++) {
      var horizontal = Bitmap(BitmapData(802, 2, Color.LightGray));
      horizontal.y = i * 32;
      stage.addChild(horizontal);

      var vertical = Bitmap(BitmapData(2, 802, Color.LightGray));
      vertical.x = i * 32;
      stage.addChild(vertical);
    }

    backgroundBitmap = Bitmap(BitmapData(800, 800, Color.Transparent));
    stage.addChild(backgroundBitmap);

    startBitmap = Bitmap(BitmapData(30, 30, Color.LimeGreen));
    startNode = Node(startBitmap, 'start', 7, 12);
    nodes[7][12] = startNode;
    startSprite.addChild(startBitmap);
    stage.addChild(startSprite);
    startSprite.x = 226;
    startSprite.y = 386;

    endBitmap = Bitmap(BitmapData(30, 30, Color.OrangeRed));
    endNode = Node(endBitmap, 'end', 7, 12);
    nodes[7][12] = endNode;
    endSprite.addChild(endBitmap);
    stage.addChild(endSprite);
    endBitmap.x = 546;
    endBitmap.y = 386;

    for (var r = 0; r < nodes.length; r++) {
      for (var c = 0; c < nodes[r].length; c++) {
        if (nodes[r][c] != startNode && nodes[r][c] != endNode) {
          createBlankNode(r , c);
        }
      }
    }

    stage.onMouseDown.listen((e) {
      if (backgroundBitmap.hitTestInput(mouseX, mouseY) != null) {
        row = mouseGridRow();
        column = mouseGridColumn();
        if (nodes[row][column] == startNode) {
          stage.removeChild(startSprite);
          stage.addChild(startSprite);
          startSprite.startDrag();
        } else if (nodes[row][column] == endNode) {
          stage.removeChild(endSprite);
          stage.addChild(endSprite);
          endSprite.startDrag();
        }
      }
    });

    stage.onMouseUp.listen((e) {
      startSprite.stopDrag();
      endSprite.stopDrag();
      if (backgroundBitmap.hitTestInput(mouseX, mouseY) != null) {
        if (moveEndpoint(row, column)) {
          createWallNode(row, column);
        }
      } else {
        if (nodes[row][column].type == 'start') {
          startSprite.x = spritePosition(row);
          startSprite.y = spritePosition(column);
        } else if (nodes[row][column].type == 'end') {
          endSprite.x = spritePosition(row);
          endSprite.y = spritePosition(column);
        }
      }
    });
  }

  bool moveEndpoint(int r, int c) {
    if (deleteWallNode(r, c)) {
      return false;
    }

    num new_r, new_c;
    new_r = mouseGridRow();
    new_c = mouseGridColumn();

    num old_x_pos = spritePosition(r), old_y_pos = spritePosition(c);
    num new_x_pos = spritePosition(new_r), new_y_pos = spritePosition(new_c);

    if (nodes[new_r][new_c] == endNode && nodes[r][c] == startNode) {
      nodes[r][c].bitmap.x = old_x_pos;
      nodes[r][c].bitmap.y = old_y_pos;
      print("can't move start node to ($new_r, $new_c), position is occupied by end node");
      return false;
    } else if (nodes[new_r][new_c] == startNode && nodes[r][c] == endNode) {
      nodes[r][c].bitmap.x = old_x_pos;
      nodes[r][c].bitmap.y = old_y_pos;
      print("can't move end node to ($new_r, $new_c), position is occupied by start node");
      return false;
    }

    deleteWallNode(new_r, new_c);

    if (nodes[r][c] == startNode) {
      startNode.bitmap.x = new_x_pos;
      startNode.bitmap.y = new_y_pos;
      createBlankNode(r, c);
      nodes[new_r][new_c] = startNode;
      print('moved start node to ($new_r, $new_c)');
      return false;
    } else if (nodes[r][c] == endNode) {
      endNode.bitmap.x = new_x_pos;
      endNode.bitmap.y = new_y_pos;
      createBlankNode(r, c);
      nodes[new_r][new_c] = endNode;
      print('moved end node to ($new_r, $new_c)');
      return false;
    } else {
      return true;
    }
  }

  void createWallNode(num r, num c) {
    var wallBitmap = Bitmap(BitmapData(30, 30, Color.Gray));
    nodes[r][c] = Node(wallBitmap, 'wall', r, c);
    print('created wall at ($r, $c)');
  }

  void createBlankNode(num r, num c) {
    Bitmap blankBitmap;
    nodes[r][c] = Node(blankBitmap, 'blank', r, c);
  }

  bool deleteWallNode(num r, num c) {
    if (nodes[r][c] != startNode && nodes[r][c] != endNode) {
      stage.removeChild(nodes[r][c].bitmap);
      createBlankNode(r, c);
      print('deleted wall at ($r, $c)');
      return true;
    }
    return false;
  }

  void clearWallNodes() {
    for (var r = 0; r < nodes.length; r++) {
      for (var c = 0; c < nodes[r].length; c++) {
        deleteWallNode(r, c);
      }
    }
  }

  void calculateAdjacencies() {
    for (var r = 0; r < nodes.length; r++) {
      for (var c = 0; c < nodes[r].length; c++) {
        if (c - 1 > -1 && nodes[r][c - 1].type != 'wall') {
          nodes[r][c].adjacencies.add(nodes[r][c - 1]);
        }
        if (r + 1 < 25 && nodes[r + 1][c].type != 'wall') {
          nodes[r][c].adjacencies.add(nodes[r + 1][c]);
        }
        if (c + 1 < 25 && nodes[r][c + 1].type != 'wall') {
          nodes[r][c].adjacencies.add(nodes[r][c + 1]);
        }
        if (r - 1 > -1 && nodes[r - 1][c].type != 'wall') {
          nodes[r][c].adjacencies.add(nodes[r - 1][c]);
        }
      }
    }
  }

  int mouseGridRow() {
    return (mouseX / 32).truncate();
  }

  int mouseGridColumn() {
    return (mouseY / 32).truncate();
  }

  int spritePosition(int n) {
    return n * 32 + 2;
  }

  int listPosition(int n) {
    return (n / 32).truncate();
  }
}