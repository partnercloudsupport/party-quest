// import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart' show Colors, TextPainter, runApp;

import 'package:flame/game.dart';
// import 'package:flame/components/component.dart';
import 'package:flame/components/animation_component.dart';
import 'package:flame/flame.dart';

const CHARACTER_SIZE_X = 456.0;
const CHARACTER_SIZE_Y = 350.0;

class CharacterAnimation extends StatelessWidget {
  var game;

  CharacterAnimation(String characterFileName, double spriteX, double spriteY, int spriteCount){
    game = new MyGame(characterFileName, spriteX, spriteY, spriteCount);
    Flame.images.load(characterFileName);
  }
  
  @override
	Widget build(BuildContext context) {
    return game.widget;
  }
}

class Character extends AnimationComponent {
  static const TIME = 0.75;

  Character(String characterFileName, double spriteX, double spriteY, int spriteCount) : super.sequenced(spriteX, spriteY, characterFileName, spriteCount, textureWidth: spriteX, textureHeight: spriteY) {
    this.x = -40.0;
    this.y = 0.0;
    this.animation.stepTime = TIME / 10;
  }

  bool destroy() {
    return this.animation.done();
  }
}

class MyGame extends BaseGame {
  double creationTimer = 0.0;

  MyGame(String characterFileName, double spriteX, double spriteY, int spriteCount){
    add(new Character(characterFileName, spriteX, spriteY, spriteCount));
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // renderComponent(canvas, new Character());
  }

  @override
  void update(double t) {
    super.update(t);
  }

}