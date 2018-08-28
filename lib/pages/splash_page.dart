// import 'dart:math';
import 'package:flutter/material.dart';
import '../application.dart';
import 'package:pegg_party/globals.dart' as globals;
import 'package:fluro/fluro.dart';

class SplashPage extends StatefulWidget {
	@override
	createState() => SplashPageState();
}

class SplashPageState extends State<SplashPage> {
	SplashPageState() {
		globals.userState.changes.listen((changes) {
			setState(() {
				_loginStatus = globals.userState['loginStatus'];
			});
		});
	}
	String _loginStatus;

	@override
	Widget build(BuildContext context) {
		return _buildLandingPage(context);
	}

	Widget _buildLandingPage(BuildContext context) {
		return Scaffold(
			backgroundColor: Colors.black,
			body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
					image: AssetImage("assets/images/splash_bg.png"),
					fit: BoxFit.cover,
				)),
				child: Row(children: <Widget>[
					Expanded(
						child: Column(children: <Widget>[
						Expanded(
							child: Container(
								decoration: BoxDecoration(
									image: DecorationImage(
							image: AssetImage("assets/images/splash_unicorns.png"),
							fit: BoxFit.contain,
						)))),
						// Container(child: Text("Be a unicorn.", style: TextStyle(color: Colors.white, fontSize: 30.0))),
						Padding(
							padding: EdgeInsets.all(40.0),
							child: _loginStatus == 'notLoggedIn'
								? RaisedButton(
									padding: EdgeInsets.symmetric(
										vertical: 20.0, horizontal: 40.0),
									onPressed: () => Application.router.navigateTo(
										context, 'userProfile',
										transition: TransitionType.fadeIn),
									color: const Color(0xFF00b0ff),
									shape: RoundedRectangleBorder(
										borderRadius: new BorderRadius.circular(40.0)),
									child: Text(
										"Let's Play!",
										style: new TextStyle(
											fontSize: 22.0,
											color: Colors.white,
											fontWeight: FontWeight.w800,
										),
									))
								: Container(child: CircularProgressIndicator()))
					]))
				])));
	}
}
