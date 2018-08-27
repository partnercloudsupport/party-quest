library pegg_party.globals;
// import 'package:camera/camera.dart';
import 'package:observable/observable.dart';

ObservableMap userState = toObservable({'loginStatus': '', 'userId': '', 'name': '', 'profilePic': ''});
ObservableMap gameState = toObservable({'id': '', 'category': '', 'name': '', 'title': '', 'isPublic': '', 'code': ''});
// List<CameraDescription> cameras;