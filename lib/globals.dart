library party_quest.globals;
// import 'package:camera/camera.dart';
import 'package:observable/observable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

SharedPreferences prefs;
QuerySnapshot myGames;
QuerySnapshot topGames;
var playersList;
ObservableMap userState = toObservable({'loginStatus': ''});
DocumentSnapshot currentGame;
DocumentSnapshot currentUser;