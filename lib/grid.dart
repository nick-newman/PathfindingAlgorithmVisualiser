import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:test_project3/vertex.dart';

class Grid extends DisplayObjectContainer {
  @override
  var stage;
  var canvas, renderLoop;
  Bitmap background;
  bool running = true, algorithm = false;

  final verticies = List<List<Vertex>>.generate(
      25, (i) => List<Vertex>.generate(25, (j) => null));
  Vertex start, end;

  Grid() {
    var options = StageOptions()
      ..backgroundColor = Color.White
      ..renderEngine = RenderEngine.WebGL;
    canvas = querySelector('#stage');
    stage = Stage(canvas, width: 802, height: 802, options: options);
    renderLoop = RenderLoop();
    renderLoop.addStage(stage);

    background = Bitmap(BitmapData(800, 800, Color.Transparent));
    addChild(background);
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
    start = Vertex('start', startBitmap, 7, 12);
    verticies[7][12] = start;
    start.moveSprite(226, 386);
    drawSprite(start);

    var endBitmap = Bitmap(BitmapData(30, 30, Color.OrangeRed));
    end = Vertex('end', endBitmap, 17, 12);
    verticies[17][12] = end;
    end.moveSprite(546, 386);
    drawSprite(end);

    for (var r = 0; r < verticies.length; r++) {
      for (var c = 0; c < verticies[r].length; c++) {
        if (verticies[r][c] != start && verticies[r][c] != end) {
          createVertex(r, c, 'blank');
        }
      }
    }

    int r, c;

    stage.onMouseDown.listen((e) {
      if (background.hitTestInput(mouseX, mouseY) != null) {
        r = mouseGridRow();
        c = mouseGridColumn();

        if (verticies[r][c] == start) {
          removeSprite(start);
          drawSprite(start);
          start.sprite.startDrag();
        } else if (verticies[r][c] == end) {
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
          createVertex(r, c, 'wall');
        }
      } else {
        verticies[r][c].moveSprite(
            spritePosition(r) as double, spritePosition(c) as double);
      }
    });

    var dijkstraButton = querySelector('#dijkstraButton');
    dijkstraButton.onClick.listen((e) {
      if (algorithm) {
        return;
      }
      running = true;
      var speed = int.parse((querySelector('#speedInput') as InputElement).value);
      if (speed < 0 || speed > 5000) {
        speed = 50;
      }
      print("running Dijkstra's algorithm");
      for (var r = 0; r < verticies.length; r++) {
        for (var c = 0; c < verticies[r].length; c++) {
          if (verticies[r][c].type == 'visited' || verticies[r][c].type == 'path') {
            stage.removeChild(verticies[r][c].sprite);
            createVertex(r, c, 'blank');
          }
        }
      }
      calculateAdjacencies();
      var visited = computeDijkstraPaths();
      var path = getShortestPath();
      highlight(visited, path, speed);
      print("ran Dijkstra's algorithm");
      for (var r = 0; r < verticies.length; r++) {
        for (var c = 0; c < verticies[r].length; c++) {
          Vertex blankPrevious;
          verticies[r][c].previous = blankPrevious;
          verticies[r][c].minDistance = double.infinity;
          verticies[r][c].adjacencies.clear();
        }
      }
    });

    var aStarButton = querySelector('#aStarButton');
    aStarButton.onClick.listen((e) {
      if (algorithm) {
        return;
      }
      running = true;
      var speed = int.parse((querySelector('#speedInput') as InputElement).value);
      if (speed < 0 || speed > 5000) {
        speed = 50;
      }
      print('running A* algorithm');
      for (var r = 0; r < verticies.length; r++) {
        for (var c = 0; c < verticies[r].length; c++) {
          if (verticies[r][c].type == 'visited' || verticies[r][c].type == 'path') {
            stage.removeChild(verticies[r][c].sprite);
            createVertex(r, c, 'blank');
          }
        }
      }
      calculateAdjacencies();
      var visited = computeAStarPaths();
      var path = getShortestPath();
      highlight(visited, path, speed);
      print('ran A* algorithm');
      for (var r = 0; r < verticies.length; r++) {
        for (var c = 0; c < verticies[r].length; c++) {
          Vertex blankPrevious;
          verticies[r][c].previous = blankPrevious;
          verticies[r][c].minDistance = double.infinity;
          verticies[r][c].adjacencies.clear();
        }
      }
    });

    var clearButton = querySelector('#clearButton');
    clearButton.onClick.listen((e) {
      clearVerticies();
    });

    var stopButton = querySelector('#stopButton');
    stopButton.onClick.listen((e) {
      running = false;
      algorithm = false;
      print('stopped');
    });
  }

  void printVerticies() {
    var types = '';
    var counter = 0;
    for (var r = 0; r < verticies.length; r++) {
      for (var c = 0; c < verticies[r].length; c++) {
        counter++;
        if (verticies[r][c] != null) {
          var type = verticies[r][c].type;
          types = ('$types $type:$counter, ');
        } else {
          types = ('$types null:$counter, ');
        }
      }
    }
    print(types);
  }

  void createVertex(int r, int c, String type) {
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
    var vertex = Vertex(type, bitmap, r, c);
    vertex.moveSprite(x_pos as double, y_pos as double);
    if (vertex.type != 'blank') {
      drawSprite(vertex);
    }
    verticies[r][c] = vertex;
  }

  bool moveEndpoint(int r, int c) {
    if (deleteVertex(r, c, true)) {
      return false;
    }

    int new_r, new_c;
    new_r = mouseGridRow();
    new_c = mouseGridColumn();

    num old_x_pos = spritePosition(r), old_y_pos = spritePosition(c);
    num new_x_pos = spritePosition(new_r), new_y_pos = spritePosition(new_c);

    if (verticies[new_r][new_c] == end && verticies[r][c] == start) {
      verticies[r][c].moveSprite(old_x_pos, old_y_pos);
      print(
          "can't move start node to ($new_r, $new_c), position is occupied by end node");
      return false;
    } else if (verticies[new_r][new_c] == start && verticies[r][c] == end) {
      verticies[r][c].moveSprite(old_x_pos, old_y_pos);
      print(
          "can't move end node to ($new_r, $new_c), position is occupied by start node");
      return false;
    }

    deleteVertex(new_r, new_c, true);

    if (verticies[r][c] == start) {
      start.moveSprite(new_x_pos, new_y_pos);
      createVertex(r, c, 'blank');
      verticies[new_r][new_c] = start;
      print('moved start node to ($new_r, $new_c)');
      return false;
    } else if (verticies[r][c] == end) {
      end.moveSprite(new_x_pos, new_y_pos);
      createVertex(r, c, 'blank');
      verticies[new_r][new_c] = end;
      print('moved end node to ($new_r, $new_c)');
      return false;
    } else {
      return true;
    }
  }

  bool deleteVertex(int r, int c, bool audit) {
    if (verticies[r][c].type == 'wall' || verticies[r][c].type == 'visited') {
      stage.removeChild(verticies[r][c].sprite);
      createVertex(r, c, 'blank');
      if (audit) {
        print('deleted wall at ($r, $c)');
      }
      return true;
    }
    return false;
  }

  void clearVerticies() {
    if (algorithm) {
      print("can't clear verticies while running");
      return;
    }
    print('clearing verticies');
    for (var r = 0; r < verticies.length; r++) {
      for (var c = 0; c < verticies[r].length; c++) {
        deleteVertex(r, c, false);
      }
    }
    print('cleared verticies');
  }

  void calculateAdjacencies() {
    for (var r = 0; r < verticies.length; r++) {
      for (var c = 0; c < verticies[r].length; c++) {
        if (c - 1 > -1 && verticies[r][c - 1].type != 'wall') {
          verticies[r][c].adjacencies.add(verticies[r][c - 1]);
        }
        if (r + 1 < 25 && verticies[r + 1][c].type != 'wall') {
          verticies[r][c].adjacencies.add(verticies[r + 1][c]);
        }
        if (c + 1 < 25 && verticies[r][c + 1].type != 'wall') {
          verticies[r][c].adjacencies.add(verticies[r][c + 1]);
        }
        if (r - 1 > -1 && verticies[r - 1][c].type != 'wall') {
          verticies[r][c].adjacencies.add(verticies[r - 1][c]);
        }
      }
    }
  }

  List computeDijkstraPaths() {
    algorithm = true;
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
        for (Vertex vertex in current.adjacencies) {
          double currentDistance = current.minDistance + 1;
          if (currentDistance < vertex.minDistance) {
            queue.remove(vertex);
            vertex.minDistance = currentDistance;
            vertex.previous = current;
            queue.add(vertex);
          }
        }
      }
    return visited;
  }

  List computeAStarPaths() {
    algorithm = true;
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
        for (Vertex vertex in current.adjacencies) {

//-*

//https://dzone.com/articles/from-dijkstra-to-a-star-a-part-2-the-a-star-a-algo

//g_cost is minDistance
//f_cost should be added to vertex, set to infinity (later gets calculated by algo)
//h_cost is set to nothing in constructor, set to something here (it is the estimation)

      //double new_g_cost = current.g_cost + 1; \/
      double currentDistance = current.minDistance + 1;
      double newEstDistance = 1 + new_g_cost;
      //vertex.h_cost instead of 1 for above

      if (newEstDistance < vertex.estDistance) {
        vertex.parent = current;
        vertex.minDistance = currentDistance;
        //vertex.g_cost = new_g_cost; /\
        vertex.estDistance = newEstDistance;
        if (queue.contains(vertex)) {
          queue.remove(vertex);
        }
        queue.add(vertex);
      }
//-*

//--
          //double currentDistance = current.minDistance + 1;
          if (currentDistance < vertex.minDistance) {
            queue.remove(vertex);
            vertex.minDistance = currentDistance;
            vertex.previous = current;
            queue.add(vertex);
          }
//--
        }
      }
    return visited;
  }

  List getShortestPath() {
    var path = [];
    for (var vertex = end; vertex != null; vertex = vertex.previous) {
      path.add(vertex);
    }
    return path;
  }

  Future<void> highlight(List visited, List path, int speed) async {
    for (var vertex in visited) {
      if (!running) {
        return;
      }
      vertex.highlight('blue');
      await Future.delayed(Duration(milliseconds: speed));
      drawSprite(vertex);
    }

    for (var vertex in path) {
      if (!running) {
        return;
      }
      vertex.highlight('yellow');
      drawSprite(vertex);
    }
    running = false;
    algorithm = false;
  }

  void drawSprite(Vertex vertex) {
    stage.addChild(vertex.sprite);
  }

  void removeSprite(Vertex vertex) {
    stage.removeChild(vertex.sprite);
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