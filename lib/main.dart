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
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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
    // _signInAnonymously();
    _signIn();
    // _signOut();
    globals.userState.changes.listen((changes) {
      setState(() {
        _loginStatus = globals.userState['loginStatus'];
      });
    });
  }
  String _loginStatus;
  DatabaseReference _messagesRef;

  @override
  void initState() {
    super.initState();
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // _loadGame(message);
        // _showItemDialog(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
        _loadGame(message);
        // _navigateToItemDetail(message);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
        _loadGame(message);
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

  void _loadGame(Map gameData){
    globals.gameState['id'] = gameData['gameId'];
    globals.gameState['genre'] = gameData['genre'];
    globals.gameState['title'] = gameData['gameTitle'];
    globals.gameState['name'] = gameData['name'];
    globals.gameState['code'] = gameData['code'];
    globals.gameState['creator'] = gameData['creator'];
    globals.gameState['players'] = json.encode(gameData['players']);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([SystemUiOverlay.bottom]);
    SystemChrome.setApplicationSwitcherDescription(new ApplicationSwitcherDescription(
      primaryColor: 0xFF,
    ));

    Widget startPage;
    if (_loginStatus != null && _loginStatus == 'loggedIn') {
      startPage = HomePage();
    } else {
      startPage = SplashPage();
    }
    return new MaterialApp(
      title: 'Pegg Party',
      theme: new ThemeData(
          primaryColor: const Color(0xFF000636),
          fontFamily: 'LondrinaSolid',
          textTheme: TextTheme(title: TextStyle(letterSpacing: 1.2)) ,
          canvasColor: Colors.black,
          buttonColor: const Color(0xFF00B0FF),
          accentColor: const Color(0xFF2F318A),
          primaryColorLight: Colors.white.withOpacity(0.2)),
      onGenerateRoute: Application.router.generator,
      home: startPage,
    );
  }

  Future<String> _signOut() async {
    await FirebaseAuth.instance.signOut();
    globals.userState['loginStatus'] = 'notLoggedIn';
    return 'signed out.';
  }

  Future _signIn() async {
    final FirebaseUser currentUser = await _auth.currentUser();
    globals.prefs = await SharedPreferences.getInstance();
    globals.userState['loginStatus'] = 'loggingIn';
    if(currentUser != null) {
      if(currentUser.phoneNumber != null) {
        var userRef = Firestore.instance.collection('Users').document(currentUser.uid);
        userRef.get().then((snapshot) {
          if (snapshot.data != null) {
            globals.userState['loginStatus'] = 'loggedIn';
            globals.userState['userId'] = currentUser.uid;
            globals.userState['profilePic'] = snapshot.data['profilePic'];
            globals.userState['requests'] = snapshot.data['requests'].toString();
            globals.userState['name'] = snapshot.data['name'];
          } else {
            globals.userState['loginStatus'] = 'notLoggedIn';
          }
          registerPushToken(currentUser.uid);
        });
      } else {
        globals.userState['loginStatus'] = 'notLoggedIn';
      }
    } else {
      globals.userState['loginStatus'] = 'notLoggedIn';
    }
  }

  void registerPushToken(String userId) {
    _firebaseMessaging.getToken().then((String token) {
      _messagesRef = FirebaseDatabase.instance.reference().child('deviceTokens/' + userId);
      _messagesRef.set(<String, dynamic>{
        token: DateTime.now().toString()
      });
    });
  }

  Future<String> _signInAnonymously() async {
    final FirebaseUser user = await _auth.signInAnonymously();
    assert(user != null);
    assert(user.isAnonymous);
    assert(await user.getIdToken() != null);

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
          globals.userState['requests'] = snapshot.data['requests'].toString();
        }
        globals.userState['name'] = snapshot.data['name'];
      } 
      else {
        globals.userState['loginStatus'] = 'notLoggedIn';
      }
    });
    return 'signInAnonymously succeeded: $user';
  }
}
