import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:flutter/services.dart';
// import 'package:flutter/scheduler.dart';
import 'package:timeago/timeago.dart';
import '../application.dart';
import 'package:fluro/fluro.dart';
import '../components/reactions_view.dart';
import '../components/actions_view.dart';
import '../components/chatMessageItem.dart';
import 'package:firestore_ui/animated_firestore_list.dart';

class ChatView extends StatefulWidget {
  final String gameId;
  ChatView(this.gameId);
  
	@override
	_ChatViewState createState() => new _ChatViewState();
}

class _ChatViewState extends State<ChatView> {

	@override
	void initState() {
		super.initState();
	}

	bool _showOverlay = false;
  bool _showJumpButton = true;

	TapUpDetails _tapUpDetails;
	DocumentSnapshot _tappedBubble;
  ScrollController _listViewController;
	_ChatViewState() {
    _showOverlay = false;
	}

  void loadOffset() {
    var currentOffset = globals.prefs.getDouble(widget.gameId + '_offset');
    if(currentOffset != null) {
      _listViewController = ScrollController(initialScrollOffset: currentOffset);
    } else {
      _listViewController = ScrollController(initialScrollOffset: 0.0);
    }
  }    

	@override
	Widget build(BuildContext context) {
    loadOffset();
		// CollectionReference get logs =>
    // WidgetsBinding.instance.addPostFrameCallback((_) => jumpToLine()); 
		return 
    Scaffold(
			// backgroundColor: Colors.white,
			// drawer: AccountDrawer(), // left side
			appBar: AppBar(
        elevation: 50.0,
        title: Text(globals.gameState['title'], style: TextStyle(color: Colors.white, fontSize: 30.0)),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
					icon: Icon(Icons.close, color: Colors.white),
					onPressed: () => Navigator.pop(context)),
        actions: <Widget>[
					IconButton(
						icon: Icon(
							Icons.info_outline,
							color: Colors.white,
						),
						tooltip: 'Info about this Game.',
						onPressed: _openInfoView)
				],
      ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
            // image: AssetImage("assets/images/$_gameType.jpg"),
            image: AssetImage("assets/images/background-cosmos.png"),
            fit: BoxFit.cover,
            // colorFilter: ColorFilter.mode(
            // Colors.black.withOpacity(0.9), BlendMode.dstATop)
          )
          ),
          child: Stack(children: <Widget>[
          // Column(children: <Widget>[
            Flex(direction: Axis.vertical, children: <Widget>[_buildChatLog(), Container(height: 100.0)]),
            _showJumpButton == true ? 
            Align(alignment: Alignment.bottomCenter, child: _buildJumpButton()) 
            :
            Align(alignment: Alignment.bottomCenter, child: ActionsView(widget.gameId, _scrollToEnd)),
            // Align(alignment: Alignment.bottomCenter, child: 
            // globals.gameState['players']?.contains(globals.userState['userId']) == true
            //   ? _buildTextComposer()
            //   : _buildInfoBox('Tap any speech bubble to react to what players are saying.')),
            _showOverlay == true ? _buildOverlay(ReactionsView(_tappedBubble, _tapUpDetails, _onCloseOverlay)) : Container()
        ])
    ));
	}

  Widget _buildJumpButton(){
    return Padding(padding: EdgeInsets.symmetric(vertical: 25.0), 
      child: RaisedButton(
        elevation: 4.0,
        highlightElevation: 50.0,
        padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 10.0),
        // onPressed: null,
        onPressed: _scrollToEnd,
        // color: Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
        child: Container(
          margin: EdgeInsets.only(left: 4.0),
          child: Text('Jump to bottom', style: TextStyle(color: Colors.white, fontSize: 20.0)))
    ));
  }

  void _scrollToEnd() {
    _listViewController.animateTo(
      _listViewController.position.maxScrollExtent, 
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
    setState(() {
      _showJumpButton = false;
    });                                     
  }   

  void _onCloseOverlay(){
    setState(() {
      _showOverlay = false;
    });
  }

	Widget _buildOverlay(Widget content) {
		MediaQueryData queryData;
		queryData = MediaQuery.of(context);
		return GestureDetector(
			child: Center(
				child: Container(
					width: queryData.size.width,
					height: queryData.size.height,
					child: content,
					decoration: BoxDecoration(
						shape: BoxShape.rectangle,
						color: Colors.black.withOpacity(.4),
					)),
			),
			onTap: _onCloseOverlay);
		}

  void _openInfoView() {
		Application.router
			.navigateTo(context, 'info', transition: TransitionType.native);
	}


	Widget _buildChatLog() {
    DocumentSnapshot lastDocument;
    return Expanded(
      child: FirestoreAnimatedList(
      onNotification: _onScrollNotification,
      controller: _listViewController,
      reverse: false,
      query: Firestore.instance
        .collection('Games/${widget.gameId}/Logs')
        // .where('dts', isGreaterThan: monthAgo)
        .orderBy('dts', descending: false)
        .snapshots(),
      itemBuilder: (
        BuildContext context,
        DocumentSnapshot currentDocument,
        Animation<double> animation,
        int index,
      ) {
        Widget chatItem;
        if(lastDocument != null && currentDocument['userName'] != null && (lastDocument['userId'] != currentDocument['userId'])){
          chatItem = Column(children: <Widget>[
            _buildLabel(currentDocument['userName'], currentDocument['dts']),
            ChatMessageListItem(index, currentDocument, _onTapBubble)
          ]);
        } else {
          chatItem = ChatMessageListItem(index, currentDocument, _onTapBubble);
        }
        lastDocument = currentDocument;
        return FadeTransition(
          opacity: animation,
          // textDirection: TextDirection.ltr,
          // turns: animation,
          // scale: animation,
          // sizeFactor: animation,
          child: chatItem,
        );
      },
    ));

  }

  bool _onScrollNotification(ScrollNotification notification) {
    // print(_listViewController.position.maxScrollExtent);
    // print(_listViewController.offset);
    if(_listViewController.offset + 150 > _listViewController.position.maxScrollExtent && _showJumpButton){
      setState(() {
        _showJumpButton = false;
      });
    }
    if (notification is ScrollEndNotification) {
      // Store new offset
      storePref('offset', _listViewController.offset);
    } if (notification is ScrollStartNotification) {
      closeKeyboard(notification.dragDetails);
    }
    return true;
  }

  void storePref(String name, dynamic value) async {
    await globals.prefs.setDouble(widget.gameId + '_' + name, value);
  }

	// TODO: optimize this...
	void closeKeyboard(DragStartDetails d) {
		// if (d.delta.distance > 20) {
		FocusScope.of(context).requestFocus(new FocusNode());
		SystemChannels.textInput.invokeMethod('TextInput.hide');
		// }
	}
  
	void _onTapBubble(TapUpDetails details, DocumentSnapshot document) {
    setState(() {
      _showOverlay = true;
      _tapUpDetails = details;
      _tappedBubble = document;
    });
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