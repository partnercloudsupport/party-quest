library gratzi_game.globals;
import 'package:camera/camera.dart';
import 'package:observable/observable.dart';

bool isLoggedIn = false;
String userId;
ObservableMap userState = toObservable({'userId': '', 'userName': ''});
ObservableMap gameState = toObservable({'gameId': '', 'gameName': ''});
List<CameraDescription> cameras;