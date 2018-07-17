library gratzi_game.globals;
// import 'package:camera/camera.dart';
import 'package:observable/observable.dart';

bool isLoggedIn = false;
ObservableMap userState = toObservable({'userId': '', 'name': '', 'profilePic': ''});
ObservableMap gameState = toObservable({'id': '', 'type': ''});
// List<CameraDescription> cameras;