import 'dart:html';
import 'package:stagexl/stagexl.dart';
import 'package:test_project3/grid.dart';
import 'package:test_project3/gridtesttwo.dart';
import 'package:test_project3/demo.dart';

StageOptions options = StageOptions()
  ..backgroundColor = Color.White
  ..renderEngine = RenderEngine.WebGL;
CanvasElement canvas = querySelector('#stage');
Stage stage = Stage(canvas, width: 800, height: 800, options: options);
RenderLoop renderLoop = RenderLoop();
ResourceManager resourceManager = ResourceManager();

void main() {

  renderLoop.addStage(stage);

  resourceManager.load()
    .then((_) => stage.addChild(Demo()))
    .catchError((e) => print(e));

  //var grid = Grid();
}
