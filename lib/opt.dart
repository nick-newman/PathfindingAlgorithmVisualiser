import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:test_project3/node.dart';

class Opt {

  List<List<Node>> nodes;
  Node start;
  Node end;

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

    List computePaths() {
      var visited = [];
      var queue = [];
      start.minDistance = 0;
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
        for (Node node in current.adjacencies) {
          visited.add(node);
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
      for (var vertex = end; vertex != null; vertex = vertex.previous) {
        path.add(vertex);
      }
      return path;
    }

    Future<void> highlightNodes(List visited, List path, int speed) async {
      for (var node in visited) {
        //await Future.delayed(Duration(milliseconds : speed));        
        //stage.removeChild(node);
        node.highlight(Color.MediumTurquoise);
        //stage.addChild(node);
      }
      for (var node in path) {
        //stage.removeChild(node);
        node.highlight(Color.LightYellow);
        //stage.addChild(node);
      }
    }
}