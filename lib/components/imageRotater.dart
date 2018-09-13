import 'package:flutter/material.dart';

class ImageRotater extends StatefulWidget {
  @override
  _ImageRotaterState createState() => new _ImageRotaterState();
}

class _ImageRotaterState extends State<ImageRotater> with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation rotationAngle;

  @override
  void initState() {
    super.initState();
    animationController = new AnimationController(
      vsync: this,
      duration: new Duration(seconds: 2),
    );
    // final CurvedAnimation curve =
    //     CurvedAnimation(parent: animationController, curve: Interval(0.0, 0.75, curve: Curves.easeOut));
    // rotationAngle = Tween(begin: 0.0, end: 12000.0).animate(curve);
    animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      alignment: Alignment.center,
      // color: Colors.white,
      child: new AnimatedBuilder(
        animation: animationController,
        child: new Container(
          height: 50.0,
          width: 50.0,
          child: new Image.asset('assets/images/20D20.png'),
        ),
        builder: (BuildContext context, Widget _widget) {
          return new Transform.rotate(
            angle: animationController.value * 46,
            child: _widget,
          );
        },
      ),
    );
  }

  void rollDice(){
    animationController.forward();
  }
}