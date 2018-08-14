import 'application.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'routes.dart';
import 'pages/splash_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pegg_party/globals.dart' as globals;
import 'pages/home_page.dart';
import 'package:flutter/services.dart';

final FirebaseAuth _auth = FirebaseAuth.instance;

Future<Null> main() async {
  runApp(new PeggParty());
}

class PeggParty extends StatefulWidget {
  @override
  createState() => PeggPartyState();
}

class PeggPartyState extends State<PeggParty> {
  PeggPartyState() {
    final router = new Router();
    Routes.configureRoutes(router);
    Application.router = router;
    _signInAnonymously();
    globals.userState.changes.listen((changes) {
      setState(() {
        _userName = globals.userState['name'];
      });
    });
  }
  String _userName;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome
        .setApplicationSwitcherDescription(new ApplicationSwitcherDescription(
      primaryColor: 0xFF,
    ));

    Widget startPage;
    if (_userName != null && _userName.length > 0) {
      startPage = HomePage();
    } else {
      startPage = SplashPage();
    }
    return new MaterialApp(
      title: 'Pegg Party',
      theme: new ThemeData(
          primaryColor: Colors.white,
          fontFamily: 'Montserrat',
          canvasColor: Colors.black,
          primaryColorLight: Colors.white.withOpacity(0.2)),
      onGenerateRoute: Application.router.generator,
      home: startPage,
    );
  }

  Future<String> _signInAnonymously() async {
    final FirebaseUser user = await _auth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    // assert(!user.isEmailVerified);
    assert(await user.getIdToken() != null);
    // if (Platform.isIOS) {
    //   // Anonymous auth doesn't show up as a provider on iOS
    //   assert(user.providerData.isEmpty);
    // } else if (Platform.isAndroid) {
    //   // Anonymous auth does show up as a provider on Android
    //   assert(user.providerData.length == 1);
    //   assert(user.providerData[0].providerId == 'firebase');
    //   assert(user.providerData[0].uid != null);
    //   assert(user.providerData[0].displayName == null);
    //   assert(user.providerData[0].photoUrl == null);
    //   assert(user.providerData[0].email == null);
    // }

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);
    globals.userState['userId'] = user.uid;
    var userRef = Firestore.instance.collection('Users').document(user.uid);
    userRef.get().then((snapshot) {
      if (snapshot.data != null) {
        if (snapshot.data['profilePic'] != null) {
          globals.userState['profilePic'] = snapshot.data['profilePic'];
          globals.userState['isLoggedIn'] = true;
        }
        globals.userState['name'] = snapshot.data['name'];
      } 
      // else {
      //   globals.userState['isLoggedIn'] = false;
      // }
    });
    return 'signInAnonymously succeeded: $user';

    // UserUpdateInfo ui = new UserUpdateInfo();
    // ui.displayName = text;
    // ui.photoUrl = _downloadUrl;
    // FirebaseAuth.instance.updateProfile(ui);
  }
}
