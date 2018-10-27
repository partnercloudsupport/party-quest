import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:flutter/services.dart';
import 'package:timeago/timeago.dart';

class SynopsisInfoPage extends StatefulWidget {
	@override
	_SynopsisInfoPageState createState() => new _SynopsisInfoPageState();
}

class _SynopsisInfoPageState extends State<SynopsisInfoPage> {

	@override
	void initState() {
		super.initState();
	}

	final TextEditingController _textController = TextEditingController();

	@override
	Widget build(BuildContext context) {
		return 
				Column(children: <Widget>[
					_buildSynopsis(),
					globals.gameState['players']?.contains(globals.userState['userId']) == true
						? _buildTextComposer()
						: Container()
				]);
	}

	Widget _buildSynopsis() {
		var _gameId = globals.gameState['id'];
		final now = DateTime.now();
		final monthAgo = new DateTime(now.year, now.month, now.day - 30);
		if (_gameId != null) {
			return Expanded(child: GestureDetector(
        onVerticalDragDown: (DragDownDetails d) => closeKeyboard(d),
				child: StreamBuilder<QuerySnapshot>(
					stream: Firestore.instance
						.collection('Games/$_gameId/Synopsis')
						.where('dts', isGreaterThan: monthAgo)
						.orderBy('dts', descending: true)
						.snapshots(),
					builder: (BuildContext context,
						AsyncSnapshot<QuerySnapshot> snapshot) {
						if (!snapshot.hasData) return const Text('Loading...');
						final int messageCount = snapshot.data.documents.length;
						return new ListView.builder(
							reverse: true,
							itemCount: messageCount,
							itemBuilder: (_, int index) {
								final DocumentSnapshot document = snapshot.data.documents[index];
                List<Widget> logItems = [];
                DocumentSnapshot nextDocument;
                // Get next document
								if (index + 1 < messageCount) nextDocument = snapshot.data.documents[index + 1];
								else nextDocument = snapshot.data.documents[index];
                // Build label if needed
                if (document['userName'] != null && (index == messageCount-1 || document['userId'] != nextDocument['userId'])){
                  logItems.add(_buildLabel(document['userName'],  document['dts']));
                }
                logItems.add(
                  Padding(padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0), child: 
                    Text(document['text'].replaceAll('\\n', '\n\n'), style: 
                    TextStyle(
                      color: document['color'] == null ? Colors.white : Color(int.parse("0x" + 'FF' + document['color'])), 
                      fontSize: 20.0 )))
                );
                return Column(children: logItems);
            });
					})));
		} else {
			return Expanded(child: Container());
		}
	}

	// TODO: optimize this...
	void closeKeyboard(DragDownDetails d) {
		// if (d.delta.distance > 20) {
		FocusScope.of(context).requestFocus(new FocusNode());
		SystemChannels.textInput.invokeMethod('TextInput.hide');
		// }
	}
  
	Widget _buildTextComposer() {
		return Container(
			decoration: BoxDecoration(color: Colors.white),
			child: IconTheme(
				data: IconThemeData(color: Theme.of(context).accentColor),
				child: Container(
					child: Row(children: <Widget>[
						Flexible(
							child: TextField(
								style: TextStyle(color: Colors.white, fontSize: 20.0, fontFamily: 'LondrinaSolid'),
								maxLines: null,
                cursorColor: Colors.white,
                cursorWidth: 3.0,
								keyboardType: TextInputType.multiline,
								controller: _textController,
								onSubmitted: _handleSubmitted,
								decoration: InputDecoration(
									contentPadding: const EdgeInsets.all(20.0),
									hintText: "Write notes, rules, or events...",
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
									hintStyle: TextStyle(color: Colors.white)),
							),
						),
						Container(
							margin: EdgeInsets.only(left: 4.0),
							child: IconButton(
								icon: Icon(
									Icons.send,
									color: Colors.white,
									size: 30.0,
								),
								onPressed: () =>
									_handleSubmitted(_textController.text))),
					]),
					decoration:
						// Theme.of(context).platform == TargetPlatform.iOS
						// ?
						BoxDecoration(
							color: const Color(0xFF4C6296),
							border: Border(
								top: BorderSide(color: const Color(0xFF4C6296)))))
				// : null),
				));
	}

	void _handleSubmitted(String text) {
		var _gameId = globals.gameState['id'];
		_textController.clear();
		if (text.length > 0) {
			final DocumentReference document =
				Firestore.instance.collection('Games/$_gameId/Synopsis').document();
			document.setData(<String, dynamic>{
				'text': text,
				'dts': DateTime.now(),
				'profileUrl': globals.userState['profilePic'],
				'userName': globals.userState['name'],
				'userId': globals.userState['userId']
			});
		}
	}

	Widget _buildLabel(String username, DateTime dts) {
		return Row(
			// margin: const EdgeInsets.all(10.0),
			children: <Widget>[
				Expanded(
					child: Padding(
						padding: username == globals.userState['name'] ? EdgeInsets.only(left: 15.0, top: 10.0) : EdgeInsets.only(right: 15.0, top: 10.0),
						child: Column(crossAxisAlignment: username == globals.userState['name'] ? CrossAxisAlignment.start : CrossAxisAlignment.end, children: <Widget>[Text(
							username,
							textAlign: TextAlign.right,
							style: TextStyle(
								color: Colors.white,
								letterSpacing: 0.5,
								fontSize: 14.0,
							),
						), Text(timeAgo(dts.toLocal()),
							style: TextStyle(
								color: Colors.white.withOpacity(.8),
								fontSize: 12.0,
							))
			])))]);
	}
}
