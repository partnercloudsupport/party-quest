import 'application.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluro/fluro.dart';
import 'routes.dart';
import 'pages/splash_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
import 'pages/home_page.dart';
import 'package:flutter/services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';

final FirebaseMessaging _firebaseMessaging = new FirebaseMessaging();
final FirebaseAuth _auth = FirebaseAuth.instance;

Future<Null> main() async {
  runApp(new PartyQuest());
}

class PartyQuest extends StatefulWidget {
  @override
  createState() => PartyQuestState();
}

class PartyQuestState extends State<PartyQuest> {
  PartyQuestState() {
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
  DatabaseReference _messagesRef;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        // _navigateToItemDetail(message);
      },
    );
    _firebaseMessaging.requestNotificationPermissions(
        const IosNotificationSettings(sound: true, badge: true, alert: true));
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print("Settings registered: $settings");
    });
  }

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
          fontFamily: 'LondrinaSolid',
          textTheme: TextTheme(title: TextStyle(letterSpacing: 1.2)) ,
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
    globals.userState['loginStatus'] = 'loggingIn';
    userRef.get().then((snapshot) {
      if (snapshot.data != null) { //snapshot.data != null
        if (snapshot.data['profilePic'] != null) {
          globals.userState['profilePic'] = snapshot.data['profilePic'];
          globals.userState['loginStatus'] = 'loggedIn';
        }
        globals.userState['name'] = snapshot.data['name'];
      } 
      else {
        globals.userState['loginStatus'] = 'notLoggedIn';
      }
    });

    _firebaseMessaging.getToken().then((String token) {
      assert(token != null);
      _messagesRef = FirebaseDatabase.instance.reference().child('deviceTokens');
      _messagesRef.push().set(<String, String>{
        'path': user.uid,
        'token': token
      });
    });

    return 'signInAnonymously succeeded: $user';

    // UserUpdateInfo ui = new UserUpdateInfo();
    // ui.displayName = text;
    // ui.photoUrl = _downloadUrl;
    // FirebaseAuth.instance.updateProfile(ui);
  }
}
