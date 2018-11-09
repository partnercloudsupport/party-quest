library party_quest.globals;
// import 'package:camera/camera.dart';
import 'package:observable/observable.dart';
import 'package:shared_preferences/shared_preferences.dart';

SharedPreferences prefs;
ObservableMap userState = toObservable({'loginStatus': '', 'userId': '', 'name': '', 'profilePic': ''});
ObservableMap gameState = toObservable({'id': '', 'genre': '', 'name': '', 'title': '', 'isPublic': '', 'code': ''});
// List<CameraDescription> cameras;