import 'package:flutter/material.dart';
import '../application.dart';
import 'package:fluro/fluro.dart';

class FancyFab extends StatefulWidget {
  final Function() onPressed;
  final String tooltip;
  final IconData icon;

  FancyFab({this.onPressed, this.tooltip, this.icon});

  @override
  _FancyFabState createState() => _FancyFabState();
}

class _FancyFabState extends State<FancyFab>
    with SingleTickerProviderStateMixin {
  bool isOpened = false;
  AnimationController _animationController;
  Animation<Color> _buttonColor;
  Animation<double> _animateIcon;
  Animation<double> _translateButton;
  Curve _curve = Curves.easeOut;
  double _fabHeight = 56.0;

  @override
  initState() {
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 500))
          ..addListener(() {
            setState(() {});
          });
    _animateIcon =
        Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _buttonColor = ColorTween(
      end: const Color(0xFFD7263D),
      begin: const Color(0xFF00B0FF),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.00,
        1.00,
        curve: Curves.linear,
      ),
    ));
    _translateButton = Tween<double>(
      begin: _fabHeight,
      end: -14.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Interval(
        0.0,
        0.75,
        curve: _curve,
      ),
    ));
    super.initState();
  }

  @override
  dispose() {
    _animationController.dispose();
    super.dispose();
  }

  animate() {
    if (!isOpened) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
    isOpened = !isOpened;
  }

  // Widget add() {
  //   return Container(
  //     child: FloatingActionButton(
  //       onPressed: null,
  //       tooltip: 'Add',
  //       child: Icon(Icons.add),
  //     ),
  //   );
  // }

  Widget image() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonColor,
        foregroundColor: Colors.white,
        heroTag: 'Create',
        onPressed: () => Application.router
          .navigateTo(context, 'createGame', transition: TransitionType.fadeIn),
        tooltip: 'Create Game',
        child: Text('Create'),
      ),
    );
  }

  Widget inbox() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: Theme.of(context).buttonColor,
        foregroundColor: Colors.white,
        heroTag: 'Join',
        onPressed: () => Application.router
          .navigateTo(context, 'joinGame', transition: TransitionType.fadeIn),
        tooltip: 'Join Game',
        child: Text('Join'),
      ),
    );
  }

  Widget toggle() {
    return Container(
      child: FloatingActionButton(
        backgroundColor: _buttonColor.value,
        onPressed: animate,
        tooltip: 'Toggle',
        child: AnimatedIcon(
          color: Colors.white,
          icon: AnimatedIcons.add_event,
          progress: _animateIcon,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        // Transform(
        //   transform: Matrix4.translationValues(
        //     0.0,
        //     _translateButton.value * 3.0,
        //     0.0,
        //   ),
        //   child: add(),
        // ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value * 2.0,
            0.0,
          ),
          child: image(),
        ),
        Transform(
          transform: Matrix4.translationValues(
            0.0,
            _translateButton.value,
            0.0,
          ),
          child: inbox(),
        ),
        toggle(),
      ],
    );
  }
}