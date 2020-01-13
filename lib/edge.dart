import 'package:test_project3/vertex.dart';

class Edge {
  
  final Vertex target;
  final double weight;
  Edge(this.target, this.weight);

  Vertex getTarget() {
    return target;
  }

  double getWeight() {
    return weight;
  }
}