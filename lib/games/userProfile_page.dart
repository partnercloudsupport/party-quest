import 'package:flutter/material.dart';
import 'package:gratzi_game/globals.dart' as globals;
import 'package:fluro/fluro.dart';
import '../application.dart';

class UserProfilePage extends StatefulWidget {
  @override
  UserProfileState createState() => new UserProfileState();
}

class UserProfileState extends State<UserProfilePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        automaticallyImplyLeading: false,
        leading: new IconButton(icon: new Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context)),
        backgroundColor: const Color(0xFF00073F),
        elevation: -1.0,
        title: new Text("My Profile",
            style: new TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              fontSize: 22.0,
            )),
      ),
      body: Container(
              decoration: BoxDecoration(
                  image: DecorationImage(
                      image:
                          AssetImage("assets/images/background-gradient.png"),
                      fit: BoxFit.fill)),
              child: Column(children: <Widget>[
                _buildCameraView(),
                Padding(
                  padding: const EdgeInsets.all(65.0),
                ),
              ])),
    );
  }

  Widget _buildCameraView() {
    return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Text(
          globals.userState['name'],
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20.0,
            fontWeight: FontWeight.w700,
          ),
        ));
  }
}
