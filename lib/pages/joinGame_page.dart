import 'package:flutter/material.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UpperCaseTextFormatter extends TextInputFormatter {
	@override
	TextEditingValue formatEditUpdate(
		TextEditingValue oldValue, TextEditingValue newValue) {
		if (oldValue.text == newValue.text) {
			return newValue;
		}
		return TextEditingValue(
			text: newValue.text?.toUpperCase(),
			selection: newValue.selection,
		);
	}
}

class JoinGamePage extends StatelessWidget {
	final TextEditingController _textController = TextEditingController();
	final UpperCaseTextFormatter upperCaseTextFormatter =
		new UpperCaseTextFormatter();

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			// color: Colors.white,
			appBar: new AppBar(
				elevation: -1.0,
				automaticallyImplyLeading: false,
				leading: new IconButton(
					icon: new Icon(Icons.close, color: Colors.white),
					onPressed: () => Navigator.pop(context)),
				backgroundColor: Theme.of(context).primaryColor,
				title: new Text("Join Game",
					style: new TextStyle(
						color: Colors.white,
						fontWeight: FontWeight.w800,
						letterSpacing: 0.5,
						fontSize: 22.0,
					)),
			),
			body: Container(
				width: 500.0,
				decoration: BoxDecoration(
					image: DecorationImage(
						image: AssetImage("assets/images/background-purple.png"),
						fit: BoxFit.fill)),
				child: Column(children: <Widget>[
					Row(children: <Widget>[
						Expanded(
							child: Padding(
								padding: EdgeInsets.only(left: 15.0),
								child: Text("Private Game",
									style:
										TextStyle(color: Colors.white70, fontSize: 12.0),
									textAlign: TextAlign.left)))
					]),
					Padding(
						padding: EdgeInsets.all(20.0),
						child: Container(
							height: 60.0,
							width: 300.0,
							padding:
								EdgeInsets.symmetric(vertical: 6.0, horizontal: 10.0),
							child: Row(children: <Widget>[
								Flexible(
									child: TextFormField(
									maxLines: 1,
									maxLength: 5,
									textAlign: TextAlign.start,
									style: TextStyle(
										fontSize: 25.0,
										fontWeight: FontWeight.w800,
										color: Colors.white,
										letterSpacing: 8.0,
                    fontFamily: 'LondrinaSolid'),
									controller: _textController,
									inputFormatters: <TextInputFormatter>[
										upperCaseTextFormatter
									],
									keyboardType: TextInputType.text,
									decoration:
										InputDecoration.collapsed(hintText: "Room code", hintStyle: TextStyle(color: Colors.white)),
								))
							]),
							decoration: BoxDecoration(
								color: const Color(0x33FFFFFF),
								borderRadius: BorderRadius.circular(8.0),
								// border:
								// Border(top: BorderSide(color: Colors.grey[200]))
							))),
					Padding(
						padding: const EdgeInsets.only(top: 10.0, bottom: 30.0),
						child: RaisedButton(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
							key: null,
							onPressed: () => _handleCodeSubmitted(_textController.text, context),
							color: Theme.of(context).buttonColor,
							shape: new RoundedRectangleBorder(
								borderRadius:
									new BorderRadius.circular(
										10.0)),
							child: Text(
								"Send Request",
								style: TextStyle(
									fontSize: 20.0,
									color: Colors.white,
									fontWeight: FontWeight.w800,
								),
							))),
				])),
		);
	}

	void _handleCodeSubmitted(String code, BuildContext context) async {
		// QuerySnapshot snapshot = await Firestore.instance.collection('Games').where('code', isEqualTo: code).getDocuments();
		// var channelName = snapshot.documents;
		var userRef = Firestore.instance.collection('Users').document(globals.userState['userId']);
		userRef.get().then((snapshot) {
			Map userRequests = snapshot.data['requests'];
			if(userRequests == null) userRequests = {};
			userRequests[code] = true;
			userRef.updateData(<String, dynamic>{
				'requests': userRequests,
			});
      Navigator.pop(context);
      _textController.clear();
		});

	}
}