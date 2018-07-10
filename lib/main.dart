import 'application.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'routes.dart';
import 'home_page.dart';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:camera/camera.dart';
import 'package:party_quest/globals.dart' as globals;

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<Null> main() async {
  // Fetch the available cameras before initializing the app.
  try {
    globals.cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.description');
  }
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {

  MyApp() {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
    _signInAnonymously();
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Party Quest',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      onGenerateRoute: Application.router.generator,
      home: new HomePage(),
    );
  }

  Future<String> _signInAnonymously() async {
    final FirebaseUser user = await _auth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    if (Platform.isIOS) {
      // Anonymous auth doesn't show up as a provider on iOS
      assert(user.providerData.isEmpty);
    } else if (Platform.isAndroid) {
      // Anonymous auth does show up as a provider on Android
      assert(user.providerData.length == 1);
      assert(user.providerData[0].providerId == 'firebase');
      assert(user.providerData[0].uid != null);
      assert(user.providerData[0].displayName == null);
      assert(user.providerData[0].photoUrl == null);
      assert(user.providerData[0].email == null);
    }

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    return 'signInAnonymously succeeded: $user';
  }
}
