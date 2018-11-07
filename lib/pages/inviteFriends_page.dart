import 'package:flutter/material.dart';
import 'package:share/share.dart';

class InviteFriendsPage extends StatelessWidget {
	InviteFriendsPage(String code) : this.code = code;
	final String code;

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: new AppBar(
				automaticallyImplyLeading: false,
				leading: new IconButton(
					icon: new Icon(Icons.close, color: Colors.white),
					onPressed: () => Navigator.pop(context)),
				backgroundColor: Theme.of(context).primaryColor,
				elevation: -1.0,
				title: new Text(
					"Invite Friends",
					style:
						TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 24.0),
				)),
			body: Container(
				decoration: BoxDecoration(
					image: DecorationImage(
						image: AssetImage("assets/images/background-purple.png"),
						fit: BoxFit.fill)),
				child: 
					Container(
						child: Align(
		        alignment: Alignment.topCenter, 
            child: Column(children: <Widget>[
              Padding(padding: EdgeInsets.all(10.0), child: Text('Your game code: ', style: TextStyle(fontSize: 20.0, color: Colors.white))),
              Text(code, style: TextStyle(fontSize: 40.0, color: Colors.white)),
              RaisedButton(
							padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
								color: Theme.of(context).buttonColor,
								shape: new RoundedRectangleBorder(
									borderRadius:
										new BorderRadius.circular(
											10.0)),
								onPressed: () => _handleShareButtonTap(code),
								child: new Text(
									"Share this code",
									style: new TextStyle(
										fontSize: 20.0,
										color: Colors.white,
										fontWeight: FontWeight.w800,
									),))
            
            ])))
			));
	}

  void _handleShareButtonTap(String code){
    Share.share('Share this code to invite friends: ' + code);
  }
}
