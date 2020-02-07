import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:test_project3/node.dart';

class GridNew extends DisplayObjectContainer {
  @override
  var stage;
  var canvas, renderLoop;

  final nodes = List<List<Node>>.generate(
      25, (i) => List<Node>.generate(25, (j) => null));
  Node start, end;
  Bitmap background;
  int r, c;

  GridNew() {
    var options = StageOptions()
      ..backgroundColor = Color.White
      ..renderEngine = RenderEngine.WebGL;
    canvas = querySelector('#stage');
    stage = Stage(canvas, width: 802, height: 802, options: options);
    renderLoop = RenderLoop();
    renderLoop.addStage(stage);

    background = Bitmap(BitmapData(800, 800, Color.Transparent));
    stage.addChild(background);

    for (var i = 0; i < 26; i++) {
      var horizontal = Bitmap(BitmapData(802, 2, Color.LightGray));
      horizontal.y = i * 32;
      addChild(horizontal);
      stage.addChild(horizontal);

      var vertical = Bitmap(BitmapData(2, 802, Color.LightGray));
      vertical.x = i * 32;
      addChild(vertical);
      stage.addChild(vertical);
    }

    var startBitmap = Bitmap(BitmapData(30, 30, Color.LimeGreen));
    start = Node('start', startBitmap, 7, 12);
    nodes[7][12] = start;
    start.move(226, 386);
    drawSprite(start);

    var endBitmap = Bitmap(BitmapData(30, 30, Color.OrangeRed));
    end = Node('end', endBitmap, 17, 12);
    nodes[17][12] = end;
    end.move(546, 386);
    drawSprite(end);

    for (var r = 0; r < nodes.length; r++) {
      for (var c = 0; c < nodes[r].length; c++) {
        if (nodes[r][c] != start && nodes[r][c] != end) {
          createNode(r, c, 'blank');
        }
      }
    }

    stage.onMouseDown.listen((e) {
      if (background.hitTestInput(mouseX, mouseY) != null) {
        r = mouseGridRow();
        c = mouseGridColumn();
        if (nodes[r][c] == start) {
          removeSprite(start);
          drawSprite(start);
          start.sprite.startDrag();
        } else if (nodes[r][c] == end) {
          removeSprite(end);
          drawSprite(end);
          end.sprite.startDrag();
        }
      }
    });

    stage.onMouseUp.listen((e) {
      start.sprite.stopDrag();
      end.sprite.stopDrag();
      if (background.hitTestInput(mouseX, mouseY) != null) {
        if (moveEndpoint(r, c)) {
          createNode(r, c, 'wall');
        }
      } else {
        nodes[r][c].move(spritePosition(r), spritePosition(c));
      }
    });

    var dijkstraButton = querySelector('#dijkstraButton');
    dijkstraButton.onClick.listen((e) {
      print("running Dijkstra's algorithm");
      calculateAdjacencies();
      var visited = computePaths();
      var path = getShortestPath();
      highlight(visited, path);
      print("ran Dijkstra's algorithm");
    });

    var clearButton = querySelector('#clearButton');
    clearButton.onClick.listen((e) {
      print('clearing nodes');
      clearNodes();
      print('cleared nodes');
    });
  }

  void printNodes() {
    var types = '';
    var counter = 0;
    for (var r = 0; r < nodes.length; r++) {
      for (var c = 0; c < nodes[r].length; c++) {
        counter++;
        if (nodes[r][c] != null) {
          var type = nodes[r][c].type;
          types = ('$types $type:$counter, ');
        } else {
          types = ('$types null:$counter, ');
        }
      }
    }
    print(types);
  }

  void createNode(int r, int c, String type) {
    var x_pos = spritePosition(r), y_pos = spritePosition(c);
    var bitmap;
    if (type == 'wall') {
      bitmap = Bitmap(BitmapData(30, 30, Color.DarkGray));
      print('created wall at ($r, $c)');
    } else if (type == 'blank') {
      bitmap = Bitmap(BitmapData(30, 30, Color.Transparent));
    } else {
      return;
    }
    var node = Node(type, bitmap, r, c);
    node.move(x_pos, y_pos);
    if (node.type != 'blank') {
      drawSprite(node);
    }
    nodes[r][c] = node;
  }

  bool moveEndpoint(int r, int c) {
    if (deleteNode(r, c, true)) {
      return false;
    }

    int new_r, new_c;
    new_r = mouseGridRow();
    new_c = mouseGridColumn();

    num old_x_pos = spritePosition(r), old_y_pos = spritePosition(c);
    num new_x_pos = spritePosition(new_r), new_y_pos = spritePosition(new_c);

    if (nodes[new_r][new_c] == end && nodes[r][c] == start) {
      nodes[r][c].move(old_x_pos, old_y_pos);
      print(
          "can't move start node to ($new_r, $new_c), position is occupied by end node");
      return false;
    } else if (nodes[new_r][new_c] == start && nodes[r][c] == end) {
      nodes[r][c].move(old_x_pos, old_y_pos);
      print(
          "can't move end node to ($new_r, $new_c), position is occupied by start node");
      return false;
    }

    deleteNode(new_r, new_c, true);

    if (nodes[r][c] == start) {
      start.move(new_x_pos, new_y_pos);
      createNode(r, c, 'blank');
      nodes[new_r][new_c] = start;
      print('moved start node to ($new_r, $new_c)');
      //calculateAdjacencies();
      return false;
    } else if (nodes[r][c] == end) {
      end.move(new_x_pos, new_y_pos);
      createNode(r, c, 'blank');
      nodes[new_r][new_c] = end;
      print('moved end node to ($new_r, $new_c)');
      //calculateAdjacencies();
      return false;
    } else {
      return true;
    }
  }

  bool deleteNode(int r, int c, bool audit) {
    if (nodes[r][c].type != 'start' && nodes[r][c].type != 'end') {
      stage.removeChild(nodes[r][c].sprite);
      createNode(r, c, 'blank');
      if (audit) {
        print('deleted wall at ($r, $c)');
      }
      return true;
    }
    return false;
  }

  // replaces all wall/visited nodes with blank nodes
  void clearNodes() {
    for (var r = 0; r < nodes.length; r++) {
      for (var c = 0; c < nodes[r].length; c++) {
        deleteNode(r, c, false);
      }
    }
  }

  void calculateAdjacencies() {
    for (var r = 0; r < nodes.length; r++) {
      for (var c = 0; c < nodes[r].length; c++) {
        nodes[r][c].adjacencies.clear();

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

  List computePaths() {
    var visited = [];
    start.minDistance = 0;
    var queue = [];
    queue.add(start);

    while (queue.isNotEmpty) {
      if (queue.elementAt(0).type == 'wall') {
        queue.removeAt(0);
      }
      var current = queue.elementAt(0);
      queue.removeAt(0);
      if (current == end) {
        return visited;
      }
      visited.add(current);
      current.type == 'visited';
      for (Node node in current.adjacencies) {
        //visited.add(node);
        double currentDistance = current.minDistance + 1;
        if (currentDistance < node.minDistance) {
          queue.remove(node);
          node.minDistance = currentDistance;
          node.previous = current;
          queue.add(node);
        }
      }
    }
    return visited;
  }

  List getShortestPath() {
    var path = [];
    for (var node = end; node != null; node = node.previous) {
      path.add(node);
    }
    return path;
  }

  Future<void> highlight(List visited, List path) async {
    for (var node in visited) {
      node.highlight('blue');
      await Future.delayed(Duration(microseconds: 100));
      drawSprite(node);
    }

    for (var node in path) {
      node.highlight('yellow');
      drawSprite(node);
    }
  }

  void drawSprite(Node node) {
    stage.addChild(node.sprite);
  }

  void removeSprite(Node node) {
    stage.removeChild(node.sprite);
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
