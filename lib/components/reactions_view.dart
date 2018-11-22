import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:party_quest/globals.dart' as globals;
import 'package:cached_network_image/cached_network_image.dart';

class ReactionsView extends StatefulWidget {
  final DocumentSnapshot messageData;
  final TapUpDetails tapUpDetails;
  final Function doneCallback;
  ReactionsView(this.messageData, this.tapUpDetails, this.doneCallback);
	
  @override
	_ReactionsViewState createState() => new _ReactionsViewState();
}

class _ReactionsViewState extends State<ReactionsView> {

	@override
	void initState() {
		super.initState();
	}

  @override
	Widget build(BuildContext context) {
    return _buildReactionViewer();
  }


  Widget _buildReactionViewer() {
    return widget.messageData.data['reactions'] == null ? 
      Stack(children: <Widget>[Positioned(top: widget.tapUpDetails.globalPosition.dy - 100, 
        child: Column(
            children: <Widget>[
              _buildNoReactionsMessage(),
              _buildReactionComposer() 
              ]))]) :
      StreamBuilder<QuerySnapshot>(
        stream: Firestore.instance
            .collection('Users')
            .where('games.' + globals.currentGame.documentID, isEqualTo: true)
            .snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) return const Text('Loading...', style: TextStyle(color: Colors.white));
          List <Widget> reactions = [];
          Map playerMap = {};
          snapshot.data.documents.forEach((player){
            playerMap[player.documentID] = player['profilePic'];
          });
          for(var key in widget.messageData.data['reactions'].keys){
            if(widget.messageData.data['reactions'][key] is int) return Container(); // BACKWARDS COMPATIBLE
            widget.messageData.data['reactions'][key].forEach((playerId){
              // Non-players just show gray unicorn
              var playerProfilePic = playerMap[playerId] == null ? 'assets/images/profile-placeholder.png' : playerMap[playerId];
              reactions.add(
                Stack(children: <Widget>[
                  Padding(padding: EdgeInsets.symmetric(horizontal: 10.0),
                    child: Container(width: 50.0, height: 50.0,
                      decoration: BoxDecoration(border: Border.all(color: Colors.white, width: 1.0), shape: BoxShape.circle,
                        image: DecorationImage(fit: BoxFit.cover,
                          image: playerProfilePic.contains('http') ? CachedNetworkImageProvider(playerProfilePic) : AssetImage(playerProfilePic)
                  )))),
                  Positioned(top: 35.0, left: 10.0, 
                    child: Padding(padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: GestureDetector(child: Container(child: Image.asset("assets/images/reaction-$key.png"), width: 30.0)))),
                ]));
            });
          }
          return Stack(children: <Widget>[Positioned(top: widget.tapUpDetails.globalPosition.dy - 100, 
          child: Column(
            children: <Widget>[
              _buildReactionsViewer(reactions),
              _buildReactionComposer()
            ]))]);
        });
  }

  Widget _buildNoReactionsMessage(){
    return Container(height: 20.0, width: MediaQuery.of(context).size.width, 
        child: Text('No reactions yet.', style: TextStyle(color: Colors.white), textAlign: TextAlign.center,));
  }

  Widget _buildReactionsViewer(List <Widget> reactions){
    return Container(height: 80.0, width: MediaQuery.of(context).size.width, 
      child: ListView(scrollDirection: Axis.horizontal, children: reactions));
  }

	Widget _buildReactionComposer() {
    if(widget.messageData.data['userId'] != globals.currentUser.documentID && !widget.messageData.data['reactions'].toString().contains(globals.currentUser.documentID)) {
      return Container(height: 80.0, width: MediaQuery.of(context).size.width, child: ListView(
          scrollDirection: Axis.horizontal,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: GestureDetector(child: Container(child: Image.asset('assets/images/reaction-love.png'), width: 50.0), onTap: () => _onTapReaction('love'))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: GestureDetector(child: Container(child: Image.asset('assets/images/reaction-cool.png'), width: 50.0), onTap: () => _onTapReaction('cool'))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: GestureDetector(child: Container(child: Image.asset('assets/images/reaction-lol.png'), width: 50.0), onTap: () => _onTapReaction('lol'))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: GestureDetector(child: Container(child: Image.asset('assets/images/reaction-meh.png'), width: 50.0), onTap: () => _onTapReaction('meh'))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: GestureDetector(child: Container(child: Image.asset('assets/images/reaction-wow.png'), width: 50.0), onTap: () => _onTapReaction('wow'))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.0),
              child: GestureDetector(child: Container(child: Image.asset('assets/images/reaction-snooze.png'), width: 50.0), onTap: () => _onTapReaction('snooze'))),
          ],
        ));
    } else {
      return Container(width: 0.0);
    }
	}

		void _onTapReaction(String reactionType) {
      widget.doneCallback();
      widget.messageData.reference.get().then((bubbleDoc) {
        if(bubbleDoc.data != null){
          if(bubbleDoc.data['reactions'] != null){
            if(bubbleDoc.data['reactions'][reactionType] != null && !(bubbleDoc.data['reactions'][reactionType] is int)){
              var newReactionsList = bubbleDoc.data['reactions'][reactionType].toList();
              newReactionsList.add(globals.currentUser.documentID);
              bubbleDoc.data['reactions'][reactionType] = newReactionsList;
            } else
              bubbleDoc.data['reactions'][reactionType] = [globals.currentUser.documentID];
          } else {
            bubbleDoc.data['reactions'] = {reactionType: [globals.currentUser.documentID]};
          }
        }
        // UPDATE LOG MESSAGE
        widget.messageData.reference.updateData(bubbleDoc.data).then((onValue) {
          var authorId = bubbleDoc.data['userId'];
          var gameId = globals.currentGame.documentID;
          // UPDATE GAME/REACTIONS
          final DocumentReference reactionsRef = Firestore.instance.collection('Games/$gameId/Reactions').document(authorId);
          reactionsRef.get().then((reactionResult){
            if(reactionResult.data == null){
              reactionsRef.setData({ reactionType: 1 });
            } else {
              if(reactionResult.data[reactionType] == null) reactionResult.data[reactionType] = 0;
              reactionResult.data[reactionType] += 1;
              reactionsRef.updateData(reactionResult.data);
            }
          });
          
          //UPDATE USER REACTIONS
          // final DocumentReference userRef = Firestore.instance.collection('Users').document(userId);
          // userRef.get().then((userResult){
          //   if(userResult.data['reactions'] == null){
          //     userResult.data['reactions'] = { reactionType: 1 };
          //     userResult.data['totalReactions'] = 1;
          //     userRef.setData(userResult.data);
          //   } else {
          //     if(userResult.data['reactions'][reactionType] == null) userResult.data['reactions'][reactionType] = 0;
          //     userResult.data['reactions'][reactionType] += 1;
          //     userResult.data['totalReactions'] += 1;
          //     userRef.updateData(userResult.data);
          //   }
          // });

          // //UPDATE GAME REACTIONS
          // final DocumentReference gameRef = Firestore.instance.collection('Games').document(gameId);
          // gameRef.get().then((gameResult){
          //   if(gameResult.data['reactions'] == null){
          //     gameResult.data['reactions'] = { reactionType: 1 };
          //     gameResult.data['totalReactions'] = 1;
          //     gameRef.setData(gameResult.data);
          //   } else {
          //     if(gameResult.data['reactions'][reactionType] == null) gameResult.data['reactions'][reactionType] = 0;
          //     gameResult.data['reactions'][reactionType] += 1;
          //     gameResult.data['totalReactions'] += 1;
          //     gameRef.updateData(gameResult.data);
          //   }
          // });
          
        });


      // This doesnt work for public games because public players dont have accesss to update the game.
      // final DocumentReference gameRef =
      // Firestore.instance.collection('Games').document(globals.currentGame.documentID);
      // gameRef.get().then((gameResult) {
      //   var reactions = gameResult['reactions'] == null ? {bubbleDoc.data['userId']: {reactionType: 0}} : gameResult['reactions'];
      //   if(reactions[bubbleDoc.data['userId']] == null) reactions[bubbleDoc.data['userId']] = {reactionType: 0};
      //   if(reactions[bubbleDoc.data['userId']][reactionType] == null) reactions[bubbleDoc.data['userId']][reactionType] = 0;
      //   reactions[bubbleDoc.data['userId']][reactionType] += 1;
      //   gameRef.updateData(<String, dynamic>{ 'reactions': reactions });
      // });
    });
	}

}