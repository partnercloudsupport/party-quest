// import 'dart:math';
import 'package:flutter/material.dart';
import '../application.dart';
import 'package:party_quest/globals.dart' as globals;
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
				child: Stack(children: <Widget>[
					Column(children: <Widget>[
						Expanded(
							child: Container(
								decoration: BoxDecoration(
									image: DecorationImage(
							image: AssetImage("assets/images/PartyQuest-splash.png"),
							fit: BoxFit.contain,
						))))]),
						// Container(child: Text("Be a unicorn.", style: TextStyle(color: Colors.white, fontSize: 30.0))),
						Align(
		alignment: Alignment.bottomCenter,
			child: Padding(padding: EdgeInsets.all(20.0), child: _loginStatus == 'notLoggedIn'
				? RaisedButton(
					padding: EdgeInsets.symmetric(
						vertical: 20.0, horizontal: 40.0),
					onPressed: () => Application.router.navigateTo(
						context, 'phoneAuth',
						transition: TransitionType.fadeIn),
					color: Theme.of(context).buttonColor,
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
				: Container(child: CircularProgressIndicator())))
				])));
	}
}
