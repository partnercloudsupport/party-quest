import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:gratzi_game/globals.dart' as globals;

class UserProfilePage extends StatefulWidget {
  @override
  UserProfileState createState() => new UserProfileState();
}

class UserProfileState extends State<UserProfilePage> {
  CameraController controller;
  @override
  void initState() {
    super.initState();
    if (globals.cameras.length > 0) {
      controller =
          new CameraController(globals.cameras[1], ResolutionPreset.medium);
      controller.initialize().then((_) {
        if (!mounted) {
          return;
        }
        setState(() {});
      });
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // color: Colors.white,
      appBar: new AppBar(
        elevation: -1.0,
        title: new Text("My Profile",
            style: new TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w800,
              fontFamily: 'Roboto',
              letterSpacing: 0.5,
              fontSize: 22.0,
            )),
      ),
      body: Column(children: <Widget>[
        Expanded(child: _buildCameraView()),
        Padding(
          padding: const EdgeInsets.all(65.0),
        ),
      ]),
    );
  }

  Widget _buildCameraView() {
    if (controller == null || !controller.value.isInitialized) {
      return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            'No camera available...',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20.0,
              fontWeight: FontWeight.w700,
            ),
          ));
    } else {
      return AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: new CameraPreview(controller));
    }
  }
}
