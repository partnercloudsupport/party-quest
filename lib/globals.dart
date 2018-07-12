library gratzi_game.globals;
import 'package:camera/camera.dart';
import 'package:observable/observable.dart';

bool isLoggedIn = false;
String userId;
ObservableMap gameState = toObservable({'gameId': '-LH9WTMC4xnb07J0WArC', 'gameName': 'City Quest'});
List<CameraDescription> cameras;