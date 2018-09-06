library pegg_party.globals;
// import 'package:camera/camera.dart';
import 'package:observable/observable.dart';

String question;
String peggeeProfilePic;
String peggeeName;
ObservableMap userState = toObservable({'loginStatus': '', 'userId': '', 'name': '', 'profilePic': ''});
ObservableMap gameState = toObservable({'id': '', 'genre': '', 'name': '', 'title': '', 'isPublic': '', 'code': ''});
// List<CameraDescription> cameras;